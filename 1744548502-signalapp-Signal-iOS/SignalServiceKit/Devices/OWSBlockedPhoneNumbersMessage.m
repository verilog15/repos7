//
// Copyright 2018 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "OWSBlockedPhoneNumbersMessage.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface OWSBlockedPhoneNumbersMessage ()

@property (nonatomic, readonly) NSArray<NSString *> *phoneNumbers;
@property (nonatomic, readonly) NSArray<NSString *> *uuids;
@property (nonatomic, readonly) NSArray<NSData *> *groupIds;

@end

@implementation OWSBlockedPhoneNumbersMessage

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    return [super initWithCoder:coder];
}

- (instancetype)initWithLocalThread:(TSContactThread *)localThread
                       phoneNumbers:(NSArray<NSString *> *)phoneNumbers
                         aciStrings:(NSArray<NSString *> *)aciStrings
                           groupIds:(NSArray<NSData *> *)groupIds
                        transaction:(DBReadTransaction *)transaction
{
    self = [super initWithLocalThread:localThread transaction:transaction];
    if (!self) {
        return self;
    }

    _phoneNumbers = [phoneNumbers copy];
    _uuids = [aciStrings copy];
    _groupIds = [groupIds copy];

    return self;
}

- (nullable SSKProtoSyncMessageBuilder *)syncMessageBuilderWithTransaction:(DBReadTransaction *)transaction
{
    SSKProtoSyncMessageBlockedBuilder *blockedBuilder = [SSKProtoSyncMessageBlocked builder];
    [blockedBuilder setNumbers:_phoneNumbers];
    [blockedBuilder setAcis:_uuids];
    [blockedBuilder setGroupIds:_groupIds];

    SSKProtoSyncMessageBlocked *blockedProto = [blockedBuilder buildInfallibly];

    SSKProtoSyncMessageBuilder *syncMessageBuilder = [SSKProtoSyncMessage builder];
    [syncMessageBuilder setBlocked:blockedProto];
    return syncMessageBuilder;
}

- (BOOL)isUrgent
{
    return NO;
}

@end

NS_ASSUME_NONNULL_END
