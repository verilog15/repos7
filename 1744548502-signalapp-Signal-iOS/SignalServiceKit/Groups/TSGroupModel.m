//
// Copyright 2017 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import "TSGroupModel.h"
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

const NSUInteger kMaxEncryptedAvatarSize = 3 * 1024 * 1024;
const NSUInteger kMaxAvatarSize = (kMaxEncryptedAvatarSize
    /* The length of the padding. See GroupSecretParams:encrypt_blob_with_padding in LibSignal. */
    - sizeof(uint32_t)
    /* Overhead from GroupAttributeBlob (protobuf) via GroupV2Params.encryptGroupAvatar(_:). */
    /* One byte for "2:LEN" & 4 bytes to represent more than 2 MiB of data (2^21). */
    - 1
    - 4
    /* The padding bytes themselves. See ClientZkGroupCipher.encryptBlob(randomness:plaintext:). */
    - 0
    /* Encryption tag & nonce. See GroupSecretParams:encrypt_blob in LibSignal. */
    - 16
    - 12
    /* Reserved byte. See GroupSecretParams:encrypt_blob in LibSignal. */
    - 1);
const CGFloat kMaxAvatarDimension = 1024;
const NSUInteger kGroupIdLengthV1 = 16;
const NSUInteger kGroupIdLengthV2 = 32;

NSUInteger const TSGroupModelSchemaVersion = 2;

@interface TSGroupModel ()

@property (nonatomic, readonly) NSUInteger groupModelSchemaVersion;

@end

#pragma mark -

@implementation TSGroupModel

@synthesize groupName = _groupName;

#if TARGET_OS_IOS

- (instancetype)initWithGroupId:(NSData *)groupId
                           name:(nullable NSString *)name
                     avatarData:(nullable NSData *)avatarData
                        members:(NSArray<SignalServiceAddress *> *)members
                 addedByAddress:(nullable SignalServiceAddress *)addedByAddress
{
    self = [super init];
    if (!self) {
        return self;
    }

    _groupId = groupId;
    _groupName = name;
    _groupMembers = members;
    _addedByAddress = addedByAddress;
    _groupModelSchemaVersion = TSGroupModelSchemaVersion;

    if (avatarData) {
        NSError *error;
        [self persistAvatarData:avatarData error:&error];
        if (error) {
            OWSFailDebug(@"Failed to persist group avatar data %@", error);
        }
    }

    OWSAssertDebug([GroupManager isValidGroupId:groupId groupsVersion:self.groupsVersion]);

    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
#pragma clang diagnostic pop
    if (!self) {
        return self;
    }

    OWSAssertDebug([GroupManager isValidGroupId:self.groupId groupsVersion:self.groupsVersion]);

    if (_groupModelSchemaVersion < 1) {
        NSArray<NSString *> *_Nullable memberE164s = [coder decodeObjectForKey:@"groupMemberIds"];
        if (memberE164s) {
            NSMutableArray<SignalServiceAddress *> *memberAddresses = [NSMutableArray new];
            for (NSString *phoneNumber in memberE164s) {
                [memberAddresses addObject:[SignalServiceAddress legacyAddressWithServiceIdString:nil
                                                                                      phoneNumber:phoneNumber]];
            }
            _groupMembers = [memberAddresses copy];
        } else {
            _groupMembers = @[];
        }
    }

    if (_groupModelSchemaVersion < 2) {
        _legacyAvatarData = [coder decodeObjectForKey:@"groupAvatarData"];
    }

    _groupModelSchemaVersion = TSGroupModelSchemaVersion;

    return self;
}

- (GroupsVersion)groupsVersion
{
    return GroupsVersionV1;
}

- (GroupMembership *)groupMembership
{
    return [[GroupMembership alloc] initWithV1Members:self.groupMembers];
}

+ (BOOL)isValidGroupAvatarData:(nullable NSData *)imageData
{
    ImageMetadata *metadata = [imageData imageMetadataWithPath:nil mimeType:nil];

    BOOL isValid = YES;
    isValid = isValid && metadata.isValid;
    isValid = isValid && metadata.pixelSize.height <= kMaxAvatarDimension;
    isValid = isValid && metadata.pixelSize.width <= kMaxAvatarDimension;
    isValid = isValid && imageData.length <= kMaxAvatarSize;
    return isValid;
}

+ (nullable NSData *)dataForGroupAvatar:(nullable UIImage *)image
{
    if (image == nil) {
        return nil;
    }

    // First, resize the image if necessary
    if (image.pixelWidth > kMaxAvatarDimension || image.pixelHeight > kMaxAvatarDimension) {
        CGFloat thumbnailSizePixels = MIN(kMaxAvatarDimension, MIN(image.pixelWidth, image.pixelHeight));
        image = [image resizedImageToFillPixelSize:CGSizeMake(thumbnailSizePixels, thumbnailSizePixels)];
    }
    if (image.pixelWidth > kMaxAvatarDimension || image.pixelHeight > kMaxAvatarDimension) {
        OWSFailDebug(@"Could not resize group avatar.");
        return nil;
    }

    // Then, convert the image to jpeg. Try to use 0.6 compression quality, but we'll ratchet down if the
    // image is still too large.
    const CGFloat kMaxQuality = 0.6;
    NSData *_Nullable imageData = nil;
    for (CGFloat targetQuality = kMaxQuality; targetQuality >= 0 && imageData == nil; targetQuality -= 0.1) {
        NSData *data = UIImageJPEGRepresentation(image, targetQuality);

        if (data.length >= 0 && data.length <= kMaxAvatarSize) {
            imageData = data;
        } else if (data.length > kMaxAvatarSize) {
            OWSLogInfo(@"Jpeg representation with quality %f is too large.", targetQuality);
        } else {
            OWSFailDebug(@"Failed to generate jpeg representation with quality %f", targetQuality);
            return nil;
        }
    }

    // Double check the image is still valid after we converted.
    if (![self isValidGroupAvatarData:imageData]) {
        OWSFailDebug(@"Invalid image");
        return nil;
    }
    return imageData;
}

#endif

- (nullable NSString *)groupName
{
    return _groupName.filterStringForDisplay;
}

- (NSString *)groupNameOrDefault
{
    NSString *_Nullable groupName = [self.groupName filterStringForDisplay];
    return groupName.length > 0 ? groupName : TSGroupThread.defaultGroupName;
}

@end

NS_ASSUME_NONNULL_END
