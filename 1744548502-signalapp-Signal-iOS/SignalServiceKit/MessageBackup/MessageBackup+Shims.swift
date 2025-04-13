//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import GRDB
import LibSignalClient

public enum MessageBackup {}

extension MessageBackup {
    public enum Shims {
        public typealias BlockingManager = _MessageBackup_BlockingManagerShim
        public typealias ContactManager = _MessageBackup_ContactManagerShim
        public typealias DonationSubscriptionManager = _MessageBackup_DonationSubscriptionManagerShim
        public typealias OWS2FAManager = _MessageBackup_OWS2FAManagerShim
        public typealias Preferences = _MessageBackup_PreferencesShim
        public typealias ProfileManager = _MessageBackup_ProfileManagerShim
        public typealias ReactionManager = _MessageBackup_ReactionManagerShim
        public typealias ReceiptManager = _MessageBackup_ReceiptManagerShim
        public typealias SSKPreferences = _MessageBackup_SSKPreferencesShim
        public typealias StoryManager = _MessageBackup_StoryManagerShim
        public typealias SystemStoryManager = _MessageBackup_SystemStoryManagerShim
        public typealias TypingIndicators = _MessageBackup_TypingIndicatorsShim
        public typealias UDManager = _MessageBackup_UDManagerShim
    }

    public enum Wrappers {
        public typealias BlockingManager = _MessageBackup_BlockingManagerWrapper
        public typealias ContactManager = _MessageBackup_ContactManagerWrapper
        public typealias DonationSubscriptionManager = _MessageBackup_DonationSubscriptionManagerWrapper
        public typealias OWS2FAManager = _MessageBackup_OWS2FAManagerWrapper
        public typealias Preferences = _MessageBackup_PreferencesWrapper
        public typealias ProfileManager = _MessageBackup_ProfileManagerWrapper
        public typealias ReactionManager = _MessageBackup_ReactionManagerWrapper
        public typealias ReceiptManager = _MessageBackup_ReceiptManagerWrapper
        public typealias SSKPreferences = _MessageBackup_SSKPreferencesWrapper
        public typealias StoryManager = _MessageBackup_StoryManagerWrapper
        public typealias SystemStoryManager = _MessageBackup_SystemStoryManagerWrapper
        public typealias TypingIndicators = _MessageBackup_TypingIndicatorsWrapper
        public typealias UDManager = _MessageBackup_UDManagerWrapper
    }
}

// MARK: - BlockingManager

public protocol _MessageBackup_BlockingManagerShim {

    func blockedRecipientIds(tx: DBReadTransaction) throws -> Set<SignalRecipient.RowId>
    func blockedGroupIds(tx: DBReadTransaction) throws -> [Data]

    func addBlockedAddress(_ address: SignalServiceAddress, tx: DBWriteTransaction)
    func addBlockedGroupId(_ groupId: Data, tx: DBWriteTransaction)
}

public class _MessageBackup_BlockingManagerWrapper: _MessageBackup_BlockingManagerShim {

    private let blockingManager: BlockingManager

    public init(_ blockingManager: BlockingManager) {
        self.blockingManager = blockingManager
    }

    public func blockedRecipientIds(tx: DBReadTransaction) throws -> Set<SignalRecipient.RowId> {
        return try blockingManager.blockedRecipientIds(tx: SDSDB.shimOnlyBridge(tx))
    }

