//
//  HBVerifyReceiptService.h
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^VerifyCallback)(NSError * _Nullable error, NSDictionary * _Nullable receiptInfo);

@interface HBVerifyReceiptService : NSObject

/**
 App 专用共享密钥
 
 App 专用共享密钥是用于接收此 App 自动续订订阅收据的唯一代码。
 如果您需要将此 App 转让给其他开发人员，或者需要将主共享密钥设置为专用，可能需要使用 App 专用共享密钥。
 */
@property (nonatomic, copy) NSString *sharedSecretKey;

/// 从苹果方校验
/// @param transaction 需要校验的交易
/// @param user 用户
/// @param complete 对应的交易信息回调
- (void)verifyReceiptWith:(SKPaymentTransaction *)transaction user:(NSString * _Nullable)user complete:(VerifyCallback)complete;
- (void)verifyReceiptWith:(SKPaymentTransaction *)transaction complete:(VerifyCallback)complete;

/// 存于沙盒中的所有交易的校验信息
/// @param user 用户
+ (NSDictionary *)receiptInfosWithUser:(NSString * _Nullable)user;

@end

NS_ASSUME_NONNULL_END
