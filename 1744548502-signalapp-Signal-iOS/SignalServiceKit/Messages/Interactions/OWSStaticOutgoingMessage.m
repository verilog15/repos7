//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSStaticOutgoingMessage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSStaticOutgoingMessage ()

@property (nonatomic, readonly) NSData *plaintextData;

@end

#pragma mark -

@implementation OWSStaticOutgoingMessage

- (instancetype)initWithThread:(TSThread *)thread
                     timestamp:(uint64_t)timestamp
                 plaintextData:(NSData *)plaintextData
                   transaction:(DBReadTransaction *)transaction
{
    TSOutgoingMessageBuilder *messageBuilder = [TSOutgoingMessageBuilder outgoingMessageBuilderWithThread:thread];
    messageBuilder.timestamp = timestamp;
    self = [super initOutgoingMessageWithBuilder:messageBuilder
                            additionalRecipients:@[]
                              explicitRecipients:@[]
                               skippedRecipients:@[]
                                     transaction:transaction];

    if (self) {
        _plaintextData = plaintextData;
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

- (nullable NSData *)buildPlainTextData:(TSThread *)thread transaction:(DBWriteTransaction *)transaction
{
    return self.plaintextData;
}

@end

NS_ASSUME_NONNULL_END
