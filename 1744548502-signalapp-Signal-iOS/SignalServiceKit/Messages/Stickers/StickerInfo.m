//
// Copyright 2019 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "StickerInfo.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation StickerInfo

- (instancetype)initWithPackId:(NSData *)packId packKey:(NSData *)packKey stickerId:(UInt32)stickerId
{
    self = [super init];

    if (!self) {
        return self;
    }

    _packId = packId;
    _packKey = packKey;
    _stickerId = stickerId;

    OWSAssertDebug(self.isValid);

    return self;
}

- (NSString *)asKey
{
    return [StickerInfo keyWithPackId:self.packId stickerId:self.stickerId];
}

+ (NSString *)keyWithPackId:(NSData *)packId stickerId:(UInt32)stickerId
{
    return [NSString stringWithFormat:@"%@.%lu", packId.hexadecimalString, (unsigned long)stickerId];
}

+ (StickerInfo *)defaultValue
{
    return [[StickerInfo alloc] initWithPackId:[Randomness generateRandomBytes:16]
                                       packKey:[Randomness generateRandomBytes:StickerManager.packKeyLength]
                                     stickerId:0];
}

- (StickerPackInfo *)packInfo
{
    return [[StickerPackInfo alloc] initWithPackId:self.packId packKey:self.packKey];
}

- (BOOL)isValid
{
    return (self.packId.length > 0 && self.packKey.length == StickerManager.packKeyLength);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, %d", self.packId.hexadecimalString, (int)self.stickerId];
}

@end

NS_ASSUME_NONNULL_END
