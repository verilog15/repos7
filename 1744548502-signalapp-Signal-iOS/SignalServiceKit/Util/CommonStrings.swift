//
// Copyright 2016 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation

/**
 * Strings re-used in multiple places should be added here.
 */
public enum CommonStrings {

    static public var archiveAction: String {
        OWSLocalizedString("ARCHIVE_ACTION", comment: "Label for the archive button for conversations list view")
    }

    static public var acknowledgeButton: String {
        OWSLocalizedString("ALERT_ACTION_ACKNOWLEDGE", comment:
                            "generic button text to acknowledge that the corresponding text was read.")
    }

    static public var backButton: String {
        OWSLocalizedString("BACK_BUTTON", comment: "return to the previous screen")
    }

    static public var cancelButton: String {
        OWSLocalizedString("TXT_CANCEL_TITLE", comment: "Label for the cancel button in an alert or action sheet.")
    }

    static public var continueButton: String {
        OWSLocalizedString("BUTTON_CONTINUE", comment: "Label for 'continue' button.")
    }

    static public var discardButton: String {
        OWSLocalizedString("ALERT_DISCARD_BUTTON", comment: "The label for the 'discard' button in alerts and action sheets.")
    }

    static public var dismissButton: String {
        OWSLocalizedString("DISMISS_BUTTON_TEXT", comment: "Short text to dismiss current modal / actionsheet / screen")
    }

    static public var selectButton: String {
        OWSLocalizedString("BUTTON_SELECT", comment: "Button text to enable batch selection mode")
    }

    static public var doneButton: String {
        OWSLocalizedString("BUTTON_DONE", comment: "Label for generic done button.")
    }

    static public var nextButton: String {
        OWSLocalizedString("BUTTON_NEXT", comment: "Label for the 'next' button.")
    }

    static public var previousButton: String {
        OWSLocalizedString("BUTTON_PREVIOUS", comment: "Label for the 'previous' button.")
    }

    static public var skipButton: String {
        OWSLocalizedString("NAVIGATION_ITEM_SKIP_BUTTON", comment: "A button to skip a view.")
    }

    static public var deleteButton: String {
        OWSLocalizedString("TXT_DELETE_TITLE",
                          comment: "Label for the delete button in an alert or action sheet.")
    }

    static public var deleteForMeButton: String {
        OWSLocalizedString(
            "MESSAGE_ACTION_DELETE_FOR_YOU",
            comment: "The title for the action that deletes a message for the local user only.")
    }

    static public var retryButton: String {
        OWSLocalizedString("RETRY_BUTTON_TEXT",
                          comment: "Generic text for button that retries whatever the last action was.")
    }

    static public var okayButton: String {
        OWSLocalizedString("BUTTON_OKAY", comment: "Label for the 'okay' button.")
    }

    static public var okButton: String {
        OWSLocalizedString("OK", comment: "Label for the 'ok' button.")
    }

    static public var copyButton: String {
        OWSLocalizedString("BUTTON_COPY", comment: "Label for the 'copy' button.")
    }

    static public var setButton: String {
        OWSLocalizedString("BUTTON_SET", comment: "Label for the 'set' button.")
    }

    static public var editButton: String {
        OWSLocalizedString("BUTTON_EDIT", comment: "Label for the 'edit' button.")
    }

    static public var saveButton: String {
        OWSLocalizedString("ALERT_SAVE",
                          comment: "The label for the 'save' button in action sheets.")
    }

    static public var shareButton: String {
        OWSLocalizedString("BUTTON_SHARE", comment: "Label for the 'share' button.")
    }

    static public var goToSettingsButton: String {
        OWSLocalizedString(
            "GO_TO_SETTINGS_BUTTON",
            comment: "Label for the 'go to settings' button"
        )
    }

    static public var help: String {
        OWSLocalizedString("SETTINGS_HELP", comment: "Title for help button and help pages in app settings.")
    }

    static public var openAppSettingsButton: String {
        OWSLocalizedString(
            "OPEN_APP_SETTINGS_BUTTON",
            comment: "Title for button which opens the in-app settings"
        )
    }

    static public var openSystemSettingsButton: String {
        OWSLocalizedString(
            "OPEN_SETTINGS_BUTTON",
            comment: "Button text which opens the settings app"
        )
    }

    static public var errorAlertTitle: String {
        OWSLocalizedString("ALERT_ERROR_TITLE", comment: "")
    }

