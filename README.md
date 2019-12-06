# HBIAPManager
In-App-Purchase


### 一、初始化 HBIAPManager

建议在 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions` 方法中调用初始化方法

```object-C
[HBIAPManager.sharedInstance addMissingOrderCallback:^(SKPaymentTransaction * _Nonnull transaction, NSDictionary * _Nonnull receiptInfo) {
    NSLog(@"这单漏掉了：\n%@", receiptInfo);
    [transaction finish];
}];
```

内部添加了 `SKPaymentQueue` 对 `SKPaymentTransactionObserver` 协议的监听，必须先调用此方法，同时这里也处理漏单的地方。参考 *购买商品* ，开发者可把这次交易的校验信息进行记录或者服务器核验，操作结束之后需结束本次交易，否则再次启动app里仍会走漏单流程。

<br>

### 二、查询苹果后台里的商品列表

```Object-C
[HBIAPManager.sharedInstance.productService fetchProducts:@[@"hejiawang07", @"hejiawang30", @"a00702e725e94d3a9691f456c5ee6027", @"92df4fafd3e04baf8c4165897c035f76"] complete:^(NSError * _Nullable error, SKProductsResponse * _Nullable response) {

}];
```

传入的不再是系统方法要求的集合，方便语法糖入参。

<br>

### 三、购买商品

```Object-C
[UIApplication.sharedApplication setNetworkActivityIndicatorVisible:true];
[HBIAPManager.sharedInstance buyProduct:pro iapCallback:^(BOOL bIsPurchased) {
    NSLog(@"购买%@", bIsPurchased ? @"成功" : @"失败");
    [UIApplication.sharedApplication setNetworkActivityIndicatorVisible:false];
} complete:^(NSError * _Nullable error, SKPaymentTransaction * _Nullable transaction, NSDictionary * _Nullable receiptInfo) {
    
    if (error || transaction.error) {
        NSLog(@"校验失败：%@", error ?: transaction.error);
    } else {
        NSLog(@"校验成功，对应信息为：\n%@", receiptInfo);
        
        /*
         校验成功之后，可以在此处把收据传给自己的服务器记录，或者再次校验
         成功之后需要结束本次交易
         */
        //结束交易
        [transaction finish];
    }
}];
```

调用购买商品的接口之后，会唤起系统的确认购买弹窗，在用户进行密码（指纹、人脸）校验并确认购买之后，若支付失败，则会结束本次交易；若支付成功，则会有回调放出，方便UI进行变更，之后会对交易在苹果端进行校验，校验成功之后将会把交易对应的校验信息返回，开发者可把此校验信息发送给自己的服务器进行存储或者校验，流程走通之后则需开发者手动结束本次交易，否则，当下次启动app时，这次交易将会走漏单流程。










