//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/TSOutgoingMessage.h>

NS_ASSUME_NONNULL_BEGIN

@class AciObjC;
@class SSKProtoCallMessageAnswer;
@class SSKProtoCallMessageBusy;
@class SSKProtoCallMessageHangup;
@class SSKProtoCallMessageIceUpdate;
@class SSKProtoCallMessageOffer;
@class SSKProtoCallMessageOpaque;
@class TSThread;

/// A message sent to the other participants in a call to pass along a RingRTC
/// payload out-of-band.
///
/// Not to be confused with a ``TSCall``.
@interface OWSOutgoingCallMessage : TSOutgoingMessage

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
                  offerMessage:(SSKProtoCallMessageOffer *)offerMessage
           destinationDeviceId:(nullable NSNumber *)destinationDeviceId
                   transaction:(DBReadTransaction *)transaction;
- (instancetype)initWithThread:(TSThread *)thread
                 answerMessage:(SSKProtoCallMessageAnswer *)answerMessage
           destinationDeviceId:(nullable NSNumber *)destinationDeviceId
                   transaction:(DBReadTransaction *)transaction;
- (instancetype)initWithThread:(TSThread *)thread
             iceUpdateMessages:(NSArray<SSKProtoCallMessageIceUpdate *> *)iceUpdateMessage
           destinationDeviceId:(nullable NSNumber *)destinationDeviceId
                   transaction:(DBReadTransaction *)transaction;
- (instancetype)initWithThread:(TSThread *)thread
                 hangupMessage:(SSKProtoCallMessageHangup *)hangupMessage
           destinationDeviceId:(nullable NSNumber *)destinationDeviceId
                   transaction:(DBReadTransaction *)transaction;
- (instancetype)initWithThread:(TSThread *)thread
                   busyMessage:(SSKProtoCallMessageBusy *)busyMessage
           destinationDeviceId:(nullable NSNumber *)destinationDeviceId
                   transaction:(DBReadTransaction *)transaction;
- (instancetype)initWithThread:(TSThread *)thread
                 opaqueMessage:(SSKProtoCallMessageOpaque *)opaqueMessage
            overrideRecipients:(nullable NSArray<AciObjC *> *)overrideRecipients
                   transaction:(DBReadTransaction *)transaction;

@property (nullable, nonatomic, readonly) SSKProtoCallMessageOffer *offerMessage;
@property (nullable, nonatomic, readonly) SSKProtoCallMessageAnswer *answerMessage;
@property (nullable, nonatomic, readonly) NSArray<SSKProtoCallMessageIceUpdate *> *iceUpdateMessages;
@property (nullable, nonatomic, readonly) SSKProtoCallMessageHangup *hangupMessage;
@property (nullable, nonatomic, readonly) SSKProtoCallMessageBusy *busyMessage;
@property (nullable, nonatomic, readonly) SSKProtoCallMessageOpaque *opaqueMessage;
@property (nullable, nonatomic, readonly) NSNumber *destinationDeviceId;

@end

NS_ASSUME_NONNULL_END
