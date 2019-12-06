//
//  HBVerifyReceiptService.m
//  ByInApp
//
//  Created by 沈红榜 on 2019/12/3.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import "HBVerifyReceiptService.h"

@interface HBVerifyReceiptService ()<SKRequestDelegate>

//当本地拿不到票据时用的到
@property (nonatomic, strong) SKPaymentTransaction *currentTransaction;
@property (nonatomic, copy) VerifyCallback callback;

@end

@implementation HBVerifyReceiptService

- (void)verifyReceiptWith:(SKPaymentTransaction *)transaction complete:(VerifyCallback)complete {
    [self verifyReceiptWith:transaction user:nil complete:complete];
}

- (void)verifyReceiptWith:(SKPaymentTransaction *)transaction user:(NSString * _Nullable)user complete:(nonnull VerifyCallback)complete {
    
    NSDictionary *dic = [self receiptInfoWithTransactionId:transaction.transactionIdentifier user:user];
    
    if (dic) {
        !complete ?: complete(nil, dic);
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:NSBundle.mainBundle.appStoreReceiptURL];
    
    if (data.length == 0) {
        _callback = complete;
        _currentTransaction = transaction;
        //刷新
        SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
        request.delegate = self;
        [request start];
        return;
    }
    
#if DEBUG
    NSURL *url = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
#else
    NSURL *url = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
#endif
    
    NSString *receiptStr = [data base64EncodedStringWithOptions:0];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    param[@"receipt-data"] = receiptStr;
    param[@"password"] = _sharedSecretKey;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            !complete ?: complete(error, nil);
            return ;
        }
        
        NSError *er = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&er];
        
        if (er) {
            !complete ?: complete(er, nil);
            return;
        }
        
        NSString *key = [HBVerifyReceiptService keyFromUser:user];
        [NSUserDefaults.standardUserDefaults setObject:dic forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        NSDictionary *result = [weakSelf receiptInfoWithTransactionId:transaction.transactionIdentifier user:user];
        !complete ?: complete(nil, result);
        
    }];
    [task resume];
}

+ (NSDictionary *)receiptInfosWithUser:(NSString *)user {
    NSString *key = [HBVerifyReceiptService keyFromUser:user];

    NSDictionary *response = [NSUserDefaults.standardUserDefaults objectForKey:key];
    return response;
}

#pragma mark - SKRequestDelegate
- (void)requestDidFinish:(SKRequest *)request {
    [self verifyReceiptWith:_currentTransaction complete:_callback];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    !_callback ?: _callback(error, nil);
}

#pragma mark - helps
+ (NSString *)keyFromUser:(NSString * _Nullable)user {
    return [NSString stringWithFormat:@"hb_in_app_purchase_%@", user ?: @"hb"];
}

- (NSDictionary *)receiptInfoWithTransactionId:(NSString *)transactionId user:(NSString * _Nullable)user {
    
    NSDictionary *response = [HBVerifyReceiptService receiptInfosWithUser:user];

    NSInteger status = [response[@"status"] integerValue];
        
    if (status != 0) {
        return nil;
    }
    
    NSDictionary *receipt = response[@"receipt"];
    NSArray *inapp = receipt[@"in_app"];
    
    NSDictionary *checkDic = nil;
    
    for (NSDictionary *dic in inapp) {
        
        NSString *transaction_id = dic[@"transaction_id"];
        
        if ([transaction_id isEqualToString:transactionId]) {
            checkDic = dic;
            break;
        }
    }
    
    return checkDic;
}



@end
