//
//  HBIAPManager.h
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "HBProductService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^BuyProductIAPCallback)(BOOL bIsPurchased);
typedef void(^BuyProductCallback)(NSError * _Nullable error, SKPaymentTransaction * _Nullable transaction, NSDictionary * _Nullable receiptInfo);

@interface HBIAPManager : NSObject

/// 用于在内存中记录产品信息
@property (nonatomic, strong) HBProductService *productService;

+ (instancetype)sharedInstance;

/// 添加防漏单回调，必须先调用此方法
/// @param callback 如果校验成功，需要手动结束交易, 调用 [transaction finish];
- (void)addMissingOrderCallback:(void(^)(SKPaymentTransaction *transaction, NSDictionary *receiptInfo))callback;

/// 购买商品
/// @param product 商品信息
/// @param user 用户
/// @param iapCallback 内购的结果回调，同步于系统弹窗
/// @param complete 校验结果回调, 如果校验成功，需要手动结束交易，调用 [transaction finish];
- (void)buyProduct:(SKProduct *)product
              user:(NSString * _Nullable)user
       iapCallback:(BuyProductIAPCallback)iapCallback
          complete:(BuyProductCallback)complete;

- (void)buyProduct:(SKProduct *)product
       iapCallback:(BuyProductIAPCallback)iapCallback
          complete:(BuyProductCallback)complete;

/// 购买商品，用了过期的api
/// @param productId 商品id
/// @param user 用户
/// @param iapCallback 内购的结果回调，同步于系统弹窗
/// @param complete 校验结果回调, 如果校验成功，需要手动结束交易，调用 [transaction finish];
- (void)buyWidthProductId:(NSString *)productId
              user:(NSString * _Nullable)user
       iapCallback:(BuyProductIAPCallback)iapCallback
          complete:(BuyProductCallback)complete;

- (void)buyWidthProductId:(NSString *)productId
       iapCallback:(BuyProductIAPCallback)iapCallback
          complete:(BuyProductCallback)complete;

/// 恢复购买
- (void)restore;

@end

@interface SKPaymentTransaction (HBFinish)

/// 结束交易
- (void)finish;

@end

NS_ASSUME_NONNULL_END
