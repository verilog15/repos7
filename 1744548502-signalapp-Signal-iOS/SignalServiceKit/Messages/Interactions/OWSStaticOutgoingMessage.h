//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

// A generic, serializable message that can be used to
// send fixed plaintextData payloads.
@interface OWSStaticOutgoingMessage : TSOutgoingMessage

- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                        recipientAddressStates:
                            (NSDictionary<SignalServiceAddress *, TSOutgoingMessageRecipientState *> *)
                                recipientAddressStates NS_UNAVAILABLE;
- (instancetype)initOutgoingMessageWithBuilder:(TSOutgoingMessageBuilder *)outgoingMessageBuilder
                          additionalRecipients:(NSArray<SignalServiceAddress *> *)additionalRecipients
                            explicitRecipients:(NSArray<AciObjC *> *)explicitRecipients
                             skippedRecipients:(NSArray<SignalServiceAddress *> *)skippedRecipients
                                   transaction:(DBReadTransaction *)transaction NS_UNAVAILABLE;

- (instancetype)initWithThread:(TSThread *)thread
                     timestamp:(uint64_t)timestamp
                 plaintextData:(NSData *)plaintextData
                   transaction:(DBReadTransaction *)transaction;

@end

NS_ASSUME_NONNULL_END
