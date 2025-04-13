//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSViewedReceiptsForLinkedDevicesMessage.h"
#import "OWSLinkedDeviceReadReceipt.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSViewedReceiptsForLinkedDevicesMessage ()

@property (nonatomic, readonly) NSArray<OWSLinkedDeviceViewedReceipt *> *viewedReceipts;

@end

@implementation OWSViewedReceiptsForLinkedDevicesMessage

- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                     viewedReceipts:(NSArray<OWSLinkedDeviceViewedReceipt *> *)viewedReceipts
                        transaction:(DBReadTransaction *)transaction
{
    self = [super initWithLocalThread:localThread transaction:transaction];
    if (!self) {
        return self;
    }

    _viewedReceipts = [viewedReceipts copy];

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (BOOL)isUrgent
{
    return NO;
}

- (nullable SSKProtoSyncMessageBuilder *)syncMessageBuilderWithTransaction:(DBReadTransaction *)transaction
{
    SSKProtoSyncMessageBuilder *syncMessageBuilder = [SSKProtoSyncMessage builder];
    for (OWSLinkedDeviceViewedReceipt *viewedReceipt in self.viewedReceipts) {
        SSKProtoSyncMessageViewedBuilder *viewedProtoBuilder =
            [SSKProtoSyncMessageViewed builderWithTimestamp:viewedReceipt.messageIdTimestamp];

        [viewedProtoBuilder setSenderAci:viewedReceipt.senderAddress.aciString];

        NSError *error;
        SSKProtoSyncMessageViewed *_Nullable viewedProto = [viewedProtoBuilder buildAndReturnError:&error];
        if (error || !viewedProto) {
            OWSFailDebug(@"could not build protobuf: %@", error);
            return nil;
        }
        [syncMessageBuilder addViewed:viewedProto];
    }
    return syncMessageBuilder;
}

- (NSSet<NSString *> *)relatedUniqueIds
{
    NSMutableArray<NSString *> *messageUniqueIds = [[NSMutableArray alloc] init];
    for (OWSLinkedDeviceViewedReceipt *viewReceipt in self.viewedReceipts) {
        if (viewReceipt.messageUniqueId) {
            [messageUniqueIds addObject:viewReceipt.messageUniqueId];
        }
    }
    return [[super relatedUniqueIds] setByAddingObjectsFromArray:messageUniqueIds];
}

@end

@interface OWSLinkedDeviceViewedReceipt ()

@property (nonatomic, nullable, readonly) NSString *senderPhoneNumber;
@property (nonatomic, nullable, readonly) NSString *senderUUID;

@end

@implementation OWSLinkedDeviceViewedReceipt

- (instancetype)initWithSenderAci:(AciObjC *)senderAci
                  messageUniqueId:(nullable NSString *)messageUniqueId
               messageIdTimestamp:(uint64_t)messageIdTimestamp
                  viewedTimestamp:(uint64_t)viewedTimestamp
{
    OWSAssertDebug(messageIdTimestamp > 0);

    self = [super init];
    if (!self) {
        return self;
    }

    _senderPhoneNumber = nil;
    _senderUUID = senderAci.serviceIdUppercaseString;
    _messageUniqueId = messageUniqueId;
    _messageIdTimestamp = messageIdTimestamp;
    _viewedTimestamp = viewedTimestamp;

    return self;
}

- (SignalServiceAddress *)senderAddress
{
    return [SignalServiceAddress legacyAddressWithServiceIdString:self.senderUUID phoneNumber:self.senderPhoneNumber];
}

@end

NS_ASSUME_NONNULL_END
