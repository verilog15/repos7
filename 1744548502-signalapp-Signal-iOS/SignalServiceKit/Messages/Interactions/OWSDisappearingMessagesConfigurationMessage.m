//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSDisappearingMessagesConfigurationMessage.h"
#import "OWSDisappearingMessagesConfiguration.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSDisappearingMessagesConfigurationMessage ()

@property (nonatomic, readonly) OWSDisappearingMessagesConfiguration *configuration;

@end

#pragma mark -

@implementation OWSDisappearingMessagesConfigurationMessage

- (BOOL)shouldBeSaved
{
    return NO;
}

- (BOOL)isUrgent
{
    return NO;
}

- (instancetype)initWithConfiguration:(OWSDisappearingMessagesConfiguration *)configuration
                               thread:(TSThread *)thread
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

    _configuration = configuration;

    return self;
}


- (nullable SSKProtoDataMessageBuilder *)dataMessageBuilderWithThread:(TSThread *)thread
                                                          transaction:(DBReadTransaction *)transaction
{
    SSKProtoDataMessageBuilder *_Nullable dataMessageBuilder = [super dataMessageBuilderWithThread:thread
                                                                                       transaction:transaction];
    if (!dataMessageBuilder) {
        return nil;
    }
    [dataMessageBuilder setTimestamp:self.timestamp];
    [dataMessageBuilder setFlags:SSKProtoDataMessageFlagsExpirationTimerUpdate];
    if (self.configuration.isEnabled) {
        [dataMessageBuilder setExpireTimer:self.configuration.durationSeconds];
    } else {
        [dataMessageBuilder setExpireTimer:0];
    }
    [dataMessageBuilder setExpireTimerVersion:self.configuration.timerVersion];

    return dataMessageBuilder;
}

@end

NS_ASSUME_NONNULL_END
