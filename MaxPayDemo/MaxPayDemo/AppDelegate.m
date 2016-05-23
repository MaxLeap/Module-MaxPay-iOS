//
//  AppDelegate.m
//  MaxPayDemo
//
//  Created by 周和生 on 16/5/23.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"


@import MaxLeap;
@import MaxLeapPay;

#define kMaxLeap_Application_ID @"569f03c860b2563b4641f1d4"
#define kMaxLeap_Client_Key @"RnlZSjNVYUdDNEJ5NlZkLVpVRUs0QQ"

#define WECHAT_APPID            @"wx85fcd0162fdd8c11"


@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate

#pragma mark payment delegate and methods

- (void)onResp:(BaseResp*)resp {
    // 将 PayResponse 交给 MaxLeapPay 处理
    if ([resp isKindOfClass:[PayResp class]]) {
        [MaxLeapPay handleWXPayResponse:(PayResp *)resp];
    }
}

// iOS 4.2 -- iOS 8.4
// 如果需要兼容 iOS 6, iOS 7, iOS 8，需要实现这个代理方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
}

// iOS 9.0 or later
// iOS 9 以及更新版本会优先调用这个代理方法，如果没有实现这个，则会调用上面那个
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:  (NSDictionary<NSString *,id> *)options {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MaxLeap setApplicationId:kMaxLeap_Application_ID clientKey:kMaxLeap_Client_Key site:MLSiteCN];
    [MaxLeapPay setWXAppId:WECHAT_APPID wxDelegate:self description:@"Payment sample"];


    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
