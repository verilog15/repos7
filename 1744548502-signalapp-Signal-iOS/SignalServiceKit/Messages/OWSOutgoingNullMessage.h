//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class OWSVerificationStateSyncMessage;
@class TSContactThread;

@interface OWSOutgoingNullMessage : TSOutgoingMessage

- (instancetype)initWithGrdbId:(int64_t)grdbId
                          uniqueId:(NSString *)uniqueId
               receivedAtTimestamp:(uint64_t)receivedAtTimestamp
                            sortId:(uint64_t)sortId
                         timestamp:(uint64_t)timestamp
                    uniqueThreadId:(NSString *)uniqueThreadId
                              body:(nullable NSString *)body
                        bodyRanges:(nullable MessageBodyRanges *)bodyRanges
                      contactShare:(nullable OWSContact *)contactShare
          deprecated_attachmentIds:(nullable NSArray<NSString *> *)deprecated_attachmentIds
                         editState:(TSEditState)editState
                   expireStartedAt:(uint64_t)expireStartedAt
                expireTimerVersion:(nullable NSNumber *)expireTimerVersion
                         expiresAt:(uint64_t)expiresAt
                  expiresInSeconds:(unsigned int)expiresInSeconds
                         giftBadge:(nullable OWSGiftBadge *)giftBadge
                 isGroupStoryReply:(BOOL)isGroupStoryReply
    isSmsMessageRestoredFromBackup:(BOOL)isSmsMessageRestoredFromBackup
                isViewOnceComplete:(BOOL)isViewOnceComplete
                 isViewOnceMessage:(BOOL)isViewOnceMessage
                       linkPreview:(nullable OWSLinkPreview *)linkPreview
                    messageSticker:(nullable MessageSticker *)messageSticker
                     quotedMessage:(nullable TSQuotedMessage *)quotedMessage
      storedShouldStartExpireTimer:(BOOL)storedShouldStartExpireTimer
             storyAuthorUuidString:(nullable NSString *)storyAuthorUuidString
                storyReactionEmoji:(nullable NSString *)storyReactionEmoji
                    storyTimestamp:(nullable NSNumber *)storyTimestamp
                wasRemotelyDeleted:(BOOL)wasRemotelyDeleted
                     customMessage:(nullable NSString *)customMessage
                  groupMetaMessage:(TSGroupMetaMessage)groupMetaMessage
             hasLegacyMessageState:(BOOL)hasLegacyMessageState
               hasSyncedTranscript:(BOOL)hasSyncedTranscript
                    isVoiceMessage:(BOOL)isVoiceMessage
                legacyMessageState:(TSOutgoingMessageState)legacyMessageState
                legacyWasDelivered:(BOOL)legacyWasDelivered
             mostRecentFailureText:(nullable NSString *)mostRecentFailureText
            recipientAddressStates:(nullable NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                       recipientAddressStates
                storedMessageState:(TSOutgoingMessageState)storedMessageState
              wasNotCreatedLocally:(BOOL)wasNotCreatedLocally NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<SignalServiceAddress *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<SignalServiceAddress *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithContactThread:(TSContactThread *)contactThread
                          transaction:(DBReadTransaction *)transaction NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithContactThread:(TSContactThread *)contactThread
         verificationStateSyncMessage:(OWSVerificationStateSyncMessage *)verificationStateSyncMessage
                          transaction:(DBReadTransaction *)transaction NS_DESIGNATED_INITIALIZER;
;

@end

NS_ASSUME_NONNULL_END
