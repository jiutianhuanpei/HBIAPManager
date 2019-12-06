//
//  HBIAPManager.m
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import "HBIAPManager.h"
#import "HBVerifyReceiptService.h"

@interface HBIAPManager ()<SKPaymentTransactionObserver>

@property (nonatomic, strong) NSMutableDictionary *iapCallback;
@property (nonatomic, strong) NSMutableDictionary *callbackDic;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, strong) NSMutableSet *verifySet;
@property (nonatomic, assign) BOOL bIsAddMissObserver;

@property (nonatomic, copy) void(^missingOrderCallback)(SKPaymentTransaction *transaction, NSDictionary *receiptInfo);

@end


@implementation HBIAPManager

+ (instancetype)sharedInstance {
    static HBIAPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = HBIAPManager.new;
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _iapCallback = @{}.mutableCopy;
        _callbackDic = @{}.mutableCopy;
    }
    return self;
}

- (void)addMissingOrderCallback:(void (^)(SKPaymentTransaction * _Nonnull, NSDictionary * _Nonnull))callback {
    _missingOrderCallback = callback;
    _bIsAddMissObserver = true;
    [SKPaymentQueue.defaultQueue addTransactionObserver:self];
}

+ (BOOL)canMakePayments {
    return SKPaymentQueue.canMakePayments;
}

- (void)buyWidthProductId:(NSString *)productId iapCallback:(BuyProductIAPCallback)iapCallback complete:(BuyProductCallback)complete {
    [self buyWidthProductId:productId user:nil iapCallback:iapCallback complete:complete];
}

- (void)buyWidthProductId:(NSString *)productId user:(NSString * _Nullable)user iapCallback:(BuyProductIAPCallback)iapCallback complete:(BuyProductCallback)complete {
    
    NSAssert(_bIsAddMissObserver, @"请先调用 - (void)addMissingOrderCallback: 方法添加漏单监听");
    
    if (productId.length == 0) {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"productID cannot be null" code:999 userInfo:nil];
            complete(error, nil, nil);
        }
        return;
    }
    
    if (![HBIAPManager canMakePayments]) {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"apple pay cannot make payments" code:999 userInfo:nil];
            complete(error, nil, nil);
        }
        return;
    }
    
    _iapCallback[productId] = iapCallback;
    _callbackDic[productId] = complete;
    _user = user;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations" // 这部分是用到的过期api
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productId];
#pragma clang diagnostic pop
    
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)buyProduct:(SKProduct *)product iapCallback:(BuyProductIAPCallback)iapCallback complete:(BuyProductCallback)complete {
    [self buyProduct:product user:nil iapCallback:iapCallback complete:complete];
}

- (void)buyProduct:(SKProduct *)product user:(NSString *)user iapCallback:(BuyProductIAPCallback)iapCallback complete:(BuyProductCallback)complete {
    
    NSAssert(_bIsAddMissObserver, @"请先调用 - (void)addMissingOrderCallback: 方法添加漏单监听");
    
    if (![HBIAPManager canMakePayments]) {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"apple pay cannot make payments" code:999 userInfo:nil];
            complete(error, nil, nil);
        }
        return;
    }
    
    _iapCallback[product.productIdentifier] = iapCallback;
    _callbackDic[product.productIdentifier] = complete;
    _user = user;
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [SKPaymentQueue.defaultQueue addPayment:payment];
}

- (void)restore {
    [SKPaymentQueue.defaultQueue restoreCompletedTransactions];
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *tempTrans in transactions) {
        
        BuyProductIAPCallback iapCallback = _iapCallback[tempTrans.payment.productIdentifier];
        
        switch (tempTrans.transactionState) {
            case SKPaymentTransactionStatePurchased:
                !iapCallback ?: iapCallback(true);
                [self p_didPurchased:queue transaction:tempTrans];
                break;
            case SKPaymentTransactionStateFailed:
                //交易失败，结束交易
                !iapCallback ?: iapCallback(false);
                [self p_finishTransaction:tempTrans];
                break;
            case SKPaymentTransactionStateRestored:
                !iapCallback ?: iapCallback(true);
                [self p_didPurchased:queue transaction:tempTrans];
                break;
            case SKPaymentTransactionStateDeferred:
                !iapCallback ?: iapCallback(false);
                break;
            default:
                break;
        }
    }
}

#pragma mark - private
- (void)p_didPurchased:(SKPaymentQueue *)queue transaction:(SKPaymentTransaction *)transaction {

    __block HBVerifyReceiptService *verify = HBVerifyReceiptService.new;
    __weak typeof(self) weakSelf = self;
    
    [verify verifyReceiptWith:transaction user:_user complete:^(NSError * _Nullable error, NSDictionary * _Nullable receiptInfo) {
        
        BuyProductCallback callback = weakSelf.callbackDic[transaction.payment.productIdentifier];
        
        if (error) {
            !callback ?: callback(error, transaction, nil);
            weakSelf.callbackDic[transaction.payment.productIdentifier] = nil;
            return ;
        }
        [weakSelf.verifySet removeObject:verify];
        
        
        if (callback) {
            callback(nil, transaction, receiptInfo);
        } else if (weakSelf.missingOrderCallback) {
            weakSelf.missingOrderCallback(transaction, receiptInfo);
        } else {
            //校验成功，结束交易
            [queue finishTransaction:transaction];
        }
    }];
    
    if (!_verifySet) {
        _verifySet = [NSMutableSet setWithCapacity:0];
    }
    [_verifySet addObject:verify];
}

- (void)p_finishTransaction:(SKPaymentTransaction *)transaction {
    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
    
    BuyProductCallback callback = _callbackDic[transaction.payment.productIdentifier];
    !callback ?: callback(transaction.error, transaction, nil);
    _callbackDic[transaction.payment.productIdentifier] = nil;
}

#pragma mark - getter
- (HBProductService *)productService {
    if (!_productService) {
        _productService = HBProductService.new;
    }
    return _productService;
}

#pragma mark - life circle
- (void)dealloc {
    _bIsAddMissObserver = false;
    [SKPaymentQueue.defaultQueue removeTransactionObserver:self];
}

@end

@implementation SKPaymentTransaction (HBFinish)

- (void)finish {
    [SKPaymentQueue.defaultQueue finishTransaction:self];
}

@end

