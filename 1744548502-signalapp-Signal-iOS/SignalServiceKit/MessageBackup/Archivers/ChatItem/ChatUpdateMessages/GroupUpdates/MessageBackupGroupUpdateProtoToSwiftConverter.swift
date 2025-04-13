//
// Copyright 2024 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient

final class MessageBackupGroupUpdateProtoToSwiftConverter {

    private init() {}

    typealias PersistableGroupUpdateItem = TSInfoMessage.PersistableGroupUpdateItem

    static func restoreGroupUpdates(
        groupUpdates: [BackupProto_GroupChangeChatUpdate.Update],
        // We should never be comparing our pni as it can change,
        // we only ever want to compare our unchanging aci.
        localUserAci: Aci,
        partialErrors: inout [MessageBackup.RestoreFrameError<MessageBackup.ChatItemId>],
        chatItemId: MessageBackup.ChatItemId
    ) -> MessageBackup.RestoreInteractionResult<[PersistableGroupUpdateItem]> {
        var persistableUpdates = [PersistableGroupUpdateItem]()
        for updateProto in groupUpdates {
            let result = Self.restoreGroupUpdate(
                groupUpdate: updateProto,
                localUserAci: localUserAci,
                chatItemId: chatItemId
            )
            switch result.bubbleUp([PersistableGroupUpdateItem].self, partialErrors: &partialErrors) {
            case .continue(let component):
                persistableUpdates.append(contentsOf: component)
            case .bubbleUpError(let error):
                return error
            }
        }
        return .success(persistableUpdates)
    }

