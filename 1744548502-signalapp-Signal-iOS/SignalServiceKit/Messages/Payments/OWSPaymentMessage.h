//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

#import <SignalServiceKit/TSPaymentModels.h>

@protocol OWSPaymentMessage
@required

// Properties
@property (nonatomic, readonly, nullable) TSPaymentNotification *paymentNotification;

@end