    static public var searchPlaceholder: String {
        OWSLocalizedString("SEARCH_FIELD_PLACE_HOLDER_TEXT",
                          comment: "placeholder text in an empty search field")
    }

    static public var mainPhoneNumberLabel: String {
        OWSLocalizedString("PHONE_NUMBER_TYPE_MAIN", comment: "Label for 'Main' phone numbers.")
    }

    static public var contactSupport: String {
        OWSLocalizedString("CONTACT_SUPPORT",
                          comment: "Button text to initiate an email to signal support staff")
    }

    static public var learnMore: String {
        OWSLocalizedString("LEARN_MORE", comment: "Label for the 'learn more' button.")
    }

    static public var unarchiveAction: String {
        OWSLocalizedString("UNARCHIVE_ACTION",
                          comment: "Label for the unarchive button for conversations list view")
    }

    static public var readAction: String {
        OWSLocalizedString("READ_ACTION", comment: "Pressing this button marks a thread as read")
    }

    static public var unreadAction: String {
        OWSLocalizedString("UNREAD_ACTION", comment: "Pressing this button marks a thread as unread")
    }

    static public var pinAction: String {
        OWSLocalizedString("PIN_ACTION", comment: "Pressing this button pins a thread")
    }

    static public var unpinAction: String {
        OWSLocalizedString("UNPIN_ACTION", comment: "Pressing this button un-pins a thread")
    }

    static public var switchOn: String {
        OWSLocalizedString("SWITCH_ON", comment: "Label for 'on' state of a switch control.")
    }

    static public var switchOff: String {
        OWSLocalizedString("SWITCH_OFF", comment: "Label for 'off' state of a switch control.")
    }

    static public var sendMessage: String {
        OWSLocalizedString("ACTION_SEND_MESSAGE",
                          comment: "Label for button that lets you send a message to a contact.")
    }

    static public var yesButton: String {
        OWSLocalizedString("BUTTON_YES", comment: "Label for the 'yes' button.")
    }

    static public var noButton: String {
        OWSLocalizedString("BUTTON_NO", comment: "Label for the 'no' button.")
    }

    static public var redeemGiftButton: String {
        return OWSLocalizedString(
            "DONATION_ON_BEHALF_OF_A_FRIEND_REDEEM_BADGE",
            comment: "Label for a button used to redeem a badge that was received as a donation on your behalf."
        )
    }

    static public var notNowButton: String {
        OWSLocalizedString("BUTTON_NOT_NOW", comment: "Label for the 'not now' button.")
    }

    static public var addButton: String {
        OWSLocalizedString("BUTTON_ADD", comment: "Label for the 'add' button.")
    }

    static public var viewButton: String {
        OWSLocalizedString("BUTTON_VIEW", comment: "Label for the 'view' button.")
    }

    static public var seeAllButton: String {
        OWSLocalizedString("SEE_ALL_BUTTON", comment: "Label for the 'see all' button.")
    }

    static public var muteButton: String {
        OWSLocalizedString("BUTTON_MUTE", comment: "Label for the 'mute' button.")
    }

    static public var unmuteButton: String {
        OWSLocalizedString("BUTTON_UNMUTE", comment: "Label for the 'unmute' button.")
    }

    static public var genericError: String {
        OWSLocalizedString("ALERT_ERROR_TITLE", comment: "Generic error indicator.")
    }

    static public var attachmentTypePhoto: String {
        OWSLocalizedString("ATTACHMENT_TYPE_PHOTO",
                          comment: "Short text label for a photo attachment, used for thread preview and on the lock screen")
    }

    static public var attachmentTypeVideo: String {
        OWSLocalizedString("ATTACHMENT_TYPE_VIDEO",
                          comment: "Short text label for a video attachment, used for thread preview and on the lock screen")
    }

    static public var attachmentTypeAnimated: String {
        OWSLocalizedString("ATTACHMENT_TYPE_ANIMATED",
                          comment: "Short text label for an animated attachment, used for thread preview and on the lock screen")
    }

    static public var searchBarPlaceholder: String {
        OWSLocalizedString("INVITE_FRIENDS_PICKER_SEARCHBAR_PLACEHOLDER", comment: "Search")
    }

    static public var unknownUser: String {
        OWSLocalizedString("UNKNOWN_USER", comment: "Label indicating an unknown user.")
    }

    static public var you: String {
        OWSLocalizedString("YOU", comment: "Second person pronoun to represent the local user.")
    }