    private static func restoreGroupUpdate(
        groupUpdate: BackupProto_GroupChangeChatUpdate.Update,
        localUserAci: Aci,
        chatItemId: MessageBackup.ChatItemId
    ) -> MessageBackup.RestoreInteractionResult<[PersistableGroupUpdateItem]> {
        enum UnwrappedRequiredAci {
            case localUser
            case otherUser(AciUuid)
            case invalidAci(MessageBackup.RestoreFrameError<MessageBackup.ChatItemId>)
        }
        func unwrapRequiredAci<Proto>(
            _ proto: Proto,
            _ aciKeyPath: KeyPath<Proto, Data>
        ) -> UnwrappedRequiredAci {
            let aciData = proto[keyPath: aciKeyPath]

            guard let aci = UUID(data: aciData).map({ Aci(fromUUID: $0) }) else {
                return .invalidAci(.restoreFrameError(
                    .invalidProtoData(.invalidAci(protoClass: Proto.self)),
                    chatItemId
                ))
            }

            if aci == localUserAci {
                return .localUser
            } else {
                return .otherUser(aci.codableUuid)
            }
        }

        enum UnwrappedOptionalAci {
            case unknown
            case localUser
            case otherUser(AciUuid)
            case invalidAci(MessageBackup.RestoreFrameError<MessageBackup.ChatItemId>)
        }
        func unwrapOptionalAci<Proto>(
            _ proto: Proto,
            _ aciKeyPath: KeyPath<Proto, Data>
        ) -> UnwrappedOptionalAci {
            let aciData = proto[keyPath: aciKeyPath]

            guard !aciData.isEmpty else {
                return .unknown
            }

            guard let aci = UUID(data: aciData).map({ Aci(fromUUID: $0) }) else {
                return .invalidAci(.restoreFrameError(
                    .invalidProtoData(.invalidAci(protoClass: Proto.self)),
                    chatItemId
                ))
            }

            if aci == localUserAci {
                return .localUser
            } else {
                return .otherUser(aci.codableUuid)
            }
        }

        switch groupUpdate.update {
        case nil:
            // Fallback to a generic update.
            return .success([.genericUpdateByUnknownUser])
        case .genericGroupUpdate(let proto):
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.genericUpdateByUnknownUser])
            case .localUser:
                return .success([.genericUpdateByLocalUser])
            case .otherUser(let aci):
                return .success([.genericUpdateByOtherUser(updaterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupCreationUpdate(let proto):
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.createdByUnknownUser])
            case .localUser:
                // When we see a `createdByLocalUser`, also include a
                // `inviteFriendsToNewlyCreatedGroup`.
                return .success([.createdByLocalUser, .inviteFriendsToNewlyCreatedGroup])
            case .otherUser(let aci):
                return .success([.createdByOtherUser(updaterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupNameUpdate(let proto):
            if proto.hasNewGroupName {
                let newName = proto.newGroupName
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.nameChangedByUnknownUser(newGroupName: newName)])
                case .localUser:
                    return .success([.nameChangedByLocalUser(newGroupName: newName)])
                case .otherUser(let aci):
                    return .success([.nameChangedByOtherUser(updaterAci: aci, newGroupName: newName)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.nameRemovedByUnknownUser])
                case .localUser:
                    return .success([.nameRemovedByLocalUser])
                case .otherUser(let aci):
                    return .success([.nameRemovedByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupAvatarUpdate(let proto):
            if proto.wasRemoved {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.avatarRemovedByUnknownUser])
                case .localUser:
                    return .success([.avatarRemovedByLocalUser])
                case .otherUser(let aci):
                    return .success([.avatarRemovedByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.avatarChangedByUnknownUser])
                case .localUser:
                    return .success([.avatarChangedByLocalUser])
                case .otherUser(let aci):
                    return .success([.avatarChangedByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupDescriptionUpdate(let proto):
            if proto.hasNewDescription {
                let newDescription = proto.newDescription
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.descriptionChangedByUnknownUser(newDescription: newDescription)])
                case .localUser:
                    return .success([.descriptionChangedByLocalUser(newDescription: newDescription)])
                case .otherUser(let aci):
                    return .success([.descriptionChangedByOtherUser(updaterAci: aci, newDescription: newDescription)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.descriptionRemovedByUnknownUser])
                case .localUser:
                    return .success([.descriptionRemovedByLocalUser])
                case .otherUser(let aci):
                    return .success([.descriptionRemovedByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupMembershipAccessLevelChangeUpdate(let proto):
            let newAccess = proto.accessLevel.swiftAccessLevel
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.membersAccessChangedByUnknownUser(newAccess: newAccess)])
            case .localUser:
                return .success([.membersAccessChangedByLocalUser(newAccess: newAccess)])
            case .otherUser(let aci):
                return .success([.membersAccessChangedByOtherUser(updaterAci: aci, newAccess: newAccess)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupAttributesAccessLevelChangeUpdate(let proto):
            let newAccess = proto.accessLevel.swiftAccessLevel
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.attributesAccessChangedByUnknownUser(newAccess: newAccess)])
            case .localUser:
                return .success([.attributesAccessChangedByLocalUser(newAccess: newAccess)])
            case .otherUser(let aci):
                return .success([.attributesAccessChangedByOtherUser(updaterAci: aci, newAccess: newAccess)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupAnnouncementOnlyChangeUpdate(let proto):
            if proto.isAnnouncementOnly {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.announcementOnlyEnabledByUnknownUser])
                case .localUser:
                    return .success([.announcementOnlyEnabledByLocalUser])
                case .otherUser(let aci):
                    return .success([.announcementOnlyEnabledByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.announcementOnlyDisabledByUnknownUser])
                case .localUser:
                    return .success([.announcementOnlyDisabledByLocalUser])
                case .otherUser(let aci):
                    return .success([.announcementOnlyDisabledByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupAdminStatusUpdate(let proto):
            let updaterAci = unwrapOptionalAci(proto, \.updaterAci)
            let memberAci = unwrapRequiredAci(proto, \.memberAci)
            if proto.wasAdminStatusGranted {
                switch (updaterAci, memberAci) {
                case (.unknown, .localUser):
                    return .success([.localUserWasGrantedAdministratorByUnknownUser])
                case (.localUser, .localUser):
                    return .success([.localUserWasGrantedAdministratorByLocalUser])
                case (.otherUser(let aci), .localUser):
                    return .success([.localUserWasGrantedAdministratorByOtherUser(updaterAci: aci)])
                case (.localUser, .otherUser(let aci)):
                    return .success([.otherUserWasGrantedAdministratorByLocalUser(userAci: aci)])
                case (.otherUser(let updaterAci), .otherUser(let memberAci)):
                    return .success([.otherUserWasGrantedAdministratorByOtherUser(updaterAci: updaterAci, userAci: memberAci)])
                case (.unknown, .otherUser(let aci)):
                    return .success([.otherUserWasGrantedAdministratorByUnknownUser(userAci: aci)])
                case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                    return .messageFailure([error])
                }
            } else {
                switch (updaterAci, memberAci) {
                case (.unknown, .localUser):
                    return .success([.localUserWasRevokedAdministratorByLocalUser])
                case (.localUser, .localUser):
                    return .success([.localUserWasRevokedAdministratorByLocalUser])
                case (.otherUser(let aci), .localUser):
                    return .success([.localUserWasRevokedAdministratorByOtherUser(updaterAci: aci)])
                case (.localUser, .otherUser(let aci)):
                    return .success([.otherUserWasRevokedAdministratorByLocalUser(userAci: aci)])
                case (.otherUser(let updaterAci), .otherUser(let memberAci)):
                    return .success([.otherUserWasRevokedAdministratorByOtherUser(updaterAci: updaterAci, userAci: memberAci)])
                case (.unknown, .otherUser(let aci)):
                    return .success([.otherUserWasRevokedAdministratorByUnknownUser(userAci: aci)])
                case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                    return .messageFailure([error])
                }
            }
        case .groupMemberLeftUpdate(let proto):
            switch unwrapRequiredAci(proto, \.aci) {
            case .localUser:
                return .success([.localUserLeft])
            case .otherUser(let aci):
                return .success([.otherUserLeft(userAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupMemberRemovedUpdate(let proto):
            switch (unwrapOptionalAci(proto, \.removerAci), unwrapRequiredAci(proto, \.removedAci)) {
            case (.unknown, .localUser):
                return .success([.localUserRemovedByUnknownUser])
            case (.localUser, .localUser):
                return .success([.localUserLeft])
            case (.otherUser(let removerAci), .localUser):
                return .success([.localUserRemoved(removerAci: removerAci)])
            case (.unknown, .otherUser(let removedAci)):
                return .success([.otherUserRemovedByUnknownUser(userAci: removedAci)])
            case (.localUser, .otherUser(let removedAci)):
                return .success([.otherUserRemovedByLocalUser(userAci: removedAci)])
            case (.otherUser(let removerAci), .otherUser(let removedAci)):
                return .success([.otherUserRemoved(removerAci: removerAci, userAci: removedAci)])
            case (_, .invalidAci(let error)), (.invalidAci(let error), _):
                return .messageFailure([error])
            }
        case .selfInvitedToGroupUpdate(let proto):
            switch unwrapOptionalAci(proto, \.inviterAci) {
            case .unknown:
                return .success([.localUserWasInvitedByUnknownUser])
            case .localUser:
                return .success([.localUserWasInvitedByLocalUser])
            case .otherUser(let aci):
                return .success([.localUserWasInvitedByOtherUser(updaterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .selfInvitedOtherUserToGroupUpdate(let proto):
            switch (try? ServiceId.parseFrom(serviceIdBinary: proto.inviteeServiceID)) {
            case .some(let serviceId):
                return .success([.otherUserWasInvitedByLocalUser(inviteeServiceId: serviceId.codableUppercaseString)])
            case .none:
                return .messageFailure([.restoreFrameError(
                    .invalidProtoData(.invalidServiceId(protoClass: BackupProto_SelfInvitedOtherUserToGroupUpdate.self)),
                    chatItemId
                )])
            }
        case .groupUnknownInviteeUpdate(let proto):
            let count = UInt(proto.inviteeCount)
            switch unwrapOptionalAci(proto, \.inviterAci) {
            case .unknown:
                return .success([.unnamedUsersWereInvitedByUnknownUser(count: count)])
            case .localUser:
                return .success([.unnamedUsersWereInvitedByLocalUser(count: count)])
            case .otherUser(let aci):
                return .success([.unnamedUsersWereInvitedByOtherUser(updaterAci: aci, count: count)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupInvitationAcceptedUpdate(let proto):
            switch (unwrapOptionalAci(proto, \.inviterAci), unwrapRequiredAci(proto, \.newMemberAci)) {
            case (.unknown, .localUser):
                return .success([.localUserAcceptedInviteFromUnknownUser])
            case (.localUser, .localUser):
                return .success([.localUserJoined])
            case (.otherUser(let inviterAci), .localUser):
                return .success([.localUserAcceptedInviteFromInviter(inviterAci: inviterAci)])
            case (.unknown, .otherUser(let aci)):
                return .success([.otherUserAcceptedInviteFromUnknownUser(userAci: aci)])
            case (.localUser, .otherUser(let aci)):
                return .success([.otherUserAcceptedInviteFromLocalUser(userAci: aci)])
            case (.otherUser(let inviterAci), .otherUser(let aci)):
                return .success([.otherUserAcceptedInviteFromInviter(userAci: aci, inviterAci: inviterAci)])
            case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                return .messageFailure([error])
            }
        case .groupInvitationDeclinedUpdate(let proto):
            switch (unwrapOptionalAci(proto, \.inviterAci), unwrapOptionalAci(proto, \.inviteeAci)) {
            case (.unknown, .localUser):
                return .success([.localUserDeclinedInviteFromUnknownUser])
            case (.localUser, .localUser):
                return .success([.localUserDeclinedInviteFromUnknownUser])
            case (.otherUser(let inviterAci), .localUser):
                return .success([.localUserDeclinedInviteFromInviter(inviterAci: inviterAci)])
            case (.unknown, .otherUser(let aci)):
                return .success([.otherUserDeclinedInviteFromUnknownUser(invitee: aci.wrappedValue.codableUppercaseString)])
            case (.localUser, .otherUser(let aci)):
                return .success([.otherUserDeclinedInviteFromLocalUser(invitee: aci.wrappedValue.codableUppercaseString)])
            case (.otherUser(let inviterAci), .otherUser(let aci)):
                return .success([.otherUserDeclinedInviteFromInviter(invitee: aci.wrappedValue.codableUppercaseString, inviterAci: inviterAci)])
            case (.unknown, .unknown):
                return .success([.unnamedUserDeclinedInviteFromUnknownUser])
            case (.localUser, .unknown):
                return .success([.unnamedUserDeclinedInviteFromUnknownUser])
            case (.otherUser(let inviterAci), .unknown):
                return .success([.unnamedUserDeclinedInviteFromInviter(inviterAci: inviterAci)])
            case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                return .messageFailure([error])
            }
        case .groupMemberJoinedUpdate(let proto):
            switch unwrapRequiredAci(proto, \.newMemberAci) {
            case .localUser:
                return .success([.localUserJoined])
            case .otherUser(let aci):
                return .success([.otherUserJoined(userAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupMemberAddedUpdate(let proto):
            switch (unwrapOptionalAci(proto, \.inviterAci), unwrapRequiredAci(proto, \.newMemberAci)) {
            case (.unknown, .localUser):
                return .success([.localUserAddedByUnknownUser])
            case (.localUser, .localUser):
                return .success([.localUserAddedByLocalUser])
            case (.otherUser(let updaterAci), .localUser):
                return .success([.localUserAddedByOtherUser(updaterAci: updaterAci)])
            case (.unknown, .otherUser(let aci)):
                return .success([.otherUserAddedByUnknownUser(userAci: aci)])
            case (.localUser, .otherUser(let aci)):
                return .success([.otherUserAddedByLocalUser(userAci: aci)])
            case (.otherUser(let updaterAci), .otherUser(let aci)):
                return .success([.otherUserAddedByOtherUser(updaterAci: updaterAci, userAci: aci)])
            case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                return .messageFailure([error])
            }
        case .groupSelfInvitationRevokedUpdate(let proto):
            switch unwrapOptionalAci(proto, \.revokerAci) {
            case .unknown:
                return .success([.localUserInviteRevokedByUnknownUser])
            case .localUser:
                return .success([.localUserDeclinedInviteFromUnknownUser])
            case .otherUser(let aci):
                return .success([.localUserInviteRevoked(revokerAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupInvitationRevokedUpdate(let proto):
            let updaterAci = unwrapOptionalAci(proto, \.updaterAci)
            if
                case .localUser = updaterAci,
                proto.invitees.count == 1,
                let inviteeServiceId: ServiceId = {
                    let invitee = proto.invitees[0]
                    if
                        invitee.hasInviteeAci,
                        let aciUuid = UUID(data: invitee.inviteeAci)
                    {
                        return Aci(fromUUID: aciUuid)
                    } else if
                        invitee.hasInviteePni,
                        let pniUuid = UUID(data: invitee.inviteePni)
                    {
                        return Pni(fromUUID: pniUuid)
                    } else {
                        return nil
                    }
                }()
            {
                return .success([.otherUserInviteRevokedByLocalUser(
                    invitee: inviteeServiceId.codableUppercaseString
                )])
            } else {
                let count = UInt(proto.invitees.count)
                switch updaterAci {
                case .unknown:
                    return .success([.unnamedUserInvitesWereRevokedByUnknownUser(count: count)])
                case .localUser:
                    return .success([.unnamedUserInvitesWereRevokedByLocalUser(count: count)])
                case .otherUser(let aci):
                    return .success([.unnamedUserInvitesWereRevokedByOtherUser(updaterAci: aci, count: count)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupJoinRequestUpdate(let proto):
            switch unwrapRequiredAci(proto, \.requestorAci) {
            case .localUser:
                return .success([.localUserRequestedToJoin])
            case .otherUser(let aci):
                return .success([.otherUserRequestedToJoin(userAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupJoinRequestApprovalUpdate(let proto):
            if proto.wasApproved {
                switch (unwrapRequiredAci(proto, \.requestorAci), unwrapOptionalAci(proto, \.updaterAci)) {
                case (.localUser, .unknown):
                    return .success([.localUserRequestApprovedByUnknownUser])
                case (.localUser, .localUser):
                    return .success([.localUserJoined])
                case (.localUser, .otherUser(let updaterAci)):
                    return .success([.localUserRequestApproved(approverAci: updaterAci)])
                case (.otherUser(let aci), .unknown):
                    return .success([.otherUserRequestApprovedByUnknownUser(userAci: aci)])
                case (.otherUser(let aci), .localUser):
                    return .success([.otherUserRequestApprovedByLocalUser(userAci: aci)])
                case (.otherUser(let aci), .otherUser(let approverAci)):
                    return .success([.otherUserRequestApproved(userAci: aci, approverAci: approverAci)])
                case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                    return .messageFailure([error])
                }
            } else {
                switch (unwrapRequiredAci(proto, \.requestorAci), unwrapOptionalAci(proto, \.updaterAci)) {
                case (.localUser, .unknown):
                    return .success([.localUserRequestRejectedByUnknownUser])
                case (.localUser, .localUser):
                    return .success([.localUserRequestCanceledByLocalUser])
                case (.localUser, .otherUser(_)):
                    // We don't keep the rejector's information
                    return .success([.localUserRequestRejectedByUnknownUser])
                case (.otherUser(let aci), .unknown):
                    return .success([.otherUserRequestRejectedByUnknownUser(requesterAci: aci)])
                case (.otherUser(let aci), .localUser):
                    return .success([.otherUserRequestRejectedByLocalUser(requesterAci: aci)])
                case (.otherUser(let aci), .otherUser(let rejectorAci)):
                    return .success([.otherUserRequestRejectedByOtherUser(updaterAci: rejectorAci, requesterAci: aci)])
                case (.invalidAci(let error), _), (_, .invalidAci(let error)):
                    return .messageFailure([error])
                }
            }
        case .groupJoinRequestCanceledUpdate(let proto):
            switch unwrapRequiredAci(proto, \.requestorAci) {
            case .localUser:
                return .success([.localUserRequestCanceledByLocalUser])
            case .otherUser(let aci):
                return .success([.otherUserRequestCanceledByOtherUser(requesterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupInviteLinkResetUpdate(let proto):
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.inviteLinkResetByUnknownUser])
            case .localUser:
                return .success([.inviteLinkResetByLocalUser])
            case .otherUser(let aci):
                return .success([.inviteLinkResetByOtherUser(updaterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupInviteLinkEnabledUpdate(let proto):
            if proto.linkRequiresAdminApproval {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.inviteLinkEnabledWithApprovalByUnknownUser])
                case .localUser:
                    return .success([.inviteLinkEnabledWithApprovalByLocalUser])
                case .otherUser(let aci):
                    return .success([.inviteLinkEnabledWithApprovalByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.inviteLinkEnabledWithoutApprovalByUnknownUser])
                case .localUser:
                    return .success([.inviteLinkEnabledWithoutApprovalByLocalUser])
                case .otherUser(let aci):
                    return .success([.inviteLinkEnabledWithoutApprovalByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupInviteLinkAdminApprovalUpdate(let proto):
            if proto.linkRequiresAdminApproval {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.inviteLinkApprovalEnabledByUnknownUser])
                case .localUser:
                    return .success([.inviteLinkApprovalEnabledByLocalUser])
                case .otherUser(let aci):
                    return .success([.inviteLinkApprovalEnabledByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.inviteLinkApprovalDisabledByUnknownUser])
                case .localUser:
                    return .success([.inviteLinkApprovalDisabledByLocalUser])
                case .otherUser(let aci):
                    return .success([.inviteLinkApprovalDisabledByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        case .groupInviteLinkDisabledUpdate(let proto):
            switch unwrapOptionalAci(proto, \.updaterAci) {
            case .unknown:
                return .success([.inviteLinkDisabledByUnknownUser])
            case .localUser:
                return .success([.inviteLinkDisabledByLocalUser])
            case .otherUser(let aci):
                return .success([.inviteLinkDisabledByOtherUser(updaterAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupMemberJoinedByLinkUpdate(let proto):
            switch unwrapRequiredAci(proto, \.newMemberAci) {
            case .localUser:
                return .success([.localUserJoinedViaInviteLink])
            case .otherUser(let aci):
                return .success([.otherUserJoinedViaInviteLink(userAci: aci)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupV2MigrationUpdate(_):
            return .success([.wasMigrated])
        case .groupV2MigrationSelfInvitedUpdate(_):
            return .success([.localUserInvitedAfterMigration])
        case .groupV2MigrationInvitedMembersUpdate(let proto):
            return .success([.otherUsersInvitedAfterMigration(count: UInt(proto.invitedMembersCount))])
        case .groupV2MigrationDroppedMembersUpdate(let proto):
            return .success([.otherUsersDroppedAfterMigration(count: UInt(proto.droppedMembersCount))])
        case .groupSequenceOfRequestsAndCancelsUpdate(let proto):
            switch unwrapRequiredAci(proto, \.requestorAci) {
            case .localUser:
                return .messageFailure([.restoreFrameError(
                    .invalidProtoData(.sequenceOfRequestsAndCancelsWithLocalAci),
                    chatItemId
                )])
            // We assume it is the tail to start out with; if we see a subsequent join request
            // from the same invite then we will mark it as not the tail.
            case .otherUser(let aci):
                return .success([.sequenceOfInviteLinkRequestAndCancels(requester: aci, count: UInt(proto.count), isTail: true)])
            case .invalidAci(let error):
                return .messageFailure([error])
            }
        case .groupExpirationTimerUpdate(let proto):
            let durationMs = proto.expiresInMs
            if durationMs > 0 {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.disappearingMessagesEnabledByUnknownUser(durationMs: durationMs)])
                case .localUser:
                    return .success([.disappearingMessagesEnabledByLocalUser(durationMs: durationMs)])
                case .otherUser(let aci):
                    return .success([.disappearingMessagesEnabledByOtherUser(updaterAci: aci, durationMs: durationMs)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            } else {
                switch unwrapOptionalAci(proto, \.updaterAci) {
                case .unknown:
                    return .success([.disappearingMessagesDisabledByUnknownUser])
                case .localUser:
                    return .success([.disappearingMessagesDisabledByLocalUser])
                case .otherUser(let aci):
                    return .success([.disappearingMessagesDisabledByOtherUser(updaterAci: aci)])
                case .invalidAci(let error):
                    return .messageFailure([error])
                }
            }
        }
    }
}

extension BackupProto_GroupV2AccessLevel {

    fileprivate var swiftAccessLevel: GroupV2Access {
        switch self {
        case .unknown, .UNRECOGNIZED:
            return .unknown
        case .any:
            return .any
        case .member:
            return .member
        case .administrator:
            return .administrator
        case .unsatisfiable:
            return .unsatisfiable
        }
    }
}
