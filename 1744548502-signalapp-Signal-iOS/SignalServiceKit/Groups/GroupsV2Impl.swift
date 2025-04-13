//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

public class GroupsV2Impl: GroupsV2 {
    private var urlSession: OWSURLSessionProtocol {
        return SSKEnvironment.shared.signalServiceRef.urlSessionForStorageService()
    }

    private let authCredentialStore: AuthCredentialStore
    private let authCredentialManager: any AuthCredentialManager
    private let groupSendEndorsementStore: any GroupSendEndorsementStore

    init(
        appReadiness: AppReadiness,
        authCredentialStore: AuthCredentialStore,
        authCredentialManager: any AuthCredentialManager,
        groupSendEndorsementStore: any GroupSendEndorsementStore
    ) {
        self.authCredentialStore = authCredentialStore
        self.authCredentialManager = authCredentialManager
        self.groupSendEndorsementStore = groupSendEndorsementStore
        self.profileKeyUpdater = GroupsV2ProfileKeyUpdater(appReadiness: appReadiness)

        SwiftSingletons.register(self)

        appReadiness.runNowOrWhenAppWillBecomeReady {
            guard DependenciesBridge.shared.tsAccountManager.registrationStateWithMaybeSneakyTransaction.isRegistered else {
                return
            }

            Task {
                do {
                    try await GroupManager.ensureLocalProfileHasCommitmentIfNecessary()
                } catch {
                    Logger.warn("Local profile update failed with error: \(error)")
                }
            }
        }

        appReadiness.runNowOrWhenAppDidBecomeReadyAsync {
            Self.enqueueRestoreGroupPass(authedAccount: .implicit())
        }

        observeNotifications()
    }

    // MARK: - Notifications