    static public var somethingWentWrongError: String {
        OWSLocalizedString(
            "SOMETHING_WENT_WRONG_ERROR",
            comment: "An error message generically indicating that something went wrong."
        )
    }

    static public var somethingWentWrongTryAgainLaterError: String {
        OWSLocalizedString(
            "SOMETHING_WENT_WRONG_TRY_AGAIN_LATER_ERROR",
            comment: "An error message generically indicating that something went wrong, and that the user should try again later."
        )
    }

    static public var scanQRCodeTitle: String {
        OWSLocalizedString(
            "SCAN_QR_CODE_VIEW_TITLE",
            comment: "Title for the 'scan QR code' view."
        )
    }
}

// MARK: -

public extension Usernames.RemoteMutationError {
    var localizedDescription: String {
        switch self {
        case .networkError:
            return OWSLocalizedString(
                "USERNAMES_REMOTE_MUTATION_ERROR_DESCRIPTION",
                comment: "An error message indicating that a usernames-related requeset failed because of a network error."
            )
        case .otherError:
            return CommonStrings.somethingWentWrongTryAgainLaterError
        }
    }
}

// MARK: -

public enum MessageStrings {

    static public var conversationIsBlocked: String {
        OWSLocalizedString("CONTACT_CELL_IS_BLOCKED",
                          comment: "An indicator that a contact or group has been blocked.")
    }

    static public var newGroupDefaultTitle: String {
        OWSLocalizedString("NEW_GROUP_DEFAULT_TITLE",
                          comment: "Used in place of the group name when a group has not yet been named.")
    }

    static public var replyNotificationAction: String {
        OWSLocalizedString("PUSH_MANAGER_REPLY", comment: "Notification action button title")
    }

    static public var markAsReadNotificationAction: String {
        OWSLocalizedString("PUSH_MANAGER_MARKREAD", comment: "Notification action button title")
    }

    static public var reactWithThumbsUpNotificationAction: String {
        OWSLocalizedString("PUSH_MANAGER_REACT_WITH_THUMBS_UP",
                          comment: "Notification action button title for 'react with thumbs up.'")
    }

    static public var sendButton: String {
        OWSLocalizedString("SEND_BUTTON_TITLE", comment: "Label for the button to send a message")
    }

    static public var noteToSelf: String {
        OWSLocalizedString("NOTE_TO_SELF", comment: "Label for 1:1 conversation with yourself.")
    }

    static public var viewOnceViewPhoto: String {
        OWSLocalizedString("PER_MESSAGE_EXPIRATION_VIEW_PHOTO",
                          comment: "Label for view-once messages indicating that user can tap to view the message's contents.")
    }

    static public var viewOnceViewVideo: String {
        OWSLocalizedString("PER_MESSAGE_EXPIRATION_VIEW_VIDEO",
                          comment: "Label for view-once messages indicating that user can tap to view the message's contents.")
    }

    static public var removePreviewButtonLabel: String {
        OWSLocalizedString("REMOVE_PREVIEW",
                          comment: "Accessibility label for a button that removes the preview from a drafted message.")
    }
}

// MARK: -

public enum NotificationStrings {

    static public var missedCallBecauseOfIdentityChangeBody: String {
        OWSLocalizedString("CALL_MISSED_BECAUSE_OF_IDENTITY_CHANGE_NOTIFICATION_BODY",
                          comment: "notification body")
    }

    static public var genericIncomingMessageNotification: String {
        OWSLocalizedString("GENERIC_INCOMING_MESSAGE_NOTIFICATION", comment: "notification title indicating the user generically has a new message")
    }

    /// Body for notification in a thread with a pending message request.
    static public var incomingMessageRequestNotification: String {
        OWSLocalizedString(
            "NOTIFICATION_BODY_INCOMING_MESSAGE_REQUEST",
            comment: "Body for a notification representing a message request."
        )
    }

    /// This is the fallback message used for push notifications
    /// when the NSE or main app is unable to process them. We
    /// don't use it directly in the app, but need to maintain
    /// a reference to it for string generation.
    static public var indeterminateIncomingMessageNotification: String {
        OWSLocalizedString("APN_Message", comment: "notification body")
    }

    static public var incomingGroupMessageTitleFormat: String {
        OWSLocalizedString("NEW_GROUP_MESSAGE_NOTIFICATION_TITLE",
                          comment: "notification title. Embeds {{author name}} and {{group name}}")
    }

