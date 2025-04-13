//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import LibSignalClient

extension GroupManager {

    /// Inserts an info message into the given thread for a new group.
    public static func insertGroupUpdateInfoMessageForNewGroup(
        localIdentifiers: LocalIdentifiers,
        spamReportingMetadata: GroupUpdateSpamReportingMetadata,
        groupThread: TSGroupThread,
        groupModel: TSGroupModel,
        disappearingMessageToken: DisappearingMessageToken,
        groupUpdateSource: GroupUpdateSource,
        transaction: DBWriteTransaction
    ) {
        DependenciesBridge.shared.groupUpdateInfoMessageInserter.insertGroupUpdateInfoMessageForNewGroup(
            localIdentifiers: localIdentifiers,
            spamReportingMetadata: spamReportingMetadata,
            groupThread: groupThread,
            groupModel: groupModel,
            disappearingMessageToken: disappearingMessageToken,
            groupUpdateSource: groupUpdateSource,
            transaction: transaction
        )
    }

    /// Inserts an info message into the given thread describing how the thread
    /// has been updated, given before/after models for the thread.
    ///
    /// - Parameter newlyLearnedPniToAciAssociations
    /// Associations between PNIs and ACIs that were learned as a result of this
    /// group update.
    public static func insertGroupUpdateInfoMessage(
        groupThread: TSGroupThread,
        oldGroupModel: TSGroupModel,
        newGroupModel: TSGroupModel,
        oldDisappearingMessageToken: DisappearingMessageToken,
        newDisappearingMessageToken: DisappearingMessageToken,
        newlyLearnedPniToAciAssociations: [Pni: Aci],
        groupUpdateSource: GroupUpdateSource,
        localIdentifiers: LocalIdentifiers,
        spamReportingMetadata: GroupUpdateSpamReportingMetadata,
        transaction: DBWriteTransaction
    ) {
        DependenciesBridge.shared.groupUpdateInfoMessageInserter.insertGroupUpdateInfoMessage(
            localIdentifiers: localIdentifiers,
            spamReportingMetadata: spamReportingMetadata,
            groupThread: groupThread,
            oldGroupModel: oldGroupModel,
            newGroupModel: newGroupModel,
            oldDisappearingMessageToken: oldDisappearingMessageToken,
            newDisappearingMessageToken: newDisappearingMessageToken,
            newlyLearnedPniToAciAssociations: newlyLearnedPniToAciAssociations,
            groupUpdateSource: groupUpdateSource,
            transaction: transaction
        )
    }
}
