//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSOutgoingSyncMessage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation OWSOutgoingSyncMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (instancetype)initWithLocalThread:(TSContactThread *)localThread transaction:(DBReadTransaction *)transaction
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:localThread];
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];

    if (!self) {
        return self;
    }

    return self;
}

- (instancetype)initWithTimestamp:(uint64_t)timestamp
                      localThread:(TSContactThread *)localThread
                      transaction:(DBReadTransaction *)transaction
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:localThread];
    messageBuilder.timestamp = timestamp;
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];

    if (!self) {
        return self;
    }

    return self;
}

- (BOOL)shouldBeSaved
{
    return NO;
}

- (BOOL)shouldSyncTranscript
{
    return NO;
}

// This method should not be overridden, since we want to add random padding to *every* sync message
- (nullable SSKProtoSyncMessage *)buildSyncMessageWithTransaction:(DBReadTransaction *)transaction
{
    SSKProtoSyncMessageBuilder *_Nullable builder = [self syncMessageBuilderWithTransaction:transaction];
    if (!builder) {
        return nil;
    }

    NSError *error;
    SSKProtoSyncMessage *_Nullable proto = [[self class] buildSyncMessageProtoForMessageBuilder:builder error:&error];

    if (error || !proto) {
        OWSFailDebug(@"could not build protobuf: %@", error);
        return nil;
    }

    return proto;
}

- (nullable SSKProtoSyncMessageBuilder *)syncMessageBuilderWithTransaction:(DBReadTransaction *)transaction
{
    OWSAbstractMethod();

    return [SSKProtoSyncMessage builder];
}

- (nullable SSKProtoContentBuilder *)contentBuilderWithThread:(TSThread *)thread
                                                  transaction:(DBReadTransaction *)transaction
{
    SSKProtoSyncMessage *_Nullable syncMessage = [self buildSyncMessageWithTransaction:transaction];
    if (!syncMessage) {
        return nil;
    }

    SSKProtoContentBuilder *contentBuilder = [SSKProtoContent builder];
    [contentBuilder setSyncMessage:syncMessage];
    return contentBuilder;
}

+ (nullable SSKProtoSyncMessage *)buildSyncMessageProtoForMessageBuilder:
                                      (SSKProtoSyncMessageBuilder *)syncMessageBuilder
                                                                   error:(NSError **)errorHandle
{
    // Add a random 1-512 bytes to obscure sync message type
    size_t paddingBytesLength = arc4random_uniform(512) + 1;
    syncMessageBuilder.padding = [Randomness generateRandomBytes:paddingBytesLength];

    return [syncMessageBuilder buildAndReturnError:errorHandle];
}

@end

NS_ASSUME_NONNULL_END
