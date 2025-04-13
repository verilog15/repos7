//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import LibSignalClient
import XCTest

@testable import SignalServiceKit

final class DisplayableGroupUpdateItemCopyTest: XCTestCase {
    private let displayalbeGroupUpdateItemExamples: [DisplayableGroupUpdateItem] = [
        .genericUpdateByLocalUser,
        .genericUpdateByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .genericUpdateByUnknownUser,

        .createdByLocalUser,
        .createdByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .createdByUnknownUser,

        .nameChangedByLocalUser(newGroupName: "A New Hope"),
        .nameChangedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, newGroupName: "The Empire Strikes Back"),
        .nameChangedByUnknownUser(newGroupName: "Return of the Jedi"),

        .nameRemovedByLocalUser,
        .nameRemovedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .nameRemovedByUnknownUser,

        .avatarChangedByLocalUser,
        .avatarChangedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .avatarChangedByUnknownUser,

        .avatarRemovedByLocalUser,
        .avatarRemovedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .avatarRemovedByUnknownUser,

        .descriptionChangedByLocalUser(newDescription: "A long time ago in a galaxy far, far away..."),
        .descriptionChangedByOtherUser(
            newDescription: "A long time ago in a galaxy far, far away...",
            updaterName: .otherUser1,
            updaterAddress: .otherUser1
        ),
        .descriptionChangedByUnknownUser(newDescription: "A long time ago in a galaxy far, far away..."),

        .descriptionRemovedByLocalUser,
        .descriptionRemovedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .descriptionRemovedByUnknownUser,

