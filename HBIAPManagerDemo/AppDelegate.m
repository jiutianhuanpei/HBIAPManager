//
//  AppDelegate.m
//  HBIAPManagerDemo
//
//  Created by 沈红榜 on 2019/12/6.
//  Copyright © 2019 沈红榜. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "HBIAPManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    [self.window makeKeyAndVisible];
    
    UINavigationController *naVC = [[UINavigationController alloc] initWithRootViewController:ViewController.new];
    self.window.rootViewController = naVC;
    
    
    [HBIAPManager.sharedInstance addMissingOrderCallback:^(SKPaymentTransaction * _Nonnull transaction, NSDictionary * _Nonnull receiptInfo) {
       NSLog(@"%@", NSThread.currentThread);
        NSLog(@"这单漏掉了：\n%@", receiptInfo);
        [transaction finish];
    }];
    
    return YES;
}




@end