    static public var incomingGroupStoryReplyTitleFormat: String {
        OWSLocalizedString("NEW_GROUP_STORY_REPLY_NOTIFICATION_TITLE",
                           comment: "notification title. Embeds {{ %1%@ author name, %2%@ group name}}")
    }

    static public var failedToSendBody: String {
        OWSLocalizedString("SEND_FAILED_NOTIFICATION_BODY", comment: "notification body")
    }

    static public var groupCallSafetyNumberChangeBody: String {
        OWSLocalizedString("GROUP_CALL_SAFETY_NUMBER_CHANGE_BODY",
                          comment: "notification body when a group call participant joins with an untrusted safety number")
    }

    static public var groupCallSafetyNumberChangeAtJoinBody: String {
        OWSLocalizedString("GROUP_CALL_SAFETY_NUMBER_CHANGE_AT_JOIN_BODY",
                          comment: "notification body when you join a group call and an already-joined participant has an untrusted safety number")
    }

    static public var incomingReactionFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionTextMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_TEXT_MESSAGE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}} and {{body text}}")
    }

    static public var incomingReactionViewOnceMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_VIEW_ONCE_MESSAGE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionStickerMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_STICKER_MESSAGE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionContactShareMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_CONTACT_SHARE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionAlbumMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_ALBUM_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionPhotoMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_PHOTO_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionVideoMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_VIDEO_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionVoiceMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_VOICE_MESSAGE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionAudioMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_AUDIO_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionGifMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_GIF_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }

    static public var incomingReactionFileMessageFormat: String {
        OWSLocalizedString("REACTION_INCOMING_NOTIFICATION_TO_FILE_BODY_FORMAT",
                          comment: "notification body. Embeds {{reaction emoji}}")
    }
}

// MARK: -

public enum CallStrings {
    static var callBackButtonTitle: String {
        return OWSLocalizedString("CALLBACK_BUTTON_TITLE", comment: "notification action")
    }

    static var showThreadButtonTitle: String {
        return OWSLocalizedString("SHOW_THREAD_BUTTON_TITLE", comment: "notification action")
    }

    public static var signalCall: String {
        return OWSLocalizedString(
            "SIGNAL_CALL",
            comment: "Shown in the header when the user hasn't provided a custom name for a call."
        )
    }

    public static var callLinkDescription: String {
        return OWSLocalizedString(
            "CALL_LINK_LINK_PREVIEW_DESCRIPTION",
            comment: "Shown in a message bubble when you send a call link in a Signal chat"
        )
    }
}

// MARK: -

public enum MediaStrings {

    static public var allMedia: String {
        OWSLocalizedString("MEDIA_DETAIL_VIEW_ALL_MEDIA_BUTTON", comment: "nav bar button item")
    }
}

// MARK: -

public enum SafetyNumberStrings {

    static public var confirmSendButton: String {
        OWSLocalizedString(
            "SAFETY_NUMBER_CHANGED_CONFIRM_SEND_ACTION",
            comment: "button title to confirm sending to a recipient whose safety number recently changed"
        )
    }

    static public var verified: String {
        OWSLocalizedString(
            "PRIVACY_IDENTITY_IS_VERIFIED_BADGE",
            comment: "Badge indicating that the user is verified."
        )
    }
}

// MARK: -

public enum MegaphoneStrings {

    static public var remindMeLater: String {
        OWSLocalizedString("MEGAPHONE_REMIND_LATER", comment: "button title to snooze a megaphone")
    }

    static public var weWillRemindYouLater: String {
        OWSLocalizedString("MEGAPHONE_WILL_REMIND_LATER",
                          comment: "toast indicating that we will remind the user later")
    }
}

// MARK: -

public enum StoryStrings {

    static public var repliesAndReactionsHeader: String {
        OWSLocalizedString(
            "STORIES_REPLIES_AND_REACTIONS_HEADER",
            comment: "Section header for the 'replies & reactions' section in stories settings")
    }

    static public var repliesAndReactionsFooter: String {
        OWSLocalizedString(
            "STORIES_REPLIES_AND_REACTIONS_FOOTER",
            comment: "Section footer for the 'replies & reactions' section in stories settings")
    }

    static public var repliesAndReactionsToggle: String {
        OWSLocalizedString(
            "STORIES_REPLIES_AND_REACTIONS_TOGGLE",
            comment: "Toggle text for the 'replies & reactions' switch in stories settings")
    }
}