    public func blockedGroupIds(tx: DBReadTransaction) throws -> [Data] {
        return try blockingManager.blockedGroupIds(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func addBlockedAddress(_ address: SignalServiceAddress, tx: DBWriteTransaction) {
        blockingManager.addBlockedAddress(address, blockMode: .restoreFromBackup, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func addBlockedGroupId(_ groupId: Data, tx: DBWriteTransaction) {
        blockingManager.addBlockedGroupId(groupId, blockMode: .restoreFromBackup, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - ContactManager

public protocol _MessageBackup_ContactManagerShim {
    func displayName(_ address: SignalServiceAddress, tx: DBWriteTransaction) -> String
    func fetchSignalAccount(_ address: SignalServiceAddress, tx: DBReadTransaction) -> SignalAccount?
    func insertSignalAccount(_ account: SignalAccount, tx: DBWriteTransaction)
}

public class _MessageBackup_ContactManagerWrapper: _MessageBackup_ContactManagerShim {
    private let contactManager: any ContactManager

    init(_ contactManager: any ContactManager) {
        self.contactManager = contactManager
    }

    public func displayName(_ address: SignalServiceAddress, tx: DBWriteTransaction) -> String {
        return contactManager.displayName(for: address, tx: SDSDB.shimOnlyBridge(tx)).resolvedValue()
    }

    public func fetchSignalAccount(_ address: SignalServiceAddress, tx: DBReadTransaction) -> SignalAccount? {
        return contactManager.fetchSignalAccount(for: address, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func insertSignalAccount(_ account: SignalAccount, tx: DBWriteTransaction) {
        account.anyInsert(transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - DonationSubscriptionManager

public protocol _MessageBackup_DonationSubscriptionManagerShim {
    func displayBadgesOnProfile(tx: DBReadTransaction) -> Bool
    func setDisplayBadgesOnProfile(value: Bool, tx: DBWriteTransaction)
    func getSubscriberID(tx: DBReadTransaction) -> Data?
    func setSubscriberID(subscriberID: Data, tx: DBWriteTransaction)
    func getSubscriberCurrencyCode(tx: DBReadTransaction) -> String?
    func setSubscriberCurrencyCode(currencyCode: Currency.Code?, tx: DBWriteTransaction)
    func userManuallyCancelledSubscription(tx: DBReadTransaction) -> Bool
    func setUserManuallyCancelledSubscription(value: Bool, tx: DBWriteTransaction)
}

public class _MessageBackup_DonationSubscriptionManagerWrapper: _MessageBackup_DonationSubscriptionManagerShim {
    public func displayBadgesOnProfile(tx: DBReadTransaction) -> Bool {
        DonationSubscriptionManager.displayBadgesOnProfile(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setDisplayBadgesOnProfile(value: Bool, tx: DBWriteTransaction) {
        DonationSubscriptionManager.setDisplayBadgesOnProfile(value, updateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func getSubscriberID(tx: DBReadTransaction) -> Data? {
        DonationSubscriptionManager.getSubscriberID(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setSubscriberID(subscriberID: Data, tx: DBWriteTransaction) {
        DonationSubscriptionManager.setSubscriberID(subscriberID, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func getSubscriberCurrencyCode(tx: DBReadTransaction) -> String? {
        DonationSubscriptionManager.getSubscriberCurrencyCode(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setSubscriberCurrencyCode(currencyCode: Currency.Code?, tx: DBWriteTransaction) {
        DonationSubscriptionManager.setSubscriberCurrencyCode(currencyCode, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func userManuallyCancelledSubscription(tx: DBReadTransaction) -> Bool {
        DonationSubscriptionManager.userManuallyCancelledSubscription(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setUserManuallyCancelledSubscription(value: Bool, tx: DBWriteTransaction) {
        DonationSubscriptionManager.setUserManuallyCancelledSubscription(value, updateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - OWS2FAManager

public protocol _MessageBackup_OWS2FAManagerShim {
    func getPin(tx: DBReadTransaction) -> String?
    func restorePinFromBackup(_ pin: String, tx: DBWriteTransaction)
}

public class _MessageBackup_OWS2FAManagerWrapper: _MessageBackup_OWS2FAManagerShim {
    private let ows2FAManager: OWS2FAManager

    init(_ ows2FAManager: OWS2FAManager) {
        self.ows2FAManager = ows2FAManager
    }

    public func getPin(tx: DBReadTransaction) -> String? {
        ows2FAManager.pinCode(transaction: tx)
    }

    public func restorePinFromBackup(_ pin: String, tx: DBWriteTransaction) {
        ows2FAManager.restorePinFromBackup(pin, transaction: tx)
    }
}

// MARK: - Preferences

public protocol _MessageBackup_PreferencesShim {
    func shouldShowUnidentifiedDeliveryIndicators(tx: DBReadTransaction) -> Bool
    func setShouldShowUnidentifiedDeliveryIndicators(value: Bool, tx: DBWriteTransaction)
    func setWasGroupCallTooltipShown(tx: DBWriteTransaction)
}

public class _MessageBackup_PreferencesWrapper: _MessageBackup_PreferencesShim {
    let preferences: Preferences
    init(preferences: Preferences) {
        self.preferences = preferences
    }

    public func shouldShowUnidentifiedDeliveryIndicators(tx: DBReadTransaction) -> Bool {
        preferences.shouldShowUnidentifiedDeliveryIndicators(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setShouldShowUnidentifiedDeliveryIndicators(value: Bool, tx: DBWriteTransaction) {
        preferences.setShouldShowUnidentifiedDeliveryIndicators(value, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setWasGroupCallTooltipShown(tx: DBWriteTransaction) {
        preferences.setWasGroupCallTooltipShown(tx: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - ProfileManager

public protocol _MessageBackup_ProfileManagerShim {

    func enumerateUserProfiles(tx: DBReadTransaction, block: (OWSUserProfile) -> Void)

    func getUserProfile(for address: SignalServiceAddress, tx: DBReadTransaction) -> OWSUserProfile?

    func getUserProfileForLocalUser(tx: DBReadTransaction) -> OWSUserProfile?

    func allWhitelistedAddresses(tx: DBReadTransaction) -> [SignalServiceAddress]

    func isGroupId(inProfileWhitelist groupId: Data, tx: DBReadTransaction) -> Bool

    func addToWhitelist(_ address: SignalServiceAddress, tx: DBWriteTransaction)

    func addToWhitelist(_ thread: TSGroupThread, tx: DBWriteTransaction)

    func insertLocalUserProfile(
        givenName: String,
        familyName: String?,
        avatarUrlPath: String?,
        profileKey: Aes256Key,
        tx: DBWriteTransaction
    )

    func upsertOtherUserProfile(
        insertableAddress: OWSUserProfile.InsertableAddress,
        givenName: String?,
        familyName: String?,
        profileKey: Aes256Key?,
        tx: DBWriteTransaction
    )
}

public class _MessageBackup_ProfileManagerWrapper: _MessageBackup_ProfileManagerShim {
    private let profileManager: ProfileManager

    public init(_ profileManager: ProfileManager) {
        self.profileManager = profileManager
    }

    public func enumerateUserProfiles(tx: DBReadTransaction, block: (OWSUserProfile) -> Void) {
        OWSUserProfile.anyEnumerate(transaction: SDSDB.shimOnlyBridge(tx)) { profile, _ in
            block(profile)
        }
    }

    public func getUserProfile(for address: SignalServiceAddress, tx: DBReadTransaction) -> OWSUserProfile? {
        profileManager.userProfile(for: address, tx: SDSDB.shimOnlyBridge(tx))
    }

    public func getUserProfileForLocalUser(tx: DBReadTransaction) -> OWSUserProfile? {
        return OWSUserProfile.getUserProfileForLocalUser(tx: SDSDB.shimOnlyBridge(tx))
    }

    public func allWhitelistedAddresses(tx: DBReadTransaction) -> [SignalServiceAddress] {
        profileManager.allWhitelistedAddresses(tx: SDSDB.shimOnlyBridge(tx))
    }

    public func isGroupId(inProfileWhitelist groupId: Data, tx: DBReadTransaction) -> Bool {
        profileManager.isGroupId(inProfileWhitelist: groupId, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func addToWhitelist(_ address: SignalServiceAddress, tx: DBWriteTransaction) {
        profileManager.addUser(
            toProfileWhitelist: address,
            userProfileWriter: .messageBackupRestore,
            transaction: SDSDB.shimOnlyBridge(tx)
        )
    }

    public func addToWhitelist(_ thread: TSGroupThread, tx: DBWriteTransaction) {
        profileManager.addThread(
            toProfileWhitelist: thread,
            userProfileWriter: .messageBackupRestore,
            transaction: SDSDB.shimOnlyBridge(tx)
        )
    }

    public func insertLocalUserProfile(
        givenName: String,
        familyName: String?,
        avatarUrlPath: String?,
        profileKey: Aes256Key,
        tx: DBWriteTransaction
    ) {
        let sdsTx = SDSDB.shimOnlyBridge(tx)

        /// We can't simply insert a local-user profile here, because
        /// `OWSProfileManager` will create one itself during its `warmCaches`
        /// initialization dance. So, we'll grab the one that was created and
        /// simply overwrite its fields.
        let localUserProfile = OWSUserProfile.getOrBuildUserProfileForLocalUser(
            userProfileWriter: .messageBackupRestore,
            tx: sdsTx
        )

        localUserProfile.upsertWithNoSideEffects(
            givenName: givenName,
            familyName: familyName,
            avatarUrlPath: avatarUrlPath,
            profileKey: profileKey,
            tx: sdsTx
        )
    }

    public func upsertOtherUserProfile(
        insertableAddress: OWSUserProfile.InsertableAddress,
        givenName: String?,
        familyName: String?,
        profileKey: Aes256Key?,
        tx: DBWriteTransaction
    ) {
        if case .localUser = insertableAddress {
            owsFailDebug("Cannot use this method for the local user's profile!")
            return
        }

        let sdsTx: DBWriteTransaction = SDSDB.shimOnlyBridge(tx)

        /// We can't simply insert a profile here, because we might have created
        /// a profile through another flow (e.g., by setting a "missing" profile
        /// key).
        let profile = OWSUserProfile.getOrBuildUserProfile(
            for: insertableAddress,
            userProfileWriter: .messageBackupRestore,
            tx: sdsTx
        )

        profile.upsertWithNoSideEffects(
            givenName: givenName,
            familyName: familyName,
            avatarUrlPath: nil,
            profileKey: profileKey,
            tx: sdsTx
        )
    }
}

// MARK: - ReactionManager

public protocol _MessageBackup_ReactionManagerShim {
    func customEmojiSet(tx: DBReadTransaction) -> [String]?
    func setCustomEmojiSet(emojis: [String]?, tx: DBWriteTransaction)
}

public class _MessageBackup_ReactionManagerWrapper: _MessageBackup_ReactionManagerShim {
    public func customEmojiSet(tx: DBReadTransaction) -> [String]? {
        ReactionManager.customEmojiSet(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setCustomEmojiSet(emojis: [String]?, tx: DBWriteTransaction) {
        ReactionManager.setCustomEmojiSet(emojis, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - ReceiptManager

public protocol _MessageBackup_ReceiptManagerShim {
    func areReadReceiptsEnabled(tx: DBReadTransaction) -> Bool
    func setAreReadReceiptsEnabled(value: Bool, tx: DBWriteTransaction)
}
public class _MessageBackup_ReceiptManagerWrapper: _MessageBackup_ReceiptManagerShim {
    let receiptManager: OWSReceiptManager
    init(receiptManager: OWSReceiptManager) {
        self.receiptManager = receiptManager
    }

    public func areReadReceiptsEnabled(tx: DBReadTransaction) -> Bool {
        OWSReceiptManager.areReadReceiptsEnabled(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setAreReadReceiptsEnabled(value: Bool, tx: DBWriteTransaction) {
        receiptManager.setAreReadReceiptsEnabled(value, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - SSKPreferences

public protocol _MessageBackup_SSKPreferencesShim {
    func preferContactAvatars(tx: DBReadTransaction) -> Bool
    func setPreferContactAvatars(value: Bool, tx: DBWriteTransaction)

    func shouldKeepMutedChatsArchived(tx: DBReadTransaction) -> Bool
    func setShouldKeepMutedChatsArchived(value: Bool, tx: DBWriteTransaction)
    func setHasSavedThread(_ newValue: Bool, tx: DBWriteTransaction)
}

public class _MessageBackup_SSKPreferencesWrapper: _MessageBackup_SSKPreferencesShim {
    public func preferContactAvatars(tx: DBReadTransaction) -> Bool {
        SSKPreferences.preferContactAvatars(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setPreferContactAvatars(value: Bool, tx: DBWriteTransaction) {
        SSKPreferences.setPreferContactAvatars(value, updateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func shouldKeepMutedChatsArchived(tx: DBReadTransaction) -> Bool {
        SSKPreferences.shouldKeepMutedChatsArchived(transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setShouldKeepMutedChatsArchived(value: Bool, tx: DBWriteTransaction) {
        SSKPreferences.setShouldKeepMutedChatsArchived(value, transaction: SDSDB.shimOnlyBridge(tx))
    }

    public func setHasSavedThread(_ newValue: Bool, tx: DBWriteTransaction) {
        SSKPreferences.setHasSavedThread(newValue, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - StoryManager

public protocol _MessageBackup_StoryManagerShim {
    func hasSetMyStoriesPrivacy(tx: DBReadTransaction) -> Bool
    func setHasSetMyStoriesPrivacy(value: Bool, tx: DBWriteTransaction)
    func areStoriesEnabled(tx: DBReadTransaction) -> Bool
    func setAreStoriesEnabled(value: Bool, tx: DBWriteTransaction)
    func areViewReceiptsEnabled(tx: DBReadTransaction) -> Bool
    func setAreViewReceiptsEnabled(value: Bool, tx: DBWriteTransaction)
}

public class _MessageBackup_StoryManagerWrapper: _MessageBackup_StoryManagerShim {
    public func hasSetMyStoriesPrivacy(tx: DBReadTransaction) -> Bool {
        StoryManager.hasSetMyStoriesPrivacy(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setHasSetMyStoriesPrivacy(value: Bool, tx: DBWriteTransaction) {
        StoryManager.setHasSetMyStoriesPrivacy(value, shouldUpdateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func areStoriesEnabled(tx: DBReadTransaction) -> Bool {
        StoryManager.areStoriesEnabled(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setAreStoriesEnabled(value: Bool, tx: DBWriteTransaction) {
        StoryManager.setAreStoriesEnabled(value, shouldUpdateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func areViewReceiptsEnabled(tx: DBReadTransaction) -> Bool {
        StoryManager.areViewReceiptsEnabled(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setAreViewReceiptsEnabled(value: Bool, tx: DBWriteTransaction) {
        StoryManager.setAreViewReceiptsEnabled(value, shouldUpdateStorageService: false, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - SystemStoryManager

public protocol _MessageBackup_SystemStoryManagerShim {
    func isOnboardingStoryViewed(tx: DBReadTransaction) -> Bool
    func setHasViewedOnboardingStory(value: Bool, tx: DBWriteTransaction)
    func hasSeenGroupStoryEducationSheet(tx: DBReadTransaction) -> Bool
    func setHasSeenGroupStoryEducationSheet(value: Bool, tx: DBWriteTransaction)
}

public class _MessageBackup_SystemStoryManagerWrapper: _MessageBackup_SystemStoryManagerShim {
    let systemStoryManager: SystemStoryManagerProtocol
    init(systemStoryManager: SystemStoryManagerProtocol) {
        self.systemStoryManager = systemStoryManager
    }
    public func isOnboardingStoryViewed(tx: DBReadTransaction) -> Bool {
        systemStoryManager.isOnboardingStoryViewed(transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func setHasViewedOnboardingStory(value: Bool, tx: DBWriteTransaction) {
        guard value else {
            /// This is a one-way setting, so there's no way to set `false`. If
            /// it's `false`, simply set nothing.
            return
        }

        let source: OnboardingStoryViewSource = .local(
            timestamp: 0,
            shouldUpdateStorageService: false
        )
        try? systemStoryManager.setHasViewedOnboardingStory(source: source, transaction: SDSDB.shimOnlyBridge(tx))
    }
    public func hasSeenGroupStoryEducationSheet(tx: DBReadTransaction) -> Bool {
        systemStoryManager.isGroupStoryEducationSheetViewed(tx: SDSDB.shimOnlyBridge(tx))
    }
    public func setHasSeenGroupStoryEducationSheet(value: Bool, tx: DBWriteTransaction) {
        guard value else {
            /// This is a one-way setting, so there's no way to set `false`. If
            /// it's `false`, simply set nothing.
            return
        }

        systemStoryManager.setGroupStoryEducationSheetViewed(tx: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - TypingIndicators

public protocol _MessageBackup_TypingIndicatorsShim {
    func areTypingIndicatorsEnabled() -> Bool
    func setTypingIndicatorsEnabled(value: Bool, tx: DBWriteTransaction)
}
public class _MessageBackup_TypingIndicatorsWrapper: _MessageBackup_TypingIndicatorsShim {
    let typingIndicators: TypingIndicators
    init(typingIndicators: TypingIndicators) {
        self.typingIndicators = typingIndicators
    }

    public func areTypingIndicatorsEnabled() -> Bool {
        typingIndicators.areTypingIndicatorsEnabled()
    }

    public func setTypingIndicatorsEnabled(value: Bool, tx: DBWriteTransaction) {
        typingIndicators.setTypingIndicatorsEnabled(value: value, transaction: SDSDB.shimOnlyBridge(tx))
    }
}

// MARK: - UDManager

public protocol _MessageBackup_UDManagerShim {
    func phoneNumberSharingMode(tx: DBReadTransaction) -> PhoneNumberSharingMode?
    func setPhoneNumberSharingMode(mode: PhoneNumberSharingMode, tx: DBWriteTransaction)
}

public class _MessageBackup_UDManagerWrapper: _MessageBackup_UDManagerShim {
    let udManager: OWSUDManager
    init(udManager: OWSUDManager) {
        self.udManager = udManager
    }
    public func phoneNumberSharingMode(tx: DBReadTransaction) -> PhoneNumberSharingMode? {
        udManager.phoneNumberSharingMode(tx: tx)
    }
    public func setPhoneNumberSharingMode(mode: PhoneNumberSharingMode, tx: DBWriteTransaction) {
        udManager.setPhoneNumberSharingMode(mode, updateStorageServiceAndProfile: false, tx: SDSDB.shimOnlyBridge(tx))
    }
}
