//
//  HBProductService.h
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HBProductService : NSObject


/// 从苹果平台获取商品列表
/// @param identifiers 产品ids
/// @param complete 回调
- (void)fetchProducts:(NSArray<NSString *> *)identifiers
             complete:(void(^)(NSError * _Nullable error, SKProductsResponse * _Nullable response))complete;

/// 获取商品信息，若内存有，则直接返回，否则则从苹果平台拉取
/// @param indentifier 产品id
/// @param complete 回调
- (void)fetchProduct:(NSString *)indentifier
            complete:(void(^)(SKProduct * _Nullable product))complete;


@end

NS_ASSUME_NONNULL_END