        .membersAccessChangedByLocalUser(newAccess: .administrator),
        .membersAccessChangedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, newAccess: .administrator),
        .membersAccessChangedByUnknownUser(newAccess: .administrator),

        .attributesAccessChangedByLocalUser(newAccess: .unsatisfiable),
        .attributesAccessChangedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, newAccess: .unsatisfiable),
        .attributesAccessChangedByUnknownUser(newAccess: .unsatisfiable),

        .announcementOnlyEnabledByLocalUser,
        .announcementOnlyEnabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .announcementOnlyEnabledByUnknownUser,

        .announcementOnlyDisabledByLocalUser,
        .announcementOnlyDisabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .announcementOnlyDisabledByUnknownUser,

        .wasMigrated,

        .localUserWasGrantedAdministratorByLocalUser,
        .localUserWasGrantedAdministratorByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .localUserWasGrantedAdministratorByUnknownUser,

        .otherUserWasGrantedAdministratorByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserWasGrantedAdministratorByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, userName: .otherUser2, userAddress: .otherUser2),
        .otherUserWasGrantedAdministratorByUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserWasRevokedAdministratorByLocalUser,
        .localUserWasRevokedAdministratorByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .localUserWasRevokedAdministratorByUnknownUser,

        .otherUserWasRevokedAdministratorByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserWasRevokedAdministratorByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, userName: .otherUser2, userAddress: .otherUser2),
        .otherUserWasRevokedAdministratorByUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserLeft,
        .localUserRemoved(removerName: .otherUser1, removerAddress: .otherUser1),
        .localUserRemovedByUnknownUser,

        .otherUserLeft(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserRemovedByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserRemoved(removerName: .otherUser1, removerAddress: .otherUser1, userName: .otherUser2, userAddress: .otherUser2),
        .otherUserRemovedByUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserWasInvitedByLocalUser,
        .localUserWasInvitedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .localUserWasInvitedByUnknownUser,

        .otherUserWasInvitedByLocalUser(userName: .otherUser2, userAddress: .otherUser2),

        .unnamedUsersWereInvitedByLocalUser(count: 1),
        .unnamedUsersWereInvitedByLocalUser(count: 4),
        .unnamedUsersWereInvitedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, count: 1),
        .unnamedUsersWereInvitedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, count: 4),
        .unnamedUsersWereInvitedByUnknownUser(count: 1),
        .unnamedUsersWereInvitedByUnknownUser(count: 4),

        .localUserAcceptedInviteFromInviter(inviterName: .otherUser1, inviterAddress: .otherUser1),
        .localUserAcceptedInviteFromUnknownUser,
        .otherUserAcceptedInviteFromLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserAcceptedInviteFromInviter(userName: .otherUser2, userAddress: .otherUser2, inviterName: .otherUser1, inviterAddress: .otherUser1),
        .otherUserAcceptedInviteFromUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserJoined,
        .otherUserJoined(userName: .otherUser2, userAddress: .otherUser2),

        .localUserAddedByLocalUser,
        .localUserAddedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .localUserAddedByUnknownUser,

        .otherUserAddedByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserAddedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, userName: .otherUser2, userAddress: .otherUser2),
        .otherUserAddedByUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserDeclinedInviteFromInviter(inviterName: .otherUser2, inviterAddress: .otherUser2),
        .localUserDeclinedInviteFromUnknownUser,
        .localUserInviteRevoked(revokerName: .otherUser2, revokerAddress: .otherUser2),
        .localUserInviteRevokedByUnknownUser,

        .otherUserInviteRevokedByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserDeclinedInviteFromLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserDeclinedInviteFromInviter(inviterName: .otherUser2, inviterAddress: .otherUser2),
        .otherUserDeclinedInviteFromUnknownUser,

        .unnamedUserInvitesWereRevokedByLocalUser(count: 1),
        .unnamedUserInvitesWereRevokedByLocalUser(count: 5),
        .unnamedUserInvitesWereRevokedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, count: 1),
        .unnamedUserInvitesWereRevokedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, count: 4),
        .unnamedUserInvitesWereRevokedByUnknownUser(count: 1),
        .unnamedUserInvitesWereRevokedByUnknownUser(count: 3),

        .localUserRequestedToJoin,
        .otherUserRequestedToJoin(userName: .otherUser2, userAddress: .otherUser2),

        .localUserRequestApproved(approverName: .otherUser2, approverAddress: .otherUser2),
        .localUserRequestApprovedByUnknownUser,
        .otherUserRequestApprovedByLocalUser(userName: .otherUser2, userAddress: .otherUser2),
        .otherUserRequestApproved(userName: .otherUser2, userAddress: .otherUser2, approverName: .otherUser2, approverAddress: .otherUser2),
        .otherUserRequestApprovedByUnknownUser(userName: .otherUser2, userAddress: .otherUser2),

        .localUserRequestCanceledByLocalUser,
        .localUserRequestRejectedByUnknownUser,

        .otherUserRequestRejectedByLocalUser(requesterName: .otherUser2, requesterAddress: .otherUser2),
        .otherUserRequestRejectedByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, requesterName: .otherUser2, requesterAddress: .otherUser2),
        .otherUserRequestCanceledByOtherUser(requesterName: .otherUser2, requesterAddress: .otherUser2),
        .otherUserRequestRejectedByUnknownUser(requesterName: .otherUser2, requesterAddress: .otherUser2),

        .disappearingMessagesEnabledByLocalUser(durationMs: 1000),
        .disappearingMessagesEnabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1, durationMs: 1000),
        .disappearingMessagesEnabledByUnknownUser(durationMs: 1000),

        .disappearingMessagesDisabledByLocalUser,
        .disappearingMessagesDisabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .disappearingMessagesDisabledByUnknownUser,

        .inviteLinkResetByLocalUser,
        .inviteLinkResetByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkResetByUnknownUser,

        .inviteLinkEnabledWithoutApprovalByLocalUser,
        .inviteLinkEnabledWithoutApprovalByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkEnabledWithoutApprovalByUnknownUser,

        .inviteLinkEnabledWithApprovalByLocalUser,
        .inviteLinkEnabledWithApprovalByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkEnabledWithApprovalByUnknownUser,

        .inviteLinkDisabledByLocalUser,
        .inviteLinkDisabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkDisabledByUnknownUser,

        .inviteLinkApprovalDisabledByLocalUser,
        .inviteLinkApprovalDisabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkApprovalDisabledByUnknownUser,

        .inviteLinkApprovalEnabledByLocalUser,
        .inviteLinkApprovalEnabledByOtherUser(updaterName: .otherUser1, updaterAddress: .otherUser1),
        .inviteLinkApprovalEnabledByUnknownUser,

        .localUserJoinedViaInviteLink,
        .otherUserJoinedViaInviteLink(userName: .otherUser2, userAddress: .otherUser2),

        .sequenceOfInviteLinkRequestAndCancels(userName: .otherUser2, userAddress: .otherUser2, count: 1, isTail: true),
        .sequenceOfInviteLinkRequestAndCancels(userName: .otherUser2, userAddress: .otherUser2, count: 4, isTail: true)
    ]

    /// The strings for group update copy were migrated from one file to
    /// another, manually. This test ensures that none of them were "broken",
    /// for example a format string missing the correct format args.
    func testGroupUpdateTypeCopyIsConstructedCorrectly() {
        for example in displayalbeGroupUpdateItemExamples {
            // If we have a "(null)" in a string, we missed a format arg.
            XCTAssertFalse(example.localizedText.string.contains("(null)"))
        }
    }
}

// MARK: - Mock data

private extension String {
    static var otherUser1: String { "Han Solo" }

    static var otherUser2: String { "Boba Fett" }
}

private extension SignalServiceAddress {
    static let otherUser1: SignalServiceAddress = SignalServiceAddress(
        serviceId: Aci.randomForTesting(),
        phoneNumber: nil,
        cache: SignalServiceAddressCache()
    )

    static let otherUser2: SignalServiceAddress = SignalServiceAddress(
        serviceId: Aci.randomForTesting(),
        phoneNumber: nil,
        cache: SignalServiceAddressCache()
    )
}
