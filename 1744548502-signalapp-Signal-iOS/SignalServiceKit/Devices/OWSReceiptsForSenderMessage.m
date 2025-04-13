//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSReceiptsForSenderMessage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSReceiptsForSenderMessage ()

@property (nonatomic, readonly, nullable) NSSet<NSString *> *messageUniqueIds;
@property (nonatomic, readonly) NSArray<NSNumber *> *messageTimestamps;
@property (nonatomic, readonly) SSKProtoReceiptMessageType receiptType;

@end

#pragma mark -

@implementation OWSReceiptsForSenderMessage

+ (OWSReceiptsForSenderMessage *)deliveryReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                                 receiptSet:(MessageReceiptSet *)receiptSet
                                                                transaction:(DBReadTransaction *)transaction
{
    return [[OWSReceiptsForSenderMessage alloc] initWithThread:thread
                                                    receiptSet:receiptSet
                                                   receiptType:SSKProtoReceiptMessageTypeDelivery
                                                   transaction:transaction];
}

+ (OWSReceiptsForSenderMessage *)readReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                             receiptSet:(MessageReceiptSet *)receiptSet
                                                            transaction:(DBReadTransaction *)transaction
{
    return [[OWSReceiptsForSenderMessage alloc] initWithThread:thread
                                                    receiptSet:receiptSet
                                                   receiptType:SSKProtoReceiptMessageTypeRead
                                                   transaction:transaction];
}

+ (OWSReceiptsForSenderMessage *)viewedReceiptsForSenderMessageWithThread:(TSThread *)thread
                                                               receiptSet:(MessageReceiptSet *)receiptSet
                                                              transaction:(DBReadTransaction *)transaction
{
    return [[OWSReceiptsForSenderMessage alloc] initWithThread:thread
                                                    receiptSet:receiptSet
                                                   receiptType:SSKProtoReceiptMessageTypeViewed
                                                   transaction:transaction];
}

- (instancetype)initWithThread:(TSThread *)thread
                    receiptSet:(MessageReceiptSet *)receiptSet
                   receiptType:(SSKProtoReceiptMessageType)receiptType
                   transaction:(DBReadTransaction *)transaction
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];
    if (!self) {
        return self;
    }

    _messageUniqueIds = [receiptSet.uniqueIds copy];
    _messageTimestamps = [receiptSet.timestamps copy];
    _receiptType = receiptType;

    return self;
}

#pragma mark - TSOutgoingMessage overrides

- (BOOL)shouldSyncTranscript
{
    return NO;
}

- (BOOL)isUrgent
{
    return NO;
}

- (nullable SSKProtoContentBuilder *)contentBuilderWithThread:(TSThread *)thread
                                                  transaction:(DBReadTransaction *)transaction
{
    SSKProtoReceiptMessage *_Nullable receiptMessage = [self buildReceiptMessageWithTransaction:transaction];
    if (!receiptMessage) {
        OWSFailDebug(@"could not build protobuf.");
        return nil;
    }

    SSKProtoContentBuilder *contentBuilder = [SSKProtoContent builder];
    [contentBuilder setReceiptMessage:receiptMessage];
    return contentBuilder;
}

- (nullable SSKProtoReceiptMessage *)buildReceiptMessageWithTransaction:(DBReadTransaction *)transaction
{
    OWSAssertDebug(self.recipientAddresses.count == 1);
    OWSAssertDebug(self.messageTimestamps.count > 0);

    SSKProtoReceiptMessageBuilder *builder = [SSKProtoReceiptMessage builder];
    [builder setType:self.receiptType];
    for (NSNumber *messageTimestamp in self.messageTimestamps) {
        [builder addTimestamp:[messageTimestamp unsignedLongLongValue]];
    }

    return [builder buildInfallibly];
}

#pragma mark - TSYapDatabaseObject overrides

- (BOOL)shouldBeSaved
{
    return NO;
}

- (NSString *)debugDescription
{
    return [NSString
        stringWithFormat:@"[%@] with message timestamps: %lu", self.class, (unsigned long)self.messageTimestamps.count];
}

- (NSSet<NSString *> *)relatedUniqueIds
{
    if (self.messageUniqueIds) {
        return [[super relatedUniqueIds] setByAddingObjectsFromSet:self.messageUniqueIds];
    } else {
        return [super relatedUniqueIds];
    }
}

@end

NS_ASSUME_NONNULL_END