    private func observeNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reachabilityChanged),
            name: SSKReachability.owsReachabilityDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: .OWSApplicationDidBecomeActive,
            object: nil
        )
    }

    @objc
    private func didBecomeActive() {
        AssertIsOnMainThread()

        Self.enqueueRestoreGroupPass(authedAccount: .implicit())
    }

    @objc
    private func reachabilityChanged() {
        AssertIsOnMainThread()

        Self.enqueueRestoreGroupPass(authedAccount: .implicit())
    }

    // MARK: - Create Group

    public func createNewGroupOnService(
        groupModel: TSGroupModelV2,
        disappearingMessageToken: DisappearingMessageToken
    ) async throws -> GroupV2SnapshotResponse {
        do {
            return try await _createNewGroupOnService(
                groupModel: groupModel,
                disappearingMessageToken: disappearingMessageToken,
                isRetryingAfterRecoverable400: false
            )
        } catch GroupsV2Error.serviceRequestHitRecoverable400 {
            // We likely failed to create the group because one of the profile key
            // credentials we submitted was expired, possibly due to drift between our
            // local clock and the service. We should try again exactly once, forcing a
            // refresh of all the credentials first.
            return try await _createNewGroupOnService(
                groupModel: groupModel,
                disappearingMessageToken: disappearingMessageToken,
                isRetryingAfterRecoverable400: true
            )
        }
    }

    private func _createNewGroupOnService(
        groupModel: TSGroupModelV2,
        disappearingMessageToken: DisappearingMessageToken,
        isRetryingAfterRecoverable400: Bool
    ) async throws -> GroupV2SnapshotResponse {
        let groupV2Params = try groupModel.groupV2Params()

        let groupProto = try await self.buildProtoToCreateNewGroupOnService(
            groupModel: groupModel,
            disappearingMessageToken: disappearingMessageToken,
            groupV2Params: groupV2Params,
            shouldForceRefreshProfileKeyCredentials: isRetryingAfterRecoverable400
        )

        let requestBuilder: RequestBuilder = { authCredential -> GroupsV2Request in
            return try StorageService.buildNewGroupRequest(
                groupProto: groupProto,
                groupV2Params: groupV2Params,
                authCredential: authCredential
            )
        }

        let response = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: nil,
            behavior400: isRetryingAfterRecoverable400 ? .fail : .reportForRecovery,
            behavior403: .fail,
            behavior404: .fail
        )

        let groupResponseProto = try GroupsProtoGroupResponse(serializedData: response.responseBodyData ?? Data())

        return try GroupsV2Protos.parse(
            groupResponseProto: groupResponseProto,
            downloadedAvatars: GroupAvatarStateMap.from(groupModel: groupModel),
            groupV2Params: groupV2Params
        )
    }

    /// Construct the proto to create a new group on the service.
    /// - Parameters:
    ///   - shouldForceRefreshProfileKeyCredentials: Whether we should force-refresh PKCs for the group members.
    private func buildProtoToCreateNewGroupOnService(
        groupModel: TSGroupModelV2,
        disappearingMessageToken: DisappearingMessageToken,
        groupV2Params: GroupV2Params,
        shouldForceRefreshProfileKeyCredentials: Bool = false
    ) async throws -> GroupsProtoGroup {
        guard let localAci = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction?.aci else {
            throw OWSAssertionError("Missing localAci.")
        }

        // Gather the ACIs for all full (not invited) members, and get profile key
        // credentials for them. By definition, we cannot get a PKC for the invited
        // members.
        let acis: [Aci] = groupModel.groupMembers.compactMap { address in
            guard let aci = address.aci else {
                owsFailDebug("Address of full member in new group missing ACI.")
                return nil
            }
            return aci
        }

        guard acis.contains(localAci) else {
            throw OWSAssertionError("localUuid is not a member.")
        }

        let profileKeyCredentialMap = try await loadProfileKeyCredentials(
            for: acis,
            forceRefresh: shouldForceRefreshProfileKeyCredentials
        )
        return try GroupsV2Protos.buildNewGroupProto(
            groupModel: groupModel,
            disappearingMessageToken: disappearingMessageToken,
            groupV2Params: groupV2Params,
            profileKeyCredentialMap: profileKeyCredentialMap,
            localAci: localAci
        )
    }

    // MARK: - Update Group

    // This method updates the group on the service.  This corresponds to:
    //
    // * The local user editing group state (e.g. adding a member).
    // * The local user accepting an invite.
    // * The local user reject an invite.
    // * The local user leaving the group.
    // * etc.
    //
    // Whenever we do this, there's a few follow-on actions that we always want to do (on success):
    //
    // * Update the group in the local database to reflect the update.
    // * Insert "group update info" messages in the conversation history.
    // * Send "group update" messages to other members &  linked devices.
    //
    // We do those things here as well, to DRY them up and to ensure they're always
    // done immediately and in a consistent way.
    private func updateExistingGroupOnService(changes: GroupsV2OutgoingChanges) async throws {

        let justUploadedAvatars = GroupAvatarStateMap.from(changes: changes)
        let groupId = changes.groupId
        let groupV2Params = try GroupV2Params(groupSecretParams: changes.groupSecretParams)

        let messageBehavior: GroupUpdateMessageBehavior
        let httpResponse: HTTPResponse
        do {
            (messageBehavior, httpResponse) = try await buildGroupChangeProtoAndTryToUpdateGroupOnService(
                groupId: groupId,
                groupV2Params: groupV2Params,
                changes: changes
            )
        } catch {
            switch error {
            case GroupsV2Error.conflictingChangeOnService:
                // If we failed because a conflicting change has already been
                // committed to the service, we should refresh our local state
                // for the group and try again to apply our changes.

                try await SSKEnvironment.shared.groupV2UpdatesRef.refreshGroup(secretParams: groupV2Params.groupSecretParams)

                (messageBehavior, httpResponse) = try await buildGroupChangeProtoAndTryToUpdateGroupOnService(
                    groupId: groupId,
                    groupV2Params: groupV2Params,
                    changes: changes
                )
            case GroupsV2Error.serviceRequestHitRecoverable400:
                // We likely got the 400 because we submitted a proto with
                // profile key credentials and one of them was expired, possibly
                // due to drift between our local clock and the service. We
                // should try again exactly once, forcing a refresh of all the
                // credentials first.

                (messageBehavior, httpResponse) = try await buildGroupChangeProtoAndTryToUpdateGroupOnService(
                    groupId: groupId,
                    groupV2Params: groupV2Params,
                    changes: changes,
                    shouldForceRefreshProfileKeyCredentials: true,
                    forceFailOn400: true
                )
            default:
                throw error
            }
        }

        let changeResponse = try GroupsProtoGroupChangeResponse(serializedData: httpResponse.responseBodyData ?? Data())

        try await handleGroupUpdatedOnService(
            changeResponse: changeResponse,
            messageBehavior: messageBehavior,
            justUploadedAvatars: justUploadedAvatars,
            groupId: groupId,
            groupV2Params: groupV2Params
        )
    }

    /// Construct a group change proto from the given `changes` for the given
    /// `groupId`, and attempt to commit the group change to the service.
    /// - Parameters:
    ///   - shouldForceRefreshProfileKeyCredentials: Whether we should force-refresh PKCs for any new members while building the proto.
    ///   - forceFailOn400: Whether we should force failure when receiving a 400. If `false`, may instead report expired PKCs.
    private func buildGroupChangeProtoAndTryToUpdateGroupOnService(
        groupId: Data,
        groupV2Params: GroupV2Params,
        changes: GroupsV2OutgoingChanges,
        shouldForceRefreshProfileKeyCredentials: Bool = false,
        forceFailOn400: Bool = false
    ) async throws -> (GroupUpdateMessageBehavior, HTTPResponse) {
        let (groupThread, dmToken) = try SSKEnvironment.shared.databaseStorageRef.read { tx in
            guard let groupThread = TSGroupThread.fetch(groupId: groupId, transaction: tx) else {
                throw OWSAssertionError("Thread does not exist.")
            }

            let dmConfigurationStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
            let dmConfiguration = dmConfigurationStore.fetchOrBuildDefault(for: .thread(groupThread), tx: tx)

            return (groupThread, dmConfiguration.asToken)
        }

        guard let groupModel = groupThread.groupModel as? TSGroupModelV2 else {
            throw OWSAssertionError("Invalid group model.")
        }

        let builtGroupChange = try await changes.buildGroupChangeProto(
            currentGroupModel: groupModel,
            currentDisappearingMessageToken: dmToken,
            forceRefreshProfileKeyCredentials: shouldForceRefreshProfileKeyCredentials
        )

        var behavior400: Behavior400 = .fail
        if
            !forceFailOn400,
            builtGroupChange.proto.containsProfileKeyCredentials
        {
            // If the proto we're submitting contains a profile key credential
            // that's expired, we'll get back a generic 400. Consequently, if
            // we're submitting a proto with PKCs, and we get a 400, we should
            // attempt to recover.

            behavior400 = .reportForRecovery
        }

        let requestBuilder: RequestBuilder = { authCredential in
            return try StorageService.buildUpdateGroupRequest(
                groupChangeProto: builtGroupChange.proto,
                groupV2Params: groupV2Params,
                authCredential: authCredential,
                groupInviteLinkPassword: nil
            )
        }

        let response = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: groupId,
            behavior400: behavior400,
            behavior403: .fetchGroupUpdates,
            behavior404: .fail
        )

        return (builtGroupChange.groupUpdateMessageBehavior, response)
    }

    private func handleGroupUpdatedOnService(
        changeResponse: GroupsProtoGroupChangeResponse,
        messageBehavior: GroupUpdateMessageBehavior,
        justUploadedAvatars: GroupAvatarStateMap,
        groupId: Data,
        groupV2Params: GroupV2Params
    ) async throws {
        guard let changeProto = changeResponse.groupChange else {
            throw OWSAssertionError("Missing groupChange.")
        }
        guard changeProto.changeEpoch <= GroupManager.changeProtoEpoch else {
            throw OWSAssertionError("Invalid embedded change proto epoch: \(changeProto.changeEpoch).")
        }
        let changeActionsProto = try GroupsV2Protos.parseGroupChangeProto(changeProto, verificationOperation: .alreadyTrusted)

        let groupSendEndorsementsResponse = try changeResponse.groupSendEndorsementsResponse.map {
            return try GroupSendEndorsementsResponse(contents: [UInt8]($0))
        }

        try await updateGroupWithChangeActions(
            groupId: groupId,
            spamReportingMetadata: .learnedByLocallyInitatedRefresh,
            changeActionsProto: changeActionsProto,
            groupSendEndorsementsResponse: groupSendEndorsementsResponse,
            justUploadedAvatars: justUploadedAvatars,
            groupV2Params: groupV2Params
        )

        switch messageBehavior {
        case .sendNothing:
            return
        case .sendUpdateToOtherGroupMembers:
            break
        }

        let groupId = try groupV2Params.groupPublicParams.getGroupIdentifier()
        let groupChangeProtoData = try changeProto.serializedData()

        await GroupManager.sendGroupUpdateMessage(
            groupId: groupId,
            groupChangeProtoData: groupChangeProtoData
        )

        await sendGroupUpdateMessageToRemovedUsers(
            changeActionsProto: changeActionsProto,
            groupChangeProtoData: groupChangeProtoData,
            groupV2Params: groupV2Params
        )
    }

    private func membersRemovedByChangeActions(
        groupChangeActionsProto: GroupsProtoGroupChangeActions,
        groupV2Params: GroupV2Params
    ) -> [ServiceId] {
        var serviceIds = [ServiceId]()
        for action in groupChangeActionsProto.deleteMembers {
            guard let userId = action.deletedUserID else {
                owsFailDebug("Missing userID.")
                continue
            }
            do {
                serviceIds.append(try groupV2Params.aci(for: userId))
            } catch {
                owsFailDebug("Error: \(error)")
            }
        }
        for action in groupChangeActionsProto.deletePendingMembers {
            guard let userId = action.deletedUserID else {
                owsFailDebug("Missing userID.")
                continue
            }
            do {
                serviceIds.append(try groupV2Params.serviceId(for: userId))
            } catch {
                owsFailDebug("Error: \(error)")
            }
        }
        for action in groupChangeActionsProto.deleteRequestingMembers {
            guard let userId = action.deletedUserID else {
                owsFailDebug("Missing userID.")
                continue
            }
            do {
                serviceIds.append(try groupV2Params.aci(for: userId))
            } catch {
                owsFailDebug("Error: \(error)")
            }
        }
        return serviceIds
    }

    private func sendGroupUpdateMessageToRemovedUsers(
        changeActionsProto: GroupsProtoGroupChangeActions,
        groupChangeProtoData: Data,
        groupV2Params: GroupV2Params
    ) async {
        let serviceIds = membersRemovedByChangeActions(
            groupChangeActionsProto: changeActionsProto,
            groupV2Params: groupV2Params
        )

        if serviceIds.isEmpty {
            return
        }

        let plaintextData: Data
        let timestamp = MessageTimestampGenerator.sharedInstance.generateTimestamp()
        do {
            let groupV2Context = try GroupsV2Protos.buildGroupContextProto(
                masterKey: groupV2Params.groupSecretParams.getMasterKey(),
                revision: changeActionsProto.revision,
                groupChangeProtoData: groupChangeProtoData
            )

            let dataBuilder = SSKProtoDataMessage.builder()
            dataBuilder.setGroupV2(groupV2Context)
            dataBuilder.setRequiredProtocolVersion(UInt32(SSKProtoDataMessageProtocolVersion.initial.rawValue))
            dataBuilder.setTimestamp(timestamp)

            let dataProto = try dataBuilder.build()
            let contentBuilder = SSKProtoContent.builder()
            contentBuilder.setDataMessage(dataProto)
            plaintextData = try contentBuilder.buildSerializedData()
        } catch {
            owsFailDebug("Error: \(error)")
            return
        }

        await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
            for serviceId in serviceIds {
                let address = SignalServiceAddress(serviceId)
                let contactThread = TSContactThread.getOrCreateThread(withContactAddress: address, transaction: tx)
                let message = OWSStaticOutgoingMessage(thread: contactThread, timestamp: timestamp, plaintextData: plaintextData, transaction: tx)
                let preparedMessage = PreparedOutgoingMessage.preprepared(
                    transientMessageWithoutAttachments: message
                )
                SSKEnvironment.shared.messageSenderJobQueueRef.add(message: preparedMessage, transaction: tx)
            }
        }
    }

    // This method can process protos from another client, so there's a possibility
    // the serverGuid may be present and can be passed along to record with the update.
    public func updateGroupWithChangeActions(
        groupId: Data,
        spamReportingMetadata: GroupUpdateSpamReportingMetadata,
        changeActionsProto: GroupsProtoGroupChangeActions,
        groupSecretParams: GroupSecretParams
    ) async throws {
        let groupV2Params = try GroupV2Params(groupSecretParams: groupSecretParams)
        try await _updateGroupWithChangeActions(
            groupId: groupId,
            spamReportingMetadata: spamReportingMetadata,
            changeActionsProto: changeActionsProto,
            groupSendEndorsementsResponse: nil,
            justUploadedAvatars: nil,
            groupV2Params: groupV2Params
        )
    }

    private func updateGroupWithChangeActions(
        groupId: Data,
        spamReportingMetadata: GroupUpdateSpamReportingMetadata,
        changeActionsProto: GroupsProtoGroupChangeActions,
        groupSendEndorsementsResponse: GroupSendEndorsementsResponse?,
        justUploadedAvatars: GroupAvatarStateMap?,
        groupV2Params: GroupV2Params
    ) async throws {
        try await _updateGroupWithChangeActions(
            groupId: groupId,
            spamReportingMetadata: spamReportingMetadata,
            changeActionsProto: changeActionsProto,
            groupSendEndorsementsResponse: groupSendEndorsementsResponse,
            justUploadedAvatars: justUploadedAvatars,
            groupV2Params: groupV2Params
        )
    }

    private func _updateGroupWithChangeActions(
        groupId: Data,
        spamReportingMetadata: GroupUpdateSpamReportingMetadata,
        changeActionsProto: GroupsProtoGroupChangeActions,
        groupSendEndorsementsResponse: GroupSendEndorsementsResponse?,
        justUploadedAvatars: GroupAvatarStateMap?,
        groupV2Params: GroupV2Params
    ) async throws {
        let downloadedAvatars = try await fetchAllAvatarData(
            changeActionsProtos: [changeActionsProto],
            justUploadedAvatars: justUploadedAvatars,
            groupV2Params: groupV2Params
        )
        try await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
            _ = try SSKEnvironment.shared.groupV2UpdatesRef.updateGroupWithChangeActions(
                groupId: groupId,
                spamReportingMetadata: spamReportingMetadata,
                changeActionsProto: changeActionsProto,
                groupSendEndorsementsResponse: groupSendEndorsementsResponse,
                downloadedAvatars: downloadedAvatars,
                transaction: tx
            )
        }
    }

    // MARK: - Upload Avatar

    public func uploadGroupAvatar(
        avatarData: Data,
        groupSecretParams: GroupSecretParams
    ) async throws -> String {
        let groupV2Params = try GroupV2Params(groupSecretParams: groupSecretParams)
        return try await uploadGroupAvatar(avatarData: avatarData, groupV2Params: groupV2Params)
    }

    private func uploadGroupAvatar(
        avatarData: Data,
        groupV2Params: GroupV2Params
    ) async throws -> String {

        let requestBuilder: RequestBuilder = { (authCredential) in
            try StorageService.buildGroupAvatarUploadFormRequest(
                groupV2Params: groupV2Params,
                authCredential: authCredential
            )
        }

        let groupId = try groupV2Params.groupPublicParams.getGroupIdentifier().serialize().asData
        let response = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: groupId,
            behavior400: .fail,
            behavior403: .fetchGroupUpdates,
            behavior404: .fail
        )

        guard let protoData = response.responseBodyData else {
            throw OWSAssertionError("Invalid responseObject.")
        }
        let avatarUploadAttributes = try GroupsProtoAvatarUploadAttributes(serializedData: protoData)
        let uploadForm = try Upload.CDN0.Form.parse(proto: avatarUploadAttributes)
        let encryptedData = try groupV2Params.encryptGroupAvatar(avatarData)
        return try await Upload.CDN0.upload(data: encryptedData, uploadForm: uploadForm)
    }

    // MARK: - Fetch Current Group State

    public func fetchLatestSnapshot(
        secretParams: GroupSecretParams,
        justUploadedAvatars: GroupAvatarStateMap?
    ) async throws -> GroupV2SnapshotResponse {
        let groupV2Params = try GroupV2Params(groupSecretParams: secretParams)
        return try await fetchLatestSnapshot(groupV2Params: groupV2Params, justUploadedAvatars: justUploadedAvatars)
    }

    private func fetchLatestSnapshot(
        groupV2Params: GroupV2Params,
        justUploadedAvatars: GroupAvatarStateMap?
    ) async throws -> GroupV2SnapshotResponse {
        let requestBuilder: RequestBuilder = { (authCredential) in
            try StorageService.buildFetchCurrentGroupV2SnapshotRequest(
                groupV2Params: groupV2Params,
                authCredential: authCredential
            )
        }

        let groupId = try groupV2Params.groupPublicParams.getGroupIdentifier().serialize().asData
        let response = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: groupId,
            behavior400: .fail,
            behavior403: .removeFromGroup,
            behavior404: .groupDoesNotExistOnService
        )

        let groupResponseProto = try GroupsProtoGroupResponse(serializedData: response.responseBodyData ?? Data())

        let downloadedAvatars = try await fetchAllAvatarData(
            groupProtos: [groupResponseProto.group].compacted(),
            justUploadedAvatars: justUploadedAvatars,
            groupV2Params: groupV2Params
        )

        return try GroupsV2Protos.parse(
            groupResponseProto: groupResponseProto,
            downloadedAvatars: downloadedAvatars,
            groupV2Params: groupV2Params
        )
    }

    // MARK: - Fetch Group Change Actions

    /// Fetches some group changes (and a snapshot, if needed).
    public func fetchSomeGroupChangeActions(
        secretParams: GroupSecretParams,
        source: GroupChangeActionFetchSource
    ) async throws -> GroupChangesResponse {
        let groupV2Params = try GroupV2Params(groupSecretParams: secretParams)
        let groupId = try groupV2Params.groupPublicParams.getGroupIdentifier().serialize().asData

        let groupModel: TSGroupModelV2?
        let gseExpiration: UInt64

        let databaseStorage = SSKEnvironment.shared.databaseStorageRef
        (groupModel, gseExpiration) = databaseStorage.read { tx in
            let groupThread = TSGroupThread.fetch(groupId: groupId, transaction: tx)
            let groupThreadId = groupThread?.sqliteRowId!
            let endorsementRecord = groupThreadId.flatMap({ try? groupSendEndorsementStore.fetchCombinedEndorsement(groupThreadId: $0, tx: tx) })
            return (
                groupThread?.groupModel as? TSGroupModelV2,
                endorsementRecord?.expirationTimestamp ?? 0
            )
        }

        // If we're fetching because we're processing messages, we can stop as soon
        // as we have a new enough revision. (This can happen due to race
        // conditions receiving messages & refreshing groups, though it generally
        // won't happen because the message processing code only calls this if it
        // believes the revision is too old.)
        if
            let groupModel,
            case .groupMessage(let upThroughRevision) = source,
            groupModel.revision >= upThroughRevision
        {
            // This is fine even if we're a requesting member b/c revision must
            // increment for anything meaningful to happen.
            return GroupChangesResponse(groupChanges: [], shouldFetchMore: false)
        }

        let upThroughRevision: UInt32?
        switch source {
        case .groupMessage(let revision):
            upThroughRevision = revision
        case .other:
            upThroughRevision = nil
        }

        // We can process a change action to move from revision N to revision N + 1
        // UNLESS we have a placeholder group. In that case, we don't actually have
        // revision N -- we have an incomplete copy of revision N that must be made
        // whole before we can apply a delta to it.

        // If we're currently a full member, fetch the next batch.
        if let groupModel, groupModel.groupMembership.isLocalUserFullMember {
            // We're being told about a group we are aware of and are already a member
            // of. In this case, we can figure out which revision we want to start with
            // from local data.
            let startingAtRevision: UInt32
            let includeFirstState: Bool
            switch source {
            case .groupMessage:
                startingAtRevision = groupModel.revision + 1
                includeFirstState = false
            case .other:
                startingAtRevision = groupModel.revision
                includeFirstState = true
            }
            do {
                return try await _fetchSomeGroupChangeActions(
                    secretParams: secretParams,
                    startingAtRevision: startingAtRevision,
                    upThroughRevision: upThroughRevision,
                    includeFirstState: includeFirstState,
                    gseExpiration: gseExpiration
                )
            } catch GroupsV2Error.localUserNotInGroup {
                // If we can't fetch starting at the next version, we might have been
                // removed and re-added, so we should figure out if we're back in the group
                // at a later revision.
            }
        }

        // Otherwise, we want to figure out where we got permission to start
        // fetching changes, update to that via a snapshot, and then apply
        // everything that follows.
        let startingAtRevision = try await getRevisionLocalUserWasAddedToGroup(secretParams: secretParams)

        return try await _fetchSomeGroupChangeActions(
            secretParams: secretParams,
            startingAtRevision: startingAtRevision,
            upThroughRevision: upThroughRevision,
            includeFirstState: true,
            gseExpiration: gseExpiration
        )
    }

    private func _fetchSomeGroupChangeActions(
        secretParams: GroupSecretParams,
        startingAtRevision: UInt32,
        upThroughRevision: UInt32?,
        includeFirstState: Bool,
        gseExpiration: UInt64
    ) async throws -> GroupChangesResponse {
        let groupId = try secretParams.getPublicParams().getGroupIdentifier().serialize().asData

        let limit: UInt32? = upThroughRevision.map({ (startingAtRevision <= $0) ? ($0 - startingAtRevision + 1) : 1 })

        let response = try await performServiceRequest(
            requestBuilder: { authCredential in
                return try StorageService.buildFetchGroupChangeActionsRequest(
                    secretParams: secretParams,
                    fromRevision: startingAtRevision,
                    limit: limit,
                    includeFirstState: includeFirstState,
                    gseExpiration: gseExpiration,
                    authCredential: authCredential
                )
            },
            groupId: groupId,
            behavior400: .fail,
            behavior403: .ignore, // actually means "throw error"
            behavior404: .fail
        )
        guard let groupChangesProtoData = response.responseBodyData else {
            throw OWSAssertionError("Invalid responseObject.")
        }
        let earlyEnd: UInt32?
        if response.responseStatusCode == 206 {
            let groupRangeHeader = response.headers["content-range"]
            earlyEnd = try Self.parseEarlyEnd(fromGroupRangeHeader: groupRangeHeader)
        } else {
            earlyEnd = nil
        }
        let groupChangesProto = try GroupsProtoGroupChanges(serializedData: groupChangesProtoData)

        let parsedChanges = try GroupsV2Protos.parseChangesFromService(groupChangesProto: groupChangesProto)
        let downloadedAvatars = try await fetchAllAvatarData(
            groupProtos: parsedChanges.compactMap(\.groupProto),
            changeActionsProtos: parsedChanges.compactMap(\.changeActionsProto),
            groupV2Params: try GroupV2Params(groupSecretParams: secretParams)
        )
        let changes = try parsedChanges.map { parsedChange in
            return GroupV2Change(
                snapshot: try parsedChange.groupProto.map {
                    return try GroupsV2Protos.parse(
                        groupProto: $0,
                        fetchedAlongsideChangeActionsProto: parsedChange.changeActionsProto,
                        downloadedAvatars: downloadedAvatars,
                        groupV2Params: try GroupV2Params(groupSecretParams: secretParams)
                    )
                },
                changeActionsProto: parsedChange.changeActionsProto,
                downloadedAvatars: downloadedAvatars
            )
        }

        let groupSendEndorsementsResponse = try groupChangesProto.groupSendEndorsementsResponse.map {
            return try GroupSendEndorsementsResponse(contents: [UInt8]($0))
        }

        return GroupChangesResponse(
            groupChanges: changes,
            groupSendEndorsementsResponse: groupSendEndorsementsResponse,
            shouldFetchMore: earlyEnd != nil && (upThroughRevision == nil || upThroughRevision! > earlyEnd!)
        )
    }

    private static func parseEarlyEnd(fromGroupRangeHeader header: String?) throws -> UInt32 {
        guard let header = header else {
            throw OWSAssertionError("Missing Content-Range for group update request with 206 response")
        }

        let pattern = try! NSRegularExpression(pattern: #"^versions (\d+)-(\d+)/(\d+)$"#)
        guard let match = pattern.firstMatch(in: header, range: header.entireRange) else {
            throw OWSAssertionError("Couldn't parse Content-Range header: \(header)")
        }

        guard let earlyEndRange = Range(match.range(at: 1), in: header) else {
            throw OWSAssertionError("Could not translate NSRange to Range<String.Index>")
        }

        guard let earlyEndValue = UInt32(header[earlyEndRange]) else {
            throw OWSAssertionError("Invalid early-end in Content-Range for group update request: \(header)")
        }

        return earlyEndValue
    }

    private func getRevisionLocalUserWasAddedToGroup(secretParams: GroupSecretParams) async throws -> UInt32 {
        let groupId = try secretParams.getPublicParams().getGroupIdentifier().serialize().asData
        let getJoinedAtRevisionRequestBuilder: RequestBuilder = { authCredential in
            try StorageService.buildGetJoinedAtRevisionRequest(
                secretParams: secretParams,
                authCredential: authCredential
            )
        }

        // We might get a 403 if we are not a member of the group, e.g. if we are
        // joining via invite link. Passing .ignore means we won't retry and will
        // allow the "not a member" error to be thrown and propagated upwards.
        let response = try await performServiceRequest(
            requestBuilder: getJoinedAtRevisionRequestBuilder,
            groupId: groupId,
            behavior400: .fail,
            behavior403: .ignore,
            behavior404: .fail
        )

        guard let memberData = response.responseBodyData else {
            throw OWSAssertionError("Response missing body data")
        }

        let memberProto = try GroupsProtoMember(serializedData: memberData)

        return memberProto.joinedAtRevision
    }

    // MARK: - Avatar Downloads

    // Before we can apply snapshots/changes from the service, we
    // need to download all avatars they use.  We can skip downloads
    // in a couple of cases:
    //
    // * We just created the group.
    // * We just updated the group and we're applying those changes.
    private func fetchAllAvatarData(
        groupProtos: [GroupsProtoGroup] = [],
        changeActionsProtos: [GroupsProtoGroupChangeActions] = [],
        justUploadedAvatars: GroupAvatarStateMap? = nil,
        groupV2Params: GroupV2Params
    ) async throws -> GroupAvatarStateMap {

        var downloadedAvatars = GroupAvatarStateMap()

        // Creating or updating a group is a multi-step process
        // that can involve uploading an avatar, updating the
        // group on the service, then updating the local database.
        // We can skip downloading an avatar that we just uploaded
        // using justUploadedAvatars.
        if let justUploadedAvatars = justUploadedAvatars {
            downloadedAvatars.merge(justUploadedAvatars)
        }

        let groupId = try groupV2Params.groupPublicParams.getGroupIdentifier().serialize().asData

        // First step - try to skip downloading the current group avatar.
        if
            let groupThread = (SSKEnvironment.shared.databaseStorageRef.read { transaction in
                return TSGroupThread.fetch(groupId: groupId, transaction: transaction)
            }),
            let groupModel = groupThread.groupModel as? TSGroupModelV2
        {
            // Try to add avatar from group model, if any.
            downloadedAvatars.merge(GroupAvatarStateMap.from(groupModel: groupModel))
        }

        let protoAvatarUrlPaths = GroupsV2Protos.collectAvatarUrlPaths(
            groupProtos: groupProtos,
            changeActionsProtos: changeActionsProtos
        )

        return try await fetchAvatarDataIfNotBlurred(
            avatarUrlPaths: protoAvatarUrlPaths,
            knownAvatarStates: downloadedAvatars,
            groupV2Params: groupV2Params
        )
    }

    private func fetchAvatarDataIfNotBlurred(
        avatarUrlPaths: [String],
        knownAvatarStates: GroupAvatarStateMap,
        groupV2Params: GroupV2Params
    ) async throws -> GroupAvatarStateMap {
        let shouldBlurAvatars = try DependenciesBridge.shared.db.read { tx in
            let groupThread = TSGroupThread.fetch(
                forGroupId: try groupV2Params.groupPublicParams.getGroupIdentifier(),
                tx: tx
            )

            guard let groupThread else {
                return true
            }

            return SSKEnvironment.shared.contactManagerImplRef.shouldBlockAvatarDownload(groupThread: groupThread, tx: tx)
        }

        var downloadedAvatars = knownAvatarStates

        if shouldBlurAvatars {
            let undownloadedAvatarUrlPaths = Set(avatarUrlPaths).subtracting(downloadedAvatars.avatarUrlPaths)
            undownloadedAvatarUrlPaths.forEach { urlPath in
                downloadedAvatars.set(avatarDataState: .lowTrustDownloadWasBlocked, avatarUrlPath: urlPath)
            }
            return downloadedAvatars
        }

        downloadedAvatars.removeBlockedAvatars()
        let undownloadedAvatarUrlPaths = Set(avatarUrlPaths).subtracting(downloadedAvatars.avatarUrlPaths)

        try await withThrowingTaskGroup(of: (String, Data).self) { taskGroup in
            // We need to "populate" any group changes that have a
            // avatar with the avatar data.
            for avatarUrlPath in undownloadedAvatarUrlPaths {
                taskGroup.addTask {
                    var avatarData: Data
                    do {
                        avatarData = try await self.fetchAvatarData(
                            avatarUrlPath: avatarUrlPath,
                            groupV2Params: groupV2Params
                        )
                    } catch OWSURLSessionError.responseTooLarge {
                        owsFailDebug("Had response-too-large fetching group avatar!")
                        avatarData = Data()
                    } catch where error.httpStatusCode == 404 {
                        // Fulfill with empty data if service returns 404 status code.
                        // We don't want the group to be left in an unrecoverable state
                        // if the avatar is missing from the CDN.
                        owsFailDebug("Had 404 fetching group avatar!")
                        avatarData = Data()
                    }
                    if !avatarData.isEmpty {
                        avatarData = (try? groupV2Params.decryptGroupAvatar(avatarData)) ?? Data()
                    }
                    return (avatarUrlPath, avatarData)
                }
            }

            while let (avatarUrlPath, avatarData) = try await taskGroup.next() {
                let avatarDataState: TSGroupModel.AvatarDataState

                if
                    !avatarData.isEmpty,
                    TSGroupModel.isValidGroupAvatarData(avatarData)
                {
                    avatarDataState = .available(avatarData)
                } else {
                    avatarDataState = .failedToFetchFromCDN
                }

                downloadedAvatars.set(
                    avatarDataState: avatarDataState,
                    avatarUrlPath: avatarUrlPath
                )
            }
        }

        return downloadedAvatars
    }

    let avatarDownloadQueue = ConcurrentTaskQueue(concurrentLimit: 3)

    private func fetchAvatarData(
        avatarUrlPath: String,
        groupV2Params: GroupV2Params
    ) async throws -> Data {
        return try await avatarDownloadQueue.run {
            // We throw away decrypted avatars larger than `kMaxEncryptedAvatarSize`.
            return try await GroupsV2AvatarDownloadOperation.run(
                urlPath: avatarUrlPath,
                maxDownloadSize: kMaxEncryptedAvatarSize
            )
        }
    }

    // MARK: - Generic Group Change

    public func updateGroupV2(
        groupId: Data,
        groupSecretParams: GroupSecretParams,
        changesBlock: (GroupsV2OutgoingChanges) -> Void
    ) async throws {
        let changes = GroupsV2OutgoingChangesImpl(
            groupId: groupId,
            groupSecretParams: groupSecretParams
        )
        changesBlock(changes)
        try await updateExistingGroupOnService(changes: changes)
    }

    // MARK: - Rotate Profile Key

    private let profileKeyUpdater: GroupsV2ProfileKeyUpdater

    public func scheduleAllGroupsV2ForProfileKeyUpdate(transaction: DBWriteTransaction) {
        profileKeyUpdater.scheduleAllGroupsV2ForProfileKeyUpdate(transaction: transaction)
    }

    public func processProfileKeyUpdates() {
        profileKeyUpdater.processProfileKeyUpdates()
    }

    public func updateLocalProfileKeyInGroup(groupId: Data, transaction: DBWriteTransaction) {
        profileKeyUpdater.updateLocalProfileKeyInGroup(groupId: groupId, transaction: transaction)
    }

    // MARK: - Perform Request

    private typealias RequestBuilder = (AuthCredentialWithPni) async throws -> GroupsV2Request

    /// Represents how we should respond to 400 status codes.
    enum Behavior400 {
        case fail
        case reportForRecovery
    }

    /// Represents how we should respond to 403 status codes.
    private enum Behavior403 {
        case fail
        case removeFromGroup
        case fetchGroupUpdates
        case ignore
        case reportInvalidOrBlockedGroupLink
        case localUserIsNotARequestingMember
    }

    /// Represents how we should respond to 404 status codes.
    private enum Behavior404 {
        case fail
        case groupDoesNotExistOnService
    }

    /// Make a request to the GV2 service, produced by the given
    /// `requestBuilder`. Specifies how to respond if the request results in
    /// certain errors.
    private func performServiceRequest(
        requestBuilder: RequestBuilder,
        groupId: Data?,
        behavior400: Behavior400,
        behavior403: Behavior403,
        behavior404: Behavior404
    ) async throws -> HTTPResponse {
        guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction else {
            throw OWSAssertionError("Missing localIdentifiers.")
        }

        return try await Retry.performWithBackoff(
            maxAttempts: 3,
            isRetryable: { $0.isNetworkFailureOrTimeout || $0.httpStatusCode == 401 },
            block: {
                let authCredential = try await authCredentialManager.fetchGroupAuthCredential(localIdentifiers: localIdentifiers)
                let request = try await requestBuilder(authCredential)
                do {
                    return try await performServiceRequestAttempt(request: request)
                } catch {
                    try await self.tryRecoveryFromServiceRequestFailure(
                        error: error,
                        groupId: groupId,
                        behavior400: behavior400,
                        behavior403: behavior403,
                        behavior404: behavior404
                    )
                }
            }
        )
    }

    /// Upon error from performing a service request, attempt to recover based
    /// on the error and our 4XX behaviors.
    private func tryRecoveryFromServiceRequestFailure(
        error: Error,
        groupId: Data?,
        behavior400: Behavior400,
        behavior403: Behavior403,
        behavior404: Behavior404
    ) async throws -> Never {
        // Fall through to retry if retry-able,
        // otherwise reject immediately.
        if let statusCode = error.httpStatusCode {
            switch statusCode {
            case 400:
                switch behavior400 {
                case .fail:
                    owsFailDebug("Unexpected 400.")
                case .reportForRecovery:
                    throw GroupsV2Error.serviceRequestHitRecoverable400
                }

                throw error
            case 401:
                // Retry auth errors after retrieving new temporal credentials.
                await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
                    self.authCredentialStore.removeAllGroupAuthCredentials(tx: tx)
                }
                throw error
            case 403:
                guard
                    let responseHeaders = error.httpResponseHeaders,
                    responseHeaders.hasValueForHeader("x-signal-timestamp")
                else {
                    // The cloud infrastructure that sits in front of the Groups
                    // server is known to, in some situations, short-circuit
                    // requests with a 403 before they make it to a Signal
                    // server. That's a problem, since we might take destructive
                    // action locally in response to a 403. 403s from a Signal
                    // server will always contain this header; if we find one
                    // without, we can't trust it and should bail.
                    throw OWSAssertionError("Dropping 403 response without x-signal-timestamp header! \(error)")
                }

                // 403 indicates that we are no longer in the group for
                // many (but not all) group v2 service requests.
                switch behavior403 {
                case .fail:
                    // We should never receive 403 when creating groups.
                    owsFailDebug("Unexpected 403.")
                case .ignore:
                    // We may get a 403 when fetching change actions if
                    // they are not yet a member - for example, if they are
                    // joining via an invite link.
                    owsAssertDebug(groupId != nil, "Expecting a groupId for this path")
                case .removeFromGroup:
                    guard let groupId = groupId else {
                        owsFailDebug("GroupId must be set to remove from group")
                        break
                    }
                    // If we receive 403 when trying to fetch group state, we have left the
                    // group, been removed from the group, or had our invite revoked, and we
                    // should make sure group state in the database reflects that.
                    await GroupManager.handleNotInGroup(groupId: groupId)

                case .fetchGroupUpdates:
                    guard let groupId = groupId else {
                        owsFailDebug("GroupId must be set to fetch group updates")
                        break
                    }
                    // Service returns 403 if client tries to perform an
                    // update for which it is not authorized (e.g. add a
                    // new member if membership access is admin-only).
                    // The local client can't assume that 403 means they
                    // are not in the group. Therefore we "update group
                    // to latest" to check for and handle that case (see
                    // previous case).
                    self.tryToUpdateGroupToLatest(groupId: groupId)

                case .reportInvalidOrBlockedGroupLink:
                    owsAssertDebug(groupId == nil, "groupId should not be set in this code path.")

                    if error.httpResponseHeaders?.containsBan == true {
                        throw GroupsV2Error.localUserBlockedFromJoining
                    } else {
                        throw GroupsV2Error.expiredGroupInviteLink
                    }

                case .localUserIsNotARequestingMember:
                    owsAssertDebug(groupId == nil, "groupId should not be set in this code path.")
                    throw GroupsV2Error.localUserIsNotARequestingMember
                }

                throw GroupsV2Error.localUserNotInGroup
            case 404:
                // 404 indicates that the group does not exist on the
                // service for some (but not all) group v2 service requests.

                switch behavior404 {
                case .fail:
                    throw error
                case .groupDoesNotExistOnService:
                    Logger.warn("Error: \(error)")
                    throw GroupsV2Error.groupDoesNotExistOnService
                }
            case 409:
                // Group update conflict. The caller may be able to recover by
                // retrying, using the change set and the most recent state
                // from the service.
                throw GroupsV2Error.conflictingChangeOnService
            default:
                // Unexpected status code.
                throw error
            }
        } else {
            // Unexpected error.
            throw error
        }
    }

    private func performServiceRequestAttempt(request: GroupsV2Request) async throws -> HTTPResponse {

        let urlSession = self.urlSession

        let requestDescription = "G2 \(request.method) \(request.urlString)"
        Logger.info("Sending… -> \(requestDescription)")

        do {
            let response = try await urlSession.performRequest(
                request.urlString,
                method: request.method,
                headers: request.headers,
                body: request.bodyData
            )

            let statusCode = response.responseStatusCode
            let hasValidStatusCode = [200, 206].contains(statusCode)
            guard hasValidStatusCode else {
                throw OWSAssertionError("Invalid status code: \(statusCode)")
            }

            // NOTE: responseObject may be nil; not all group v2 responses have bodies.
            Logger.info("HTTP \(statusCode) <- \(requestDescription)")

            return response
        } catch {
            if let statusCode = error.httpStatusCode {
                Logger.warn("HTTP \(statusCode) <- \(requestDescription)")
            } else {
                Logger.warn("Failure. <- \(requestDescription): \(error)")
            }

            if error.isNetworkFailureOrTimeout {
                throw error
            }

            // These status codes will be handled by performServiceRequest.
            if let statusCode = error.httpStatusCode, [400, 401, 403, 404, 409].contains(statusCode) {
                throw error
            }

            owsFailDebug("Couldn't send request.")
            throw error
        }
    }

    private func tryToUpdateGroupToLatest(groupId: Data) {
        guard let groupThread = (SSKEnvironment.shared.databaseStorageRef.read { transaction in
            TSGroupThread.fetch(groupId: groupId, transaction: transaction)
        }) else {
            owsFailDebug("Missing group thread.")
            return
        }
        SSKEnvironment.shared.groupV2UpdatesRef.refreshGroupUpThroughCurrentRevision(groupThread: groupThread, throttle: true)
    }

    // MARK: - GSEs

    public func handleGroupSendEndorsementsResponse(
        _ groupSendEndorsementsResponse: GroupSendEndorsementsResponse,
        groupThreadId: Int64,
        secretParams: GroupSecretParams,
        membership: GroupMembership,
        localAci: Aci,
        tx: DBWriteTransaction
    ) {
        do {
            let fullMembers = membership.fullMembers.compactMap(\.serviceId)
            let receivedEndorsements = try groupSendEndorsementsResponse.receive(
                groupMembers: fullMembers,
                localUser: localAci,
                groupParams: secretParams,
                serverParams: GroupsV2Protos.serverPublicParams()
            )
            let combinedEndorsement = receivedEndorsements.combinedEndorsement
            var individualEndorsements = [(ServiceId, GroupSendEndorsement)]()
            for (serviceId, individualEndorsement) in zip(fullMembers, receivedEndorsements.endorsements) {
                if serviceId == localAci {
                    // Don't save our own endorsement. We should never use it.
                    continue
                }
                individualEndorsements.append((serviceId, individualEndorsement))
            }
            let groupId = try secretParams.getPublicParams().getGroupIdentifier()
            Logger.info("Received GSEs that expire at \(groupSendEndorsementsResponse.expiration) for \(groupId)")
            let recipientFetcher = DependenciesBridge.shared.recipientFetcher
            groupSendEndorsementStore.saveEndorsements(
                groupThreadId: groupThreadId,
                expiration: groupSendEndorsementsResponse.expiration,
                combinedEndorsement: combinedEndorsement,
                individualEndorsements: individualEndorsements.map { serviceId, endorsement in
                    return (recipientFetcher.fetchOrCreate(serviceId: serviceId, tx: tx).id!, endorsement)
                },
                tx: tx
            )
        } catch {
            owsFailDebug("Couldn't receive GSEs: \(error)")
        }
    }

    // MARK: - ProfileKeyCredentials

    /// Fetches and returnes the profile key credential for each passed ACI. If
    /// any are missing, returns an error.
    public func loadProfileKeyCredentials(
        for acis: [Aci],
        forceRefresh: Bool
    ) async throws -> ProfileKeyCredentialMap {
        try await tryToFetchProfileKeyCredentials(
            for: acis,
            ignoreMissingProfiles: false,
            forceRefresh: forceRefresh
        )

        let acis = Set(acis)

        let credentialMap = self.loadPresentProfileKeyCredentials(for: acis)

        guard acis.symmetricDifference(credentialMap.keys).isEmpty else {
            throw OWSAssertionError("Missing requested keys from credential map!")
        }

        return credentialMap
    }

    /// Makes a best-effort to fetch the profile key credential for each passed
    /// ACI. If a profile exists for the user but the credential cannot be
    /// fetched (e.g., the ACI is not a contact of ours), skips it. Optionally
    /// ignores "missing profile" errors during fetch.
    public func tryToFetchProfileKeyCredentials(
        for acis: [Aci],
        ignoreMissingProfiles: Bool,
        forceRefresh: Bool
    ) async throws {
        let acis = Set(acis)

        let acisToFetch: Set<Aci>
        if forceRefresh {
            acisToFetch = acis
        } else {
            acisToFetch = acis.subtracting(loadPresentProfileKeyCredentials(for: acis).keys)
        }

        let profileFetcher = SSKEnvironment.shared.profileFetcherRef

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            for aciToFetch in acisToFetch {
                taskGroup.addTask {
                    do {
                        _ = try await profileFetcher.fetchProfile(for: aciToFetch)
                    } catch ProfileRequestError.notFound where ignoreMissingProfiles {
                        // this is fine
                    }
                }
            }
            try await taskGroup.waitForAll()
        }
    }

    private func loadPresentProfileKeyCredentials(for acis: Set<Aci>) -> ProfileKeyCredentialMap {
        SSKEnvironment.shared.databaseStorageRef.read { transaction in
            var credentialMap = ProfileKeyCredentialMap()

            for aci in acis {
                do {
                    if let credential = try SSKEnvironment.shared.versionedProfilesRef.validProfileKeyCredential(
                        for: aci,
                        transaction: transaction
                    ) {
                        credentialMap[aci] = credential
                    }
                } catch {
                    owsFailDebug("Error loading profile key credential: \(error)")
                }
            }

            return credentialMap
        }
    }

    public func hasProfileKeyCredential(
        for address: SignalServiceAddress,
        transaction: DBReadTransaction
    ) -> Bool {
        do {
            guard let serviceId = address.serviceId else {
                throw OWSAssertionError("Missing ACI.")
            }
            guard let aci = serviceId as? Aci else {
                return false
            }
            return try SSKEnvironment.shared.versionedProfilesRef.validProfileKeyCredential(
                for: aci,
                transaction: transaction
            ) != nil
        } catch let error {
            owsFailDebug("Error getting profile key credential: \(error)")
            return false
        }
    }

    // MARK: - Restore Groups

    public func isGroupKnownToStorageService(
        groupModel: TSGroupModelV2,
        transaction: DBReadTransaction
    ) -> Bool {
        GroupsV2Impl.isGroupKnownToStorageService(groupModel: groupModel, transaction: transaction)
    }

    public func groupRecordPendingStorageServiceRestore(
        masterKeyData: Data,
        transaction: DBReadTransaction
    ) -> StorageServiceProtoGroupV2Record? {
        GroupsV2Impl.enqueuedGroupRecordForRestore(masterKeyData: masterKeyData, transaction: transaction)
    }

    public func restoreGroupFromStorageServiceIfNecessary(
        groupRecord: StorageServiceProtoGroupV2Record,
        account: AuthedAccount,
        transaction: DBWriteTransaction
    ) {
        GroupsV2Impl.enqueueGroupRestore(groupRecord: groupRecord, account: account, transaction: transaction)
    }

    // MARK: - Group Links

    private let groupInviteLinkPreviewCache = LRUCache<Data, GroupInviteLinkPreview>(maxSize: 5,
                                                                                     shouldEvacuateInBackground: true)

    private func groupInviteLinkPreviewCacheKey(groupSecretParams: GroupSecretParams) -> Data {
        return groupSecretParams.serialize().asData
    }

    public func cachedGroupInviteLinkPreview(groupSecretParams: GroupSecretParams) -> GroupInviteLinkPreview? {
        let cacheKey = groupInviteLinkPreviewCacheKey(groupSecretParams: groupSecretParams)
        return groupInviteLinkPreviewCache.object(forKey: cacheKey)
    }

    // inviteLinkPassword is not necessary if we're already a member or have a pending request.
    public func fetchGroupInviteLinkPreview(
        inviteLinkPassword: Data?,
        groupSecretParams: GroupSecretParams,
        allowCached: Bool
    ) async throws -> GroupInviteLinkPreview {
        let cacheKey = groupInviteLinkPreviewCacheKey(groupSecretParams: groupSecretParams)

        if
            allowCached,
            let groupInviteLinkPreview = groupInviteLinkPreviewCache.object(forKey: cacheKey)
        {
            return groupInviteLinkPreview
        }

        let groupV2Params = try GroupV2Params(groupSecretParams: groupSecretParams)

        let requestBuilder: RequestBuilder = { (authCredential) in
            try StorageService.buildFetchGroupInviteLinkPreviewRequest(
                inviteLinkPassword: inviteLinkPassword,
                groupV2Params: groupV2Params,
                authCredential: authCredential
            )
        }

        do {
            let behavior403: Behavior403 = (
                inviteLinkPassword != nil
                ? .reportInvalidOrBlockedGroupLink
                : .localUserIsNotARequestingMember
            )
            let response = try await performServiceRequest(
                requestBuilder: requestBuilder,
                groupId: nil,
                behavior400: .fail,
                behavior403: behavior403,
                behavior404: .fail
            )
            guard let protoData = response.responseBodyData else {
                throw OWSAssertionError("Invalid responseObject.")
            }
            let groupInviteLinkPreview = try GroupsV2Protos.parseGroupInviteLinkPreview(protoData, groupV2Params: groupV2Params)

            groupInviteLinkPreviewCache.setObject(groupInviteLinkPreview, forKey: cacheKey)

            await updatePlaceholderGroupModelUsingInviteLinkPreview(
                groupSecretParams: groupSecretParams,
                isLocalUserRequestingMember: groupInviteLinkPreview.isLocalUserRequestingMember
            )

            return groupInviteLinkPreview
        } catch {
            if case GroupsV2Error.localUserIsNotARequestingMember = error {
                await self.updatePlaceholderGroupModelUsingInviteLinkPreview(
                    groupSecretParams: groupSecretParams,
                    isLocalUserRequestingMember: false
                )
            }
            throw error
        }
    }

    public func fetchGroupInviteLinkAvatar(
        avatarUrlPath: String,
        groupSecretParams: GroupSecretParams
    ) async throws -> Data {
        let groupV2Params = try GroupV2Params(groupSecretParams: groupSecretParams)
        let downloadedAvatars = try await fetchAvatarDataIfNotBlurred(
            avatarUrlPaths: [avatarUrlPath],
            knownAvatarStates: GroupAvatarStateMap(),
            groupV2Params: groupV2Params
        )

        if let avatarData = downloadedAvatars.avatarDataState(for: avatarUrlPath)!.dataIfPresent {
            return avatarData
        } else {
            throw OWSAssertionError("Unexpectedly missing downloaded avatar data!")
        }
    }

    public func fetchGroupAvatarRestoredFromBackup(
        groupModel: TSGroupModelV2,
        avatarUrlPath: String
    ) async throws -> TSGroupModel.AvatarDataState {
        let groupV2Params = try GroupV2Params(groupSecretParams: groupModel.secretParams())
        let downloadedAvatars = try await fetchAvatarDataIfNotBlurred(
            avatarUrlPaths: [avatarUrlPath],
            knownAvatarStates: GroupAvatarStateMap(),
            groupV2Params: groupV2Params
        )

        return downloadedAvatars.avatarDataState(for: avatarUrlPath)!
    }

    public func joinGroupViaInviteLink(
        groupId: Data,
        groupSecretParams: GroupSecretParams,
        inviteLinkPassword: Data,
        groupInviteLinkPreview: GroupInviteLinkPreview,
        avatarData: Data?
    ) async throws {
        let groupV2Params = try GroupV2Params(groupSecretParams: groupSecretParams)

        // There are many edge cases around joining groups via invite links.
        //
        // * We might have previously been a member or not.
        // * We might previously have requested to join and been denied.
        // * The group might or might not already exist in the database.
        // * We might already be a full member.
        // * We might already have a pending invite (in which case we should
        //   accept that invite rather than request to join).
        // * The invite link may have been rescinded.

        do {
            // Check if...
            //
            // * We're already in the group.
            // * We already have a pending invite. If so, use it.
            //
            // Note: this will typically fail.
            try await joinGroupViaInviteLinkUsingAlternateMeans(
                groupId: groupId,
                inviteLinkPassword: inviteLinkPassword,
                groupV2Params: groupV2Params
            )
        } catch {
            if error.isNetworkFailureOrTimeout {
                throw error
            }
            Logger.warn("Error: \(error)")
            try await self.joinGroupViaInviteLinkUsingPatch(
                groupId: groupId,
                inviteLinkPassword: inviteLinkPassword,
                groupV2Params: groupV2Params,
                groupInviteLinkPreview: groupInviteLinkPreview,
                avatarData: avatarData
            )
        }
    }

    private func joinGroupViaInviteLinkUsingAlternateMeans(
        groupId: Data,
        inviteLinkPassword: Data,
        groupV2Params: GroupV2Params
    ) async throws {

        // First try to fetch latest group state from service.
        // This will fail for users trying to join via group link
        // who are not yet in the group.
        try await SSKEnvironment.shared.groupV2UpdatesRef.refreshGroup(secretParams: groupV2Params.groupSecretParams)

        guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction else {
            throw OWSAssertionError("Missing localAci.")
        }

        let groupThread = SSKEnvironment.shared.databaseStorageRef.read { tx in
            return TSGroupThread.fetch(groupId: groupId, transaction: tx)
        }
        guard let groupModelV2 = groupThread?.groupModel as? TSGroupModelV2 else {
            throw OWSAssertionError("Invalid group model.")
        }
        let groupMembership = groupModelV2.groupMembership
        if groupMembership.isFullMember(localIdentifiers.aci) || groupMembership.isRequestingMember(localIdentifiers.aci) {
            // We're already in the group.
            return
        }
        if groupMembership.isInvitedMember(localIdentifiers.aci) {
            // We're already invited by ACI; try to join by accepting the invite.
            // That will make us a full member; requesting to join via
            // the invite link might make us a requesting member.
            try await GroupManager.localAcceptInviteToGroupV2(groupModel: groupModelV2)
            return
        }
        if let pni = localIdentifiers.pni, groupMembership.isInvitedMember(pni) {
            // We're already invited by PNI; try to join by accepting the invite.
            // That will make us a full member; requesting to join via
            // the invite link might make us a requesting member.
            try await GroupManager.localAcceptInviteToGroupV2(groupModel: groupModelV2)
            return
        }
        throw GroupsV2Error.localUserNotInGroup
    }

    private func joinGroupViaInviteLinkUsingPatch(
        groupId: Data,
        inviteLinkPassword: Data,
        groupV2Params: GroupV2Params,
        groupInviteLinkPreview: GroupInviteLinkPreview,
        avatarData: Data?
    ) async throws {

        let revisionForPlaceholderModel = AtomicOptional<UInt32>(nil, lock: .sharedGlobal)

        let requestBuilder: RequestBuilder = { (authCredential) in
            let groupChangeProto = try await self.buildChangeActionsProtoToJoinGroupLink(
                groupId: groupId,
                inviteLinkPassword: inviteLinkPassword,
                groupV2Params: groupV2Params,
                revisionForPlaceholderModel: revisionForPlaceholderModel
            )
            return try StorageService.buildUpdateGroupRequest(
                groupChangeProto: groupChangeProto,
                groupV2Params: groupV2Params,
                authCredential: authCredential,
                groupInviteLinkPassword: inviteLinkPassword
            )
        }

        do {
            let response = try await performServiceRequest(
                requestBuilder: requestBuilder,
                groupId: groupId,
                behavior400: .fail,
                behavior403: .reportInvalidOrBlockedGroupLink,
                behavior404: .fail
            )

            let changeResponse = try GroupsProtoGroupChangeResponse(serializedData: response.responseBodyData ?? Data())

            guard let changeProto = changeResponse.groupChange else {
                throw OWSAssertionError("Missing groupChange after updating group.")
            }

            // The PATCH request that adds us to the group (as a full or requesting member)
            // only return the "change actions" proto data, but not a full snapshot
            // so we need to separately GET the latest group state and update the database.
            //
            // Download and update database with the group state.
            do {
                try await SSKEnvironment.shared.groupV2UpdatesRef.refreshGroup(
                    secretParams: groupV2Params.groupSecretParams,
                    options: [.didJustAddSelfViaGroupLink]
                )
            } catch {
                throw GroupsV2Error.requestingMemberCantLoadGroupState
            }

            await GroupManager.sendGroupUpdateMessage(
                groupId: try groupV2Params.groupPublicParams.getGroupIdentifier(),
                groupChangeProtoData: try changeProto.serializedData()
            )
        } catch {
            // We create a placeholder in a couple of different scenarios:
            //
            // * We successfully request to join a group via group invite link.
            //   Afterward we do not have access to group state on the service.
            // * The GroupInviteLinkPreview indicates that we are already a
            //   requesting member of the group but the group does not yet exist
            //   in the database.
            var shouldCreatePlaceholder = false
            if case GroupsV2Error.localUserIsAlreadyRequestingMember = error {
                shouldCreatePlaceholder = true
            } else if case GroupsV2Error.requestingMemberCantLoadGroupState = error {
                shouldCreatePlaceholder = true
            }
            guard shouldCreatePlaceholder else {
                throw error
            }

            let groupThread = try await createPlaceholderGroupForJoinRequest(
                groupId: groupId,
                inviteLinkPassword: inviteLinkPassword,
                groupV2Params: groupV2Params,
                groupInviteLinkPreview: groupInviteLinkPreview,
                avatarData: avatarData,
                revisionForPlaceholderModel: revisionForPlaceholderModel
            )

            let isJoinRequestPlaceholder: Bool
            if let groupModel = groupThread.groupModel as? TSGroupModelV2 {
                isJoinRequestPlaceholder = groupModel.isJoinRequestPlaceholder
            } else {
                isJoinRequestPlaceholder = false
            }
            guard !isJoinRequestPlaceholder else {
                // There's no point in sending a group update for a placeholder
                // group, since we don't know who to send it to.
                return
            }

            await GroupManager.sendGroupUpdateMessage(
                groupId: try groupV2Params.groupPublicParams.getGroupIdentifier(),
                groupChangeProtoData: nil
            )
        }
    }

    private func createPlaceholderGroupForJoinRequest(
        groupId: Data,
        inviteLinkPassword: Data,
        groupV2Params: GroupV2Params,
        groupInviteLinkPreview: GroupInviteLinkPreview,
        avatarData: Data?,
        revisionForPlaceholderModel: AtomicOptional<UInt32>
    ) async throws -> TSGroupThread {
        // We might be creating a placeholder for a revision that we just
        // created or for one we learned about from a GroupInviteLinkPreview.
        guard let revision = revisionForPlaceholderModel.get() else {
            throw OWSAssertionError("Missing revisionForPlaceholderModel.")
        }
        return try await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { (transaction) throws -> TSGroupThread in
            guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: transaction) else {
                throw OWSAssertionError("Missing localIdentifiers.")
            }

            if let groupThread = TSGroupThread.fetch(groupId: groupId, transaction: transaction) {
                // The group already existing in the database; make sure
                // that we are a requesting member.
                guard let oldGroupModel = groupThread.groupModel as? TSGroupModelV2 else {
                    throw OWSAssertionError("Invalid groupModel.")
                }
                let oldGroupMembership = oldGroupModel.groupMembership
                if oldGroupModel.revision >= revision && oldGroupMembership.isRequestingMember(localIdentifiers.aci) {
                    // No need to update database, group state is already acceptable.
                    return groupThread
                }
                var builder = oldGroupModel.asBuilder
                builder.isJoinRequestPlaceholder = true
                builder.groupV2Revision = max(revision, oldGroupModel.revision)
                var membershipBuilder = oldGroupMembership.asBuilder
                membershipBuilder.remove(localIdentifiers.aci)
                membershipBuilder.addRequestingMember(localIdentifiers.aci)
                builder.groupMembership = membershipBuilder.build()
                let newGroupModel = try builder.build()

                groupThread.update(with: newGroupModel, transaction: transaction)

                let dmConfigurationStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
                let dmToken = dmConfigurationStore.fetchOrBuildDefault(for: .thread(groupThread), tx: transaction).asToken
                GroupManager.insertGroupUpdateInfoMessage(
                    groupThread: groupThread,
                    oldGroupModel: oldGroupModel,
                    newGroupModel: newGroupModel,
                    oldDisappearingMessageToken: dmToken,
                    newDisappearingMessageToken: dmToken,
                    newlyLearnedPniToAciAssociations: [:],
                    groupUpdateSource: .localUser(originalSource: .aci(localIdentifiers.aci)),
                    localIdentifiers: localIdentifiers,
                    spamReportingMetadata: .createdByLocalAction,
                    transaction: transaction
                )

                return groupThread
            } else {
                // Create a placeholder group.
                var builder = TSGroupModelBuilder()
                builder.groupId = groupId
                builder.name = groupInviteLinkPreview.title
                builder.descriptionText = groupInviteLinkPreview.descriptionText
                builder.groupAccess = GroupAccess(members: GroupAccess.defaultForV2.members,
                                                  attributes: GroupAccess.defaultForV2.attributes,
                                                  addFromInviteLink: groupInviteLinkPreview.addFromInviteLinkAccess)
                builder.groupsVersion = .V2
                builder.groupV2Revision = revision
                builder.groupSecretParamsData = groupV2Params.groupSecretParamsData
                builder.inviteLinkPassword = inviteLinkPassword
                builder.isJoinRequestPlaceholder = true
                builder.avatarUrlPath = groupInviteLinkPreview.avatarUrlPath

                // The "group invite link" UI might not have downloaded
                // the avatar. That's fine; this is just a placeholder
                // model.
                builder.avatarDataState = TSGroupModel.AvatarDataState(avatarData: avatarData)

                var membershipBuilder = GroupMembership.Builder()
                membershipBuilder.addRequestingMember(localIdentifiers.aci)
                builder.groupMembership = membershipBuilder.build()

                let groupModel = try builder.buildAsV2()
                let groupThread = DependenciesBridge.shared.threadStore.createGroupThread(
                    groupModel: groupModel, tx: transaction
                )

                let dmConfigurationStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
                let dmToken = dmConfigurationStore.fetchOrBuildDefault(for: .thread(groupThread), tx: transaction).asToken
                GroupManager.insertGroupUpdateInfoMessageForNewGroup(
                    localIdentifiers: localIdentifiers,
                    spamReportingMetadata: .createdByLocalAction,
                    groupThread: groupThread,
                    groupModel: groupModel,
                    disappearingMessageToken: dmToken,
                    groupUpdateSource: .localUser(originalSource: .aci(localIdentifiers.aci)),
                    transaction: transaction
                )

                return groupThread
            }
        }
    }

    private func buildChangeActionsProtoToJoinGroupLink(
        groupId: Data,
        inviteLinkPassword: Data,
        groupV2Params: GroupV2Params,
        revisionForPlaceholderModel: AtomicOptional<UInt32>
    ) async throws -> GroupsProtoGroupChangeActions {

        guard let localAci = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction?.aci else {
            throw OWSAssertionError("Missing localAci.")
        }

        // We re-fetch the GroupInviteLinkPreview with every attempt in order to get the latest:
        //
        // * revision
        // * addFromInviteLinkAccess
        // * local user's request status.
        let groupInviteLinkPreview = try await fetchGroupInviteLinkPreview(
            inviteLinkPassword: inviteLinkPassword,
            groupSecretParams: groupV2Params.groupSecretParams,
            allowCached: false
        )

        guard !groupInviteLinkPreview.isLocalUserRequestingMember else {
            // Use the current revision when creating a placeholder group.
            revisionForPlaceholderModel.set(groupInviteLinkPreview.revision)
            throw GroupsV2Error.localUserIsAlreadyRequestingMember
        }

        let profileKeyCredentialMap = try await loadProfileKeyCredentials(for: [localAci], forceRefresh: false)

        guard let localProfileKeyCredential = profileKeyCredentialMap[localAci] else {
            throw OWSAssertionError("Missing localProfileKeyCredential.")
        }

        var actionsBuilder = GroupsProtoGroupChangeActions.builder()

        let oldRevision = groupInviteLinkPreview.revision
        let newRevision = oldRevision + 1
        Logger.verbose("Revision: \(oldRevision) -> \(newRevision)")
        actionsBuilder.setRevision(newRevision)

        // Use the new revision when creating a placeholder group.
        revisionForPlaceholderModel.set(newRevision)

        switch groupInviteLinkPreview.addFromInviteLinkAccess {
        case .any:
            let role = TSGroupMemberRole.`normal`
            var actionBuilder = GroupsProtoGroupChangeActionsAddMemberAction.builder()
            actionBuilder.setAdded(
                try GroupsV2Protos.buildMemberProto(
                    profileKeyCredential: localProfileKeyCredential,
                    role: role.asProtoRole,
                    groupV2Params: groupV2Params
                ))
            actionsBuilder.addAddMembers(actionBuilder.buildInfallibly())
        case .administrator:
            var actionBuilder = GroupsProtoGroupChangeActionsAddRequestingMemberAction.builder()
            actionBuilder.setAdded(
                try GroupsV2Protos.buildRequestingMemberProto(
                    profileKeyCredential: localProfileKeyCredential,
                    groupV2Params: groupV2Params
                ))
            actionsBuilder.addAddRequestingMembers(actionBuilder.buildInfallibly())
        default:
            throw OWSAssertionError("Invalid addFromInviteLinkAccess.")
        }

        return actionsBuilder.buildInfallibly()
    }

    public func cancelRequestToJoin(groupModel: TSGroupModelV2) async throws {
        let groupV2Params = try groupModel.groupV2Params()

        var newRevision: UInt32?
        do {
            newRevision = try await cancelRequestToJoinUsingPatch(
                groupId: groupModel.groupId,
                groupV2Params: groupV2Params,
                inviteLinkPassword: groupModel.inviteLinkPassword
            )
        } catch {
            switch error {
            case GroupsV2Error.localUserBlockedFromJoining, GroupsV2Error.localUserIsNotARequestingMember:
                // In both of these cases, our request has already been removed. We can proceed with updating the model.
                break
            default:
                // Otherwise, we don't recover and let the error propogate
                throw error
            }
        }

        try await updateGroupRemovingMemberRequest(groupId: groupModel.groupId, newRevision: newRevision)
    }

    private func updateGroupRemovingMemberRequest(
        groupId: Data,
        newRevision proposedRevision: UInt32?
    ) async throws {
        try await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { transaction -> Void in
            guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: transaction) else {
                throw OWSAssertionError("Missing localIdentifiers.")
            }
            guard let groupThread = TSGroupThread.fetch(groupId: groupId, transaction: transaction) else {
                throw OWSAssertionError("Missing groupThread.")
            }
            // The group already existing in the database; make sure
            // that we are a requesting member.
            guard let oldGroupModel = groupThread.groupModel as? TSGroupModelV2 else {
                throw OWSAssertionError("Invalid groupModel.")
            }
            let oldGroupMembership = oldGroupModel.groupMembership
            var newRevision = oldGroupModel.revision + 1
            if let proposedRevision = proposedRevision {
                if oldGroupModel.revision >= proposedRevision {
                    // No need to update database, group state is already acceptable.
                    owsAssertDebug(!oldGroupMembership.isMemberOfAnyKind(localIdentifiers.aci))
                    return
                }
                newRevision = max(newRevision, proposedRevision)
            }

            var builder = oldGroupModel.asBuilder
            builder.isJoinRequestPlaceholder = true
            builder.groupV2Revision = newRevision

            var membershipBuilder = oldGroupMembership.asBuilder
            membershipBuilder.remove(localIdentifiers.aci)
            builder.groupMembership = membershipBuilder.build()
            let newGroupModel = try builder.build()

            groupThread.update(with: newGroupModel, transaction: transaction)

            let dmConfigurationStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
            let dmToken = dmConfigurationStore.fetchOrBuildDefault(for: .thread(groupThread), tx: transaction).asToken
            GroupManager.insertGroupUpdateInfoMessage(
                groupThread: groupThread,
                oldGroupModel: oldGroupModel,
                newGroupModel: newGroupModel,
                oldDisappearingMessageToken: dmToken,
                newDisappearingMessageToken: dmToken,
                newlyLearnedPniToAciAssociations: [:],
                groupUpdateSource: .localUser(originalSource: .aci(localIdentifiers.aci)),
                localIdentifiers: localIdentifiers,
                spamReportingMetadata: .createdByLocalAction,
                transaction: transaction
            )
        }
    }

    private func cancelRequestToJoinUsingPatch(
        groupId: Data,
        groupV2Params: GroupV2Params,
        inviteLinkPassword: Data?
    ) async throws -> UInt32 {
        // We re-fetch the GroupInviteLinkPreview before trying in order to get the latest:
        //
        // * revision
        // * addFromInviteLinkAccess
        // * local user's request status.
        let groupInviteLinkPreview = try await fetchGroupInviteLinkPreview(
            inviteLinkPassword: inviteLinkPassword,
            groupSecretParams: groupV2Params.groupSecretParams,
            allowCached: false
        )
        let oldRevision = groupInviteLinkPreview.revision
        let newRevision = oldRevision + 1

        let requestBuilder: RequestBuilder = { (authCredential) in
            let groupChangeProto = try self.buildChangeActionsProtoToCancelMemberRequest(
                groupV2Params: groupV2Params,
                newRevision: newRevision
            )
            return try StorageService.buildUpdateGroupRequest(
                groupChangeProto: groupChangeProto,
                groupV2Params: groupV2Params,
                authCredential: authCredential,
                groupInviteLinkPassword: inviteLinkPassword
            )
        }

        _ = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: groupId,
            behavior400: .fail,
            behavior403: .fail,
            behavior404: .fail
        )

        return newRevision
    }

    private func buildChangeActionsProtoToCancelMemberRequest(
        groupV2Params: GroupV2Params,
        newRevision: UInt32
    ) throws -> GroupsProtoGroupChangeActions {
        guard let localAci = DependenciesBridge.shared.tsAccountManager.localIdentifiersWithMaybeSneakyTransaction?.aci else {
            throw OWSAssertionError("Missing localAci.")
        }

        var actionsBuilder = GroupsProtoGroupChangeActions.builder()
        actionsBuilder.setRevision(newRevision)

        var actionBuilder = GroupsProtoGroupChangeActionsDeleteRequestingMemberAction.builder()
        let userId = try groupV2Params.userId(for: localAci)
        actionBuilder.setDeletedUserID(userId)
        actionsBuilder.addDeleteRequestingMembers(actionBuilder.buildInfallibly())

        return actionsBuilder.buildInfallibly()
    }

    private func updatePlaceholderGroupModelUsingInviteLinkPreview(
        groupSecretParams: GroupSecretParams,
        isLocalUserRequestingMember: Bool
    ) async {
        do {
            let groupId = try groupSecretParams.getPublicParams().getGroupIdentifier().serialize().asData
            try await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { transaction in
                guard let localIdentifiers = DependenciesBridge.shared.tsAccountManager.localIdentifiers(tx: transaction) else {
                    throw OWSAssertionError("Missing localIdentifiers.")
                }
                guard let groupThread = TSGroupThread.fetch(groupId: groupId, transaction: transaction) else {
                    // Thread not yet in database.
                    return
                }
                guard let oldGroupModel = groupThread.groupModel as? TSGroupModelV2 else {
                    throw OWSAssertionError("Invalid groupModel.")
                }
                guard oldGroupModel.isJoinRequestPlaceholder else {
                    // Not a placeholder model; no need to update.
                    return
                }
                guard isLocalUserRequestingMember != groupThread.isLocalUserRequestingMember else {
                    // Nothing to change.
                    return
                }
                let oldGroupMembership = oldGroupModel.groupMembership
                var builder = oldGroupModel.asBuilder

                var membershipBuilder = oldGroupMembership.asBuilder
                membershipBuilder.remove(localIdentifiers.aci)
                if isLocalUserRequestingMember {
                    membershipBuilder.addRequestingMember(localIdentifiers.aci)
                }
                builder.groupMembership = membershipBuilder.build()
                let newGroupModel = try builder.build()

                groupThread.update(with: newGroupModel, transaction: transaction)

                let dmConfigurationStore = DependenciesBridge.shared.disappearingMessagesConfigurationStore
                let dmToken = dmConfigurationStore.fetchOrBuildDefault(for: .thread(groupThread), tx: transaction).asToken
                // groupUpdateSource is unknown; we don't know who did the update.
                GroupManager.insertGroupUpdateInfoMessage(
                    groupThread: groupThread,
                    oldGroupModel: oldGroupModel,
                    newGroupModel: newGroupModel,
                    oldDisappearingMessageToken: dmToken,
                    newDisappearingMessageToken: dmToken,
                    newlyLearnedPniToAciAssociations: [:],
                    groupUpdateSource: .unknown,
                    localIdentifiers: localIdentifiers,
                    spamReportingMetadata: .createdByLocalAction,
                    transaction: transaction
                )
            }
        } catch {
            owsFailDebug("Error: \(error)")
        }
    }

    public func fetchGroupExternalCredentials(secretParams: GroupSecretParams) async throws -> GroupsProtoGroupExternalCredential {
        let groupParams = try GroupV2Params(groupSecretParams: secretParams)

        let requestBuilder: RequestBuilder = { authCredential in
            try StorageService.buildFetchGroupExternalCredentials(
                groupV2Params: groupParams,
                authCredential: authCredential
            )
        }

        let response = try await performServiceRequest(
            requestBuilder: requestBuilder,
            groupId: try secretParams.getPublicParams().getGroupIdentifier().serialize().asData,
            behavior400: .fail,
            behavior403: .fetchGroupUpdates,
            behavior404: .fail
        )

        guard let groupProtoData = response.responseBodyData else {
            throw OWSAssertionError("Invalid responseObject.")
        }
        return try GroupsProtoGroupExternalCredential(serializedData: groupProtoData)
    }
}

fileprivate extension HttpHeaders {
    private static let forbiddenKey: String = "X-Signal-Forbidden-Reason"
    private static let forbiddenValue: String = "banned"

    var containsBan: Bool {
        value(forHeader: Self.forbiddenKey) == Self.forbiddenValue
    }
}

// MARK: - What's in the change actions?

private extension GroupsProtoGroupChangeActions {
    var containsProfileKeyCredentials: Bool {
        // When adding a member, we include their profile key credential.
        let isAddingMembers = !addMembers.isEmpty

        // When promoting an invited member, we include the profile key for
        // their ACI.
        // Note: in practice the only user we'll promote is ourself, when
        // accepting an invite.
        let isPromotingPni = !promotePniPendingMembers.isEmpty
        let isPromotingAci = !promotePendingMembers.isEmpty

        return isAddingMembers || isPromotingPni || isPromotingAci
    }
}
