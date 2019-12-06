//
//  HBProductService.m
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import "HBProductService.h"

@interface HBProductService ()<SKProductsRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, SKProduct *> *productsDic;

@property (nonatomic, copy) void (^complete)(NSError * _Nullable, SKProductsResponse * _Nullable);

@end

@implementation HBProductService

- (void)fetchProducts:(NSArray<NSString *> *)identifiers complete:(void (^)(NSError * _Nullable, SKProductsResponse * _Nullable))complete {
    
    if (identifiers.count == 0) {
        NSError *er = [NSError errorWithDomain:@"id 不能为空" code:999 userInfo:nil];
        !complete ?: complete(er, nil);
        return;
    }
    
    _complete = complete;
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:identifiers]];
    request.delegate = self;
    [request start];
}

- (void)fetchProduct:(NSString *)indentifier complete:(void (^)(SKProduct * _Nullable))complete {
    
    if (indentifier.length == 0) {
        !complete ?: complete(nil);
        return;
    }
    
    SKProduct *p = self.productsDic[indentifier];
    if (p) {
        !complete ?: complete(p);
        return;
    }
    [self fetchProducts:@[indentifier] complete:^(NSError * _Nullable error, SKProductsResponse * _Nullable response) {
        if (response.products.count > 0) {
            !complete ?: complete(response.products.firstObject);
        } else {
            !complete ?: complete(nil);
        }
    }];
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for (SKProduct *pro in response.products) {
        self.productsDic[pro.productIdentifier] = pro;
    }
    !_complete ?: _complete(nil, response);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    !_complete ?: _complete(error, nil);
}

#pragma mark - getter
- (NSMutableDictionary<NSString *,SKProduct *> *)productsDic {
    if (!_productsDic) {
        _productsDic = [NSMutableDictionary dictionary];
    }
    return _productsDic;
}

@end
