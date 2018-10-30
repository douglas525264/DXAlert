//
//  AppDelegate+ADExt.m
//  ChaiKD
//
//  Created by douglas on 2018/10/23.
//  Copyright © 2018 douglas. All rights reserved.
//

#import "UIResponder+ADExt.h"


@implementation UIResponder (ADExt)
+ (void)load {
    NSString *className = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GDAlertConfig" ofType:@"plist"]][@"AppDelegate"];
    if (!className) {
        className = @"AppDelegate";
    }
    DXSwizzleMethod2(NSClassFromString(className), @selector(dx_application:didFinishLaunchingWithOptions:), @selector(application:didFinishLaunchingWithOptions:));
    DXSwizzleMethod2(NSClassFromString(className), @selector(dx_applicationDidBecomeActive:), @selector(applicationDidBecomeActive:));

}

- (BOOL)dx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions  {
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];

    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GDAlertConfig" ofType:@"plist"]];
;
    
    NSString *appkey = dic[@"JPushAppKey"];
    [JPUSHService setupWithOption:launchOptions appKey:appkey
                          channel:@"pushChannel1"
                 apsForProduction:NO
            advertisingIdentifier:nil];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
   
    [self addAD];
    [[ADManager shareInstance] prloadAD];
    

    return [self dx_application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)addAD {
#ifdef ISPRO
#else
    //这里 拉取广告信息
#endif
}
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    
    NSDictionary * userInfo = [notification userInfo];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    if ([dic objectForKey:@"adtype"]) {
        NSUserDefaults *de = [NSUserDefaults standardUserDefaults] ;
        [de setValue:[dic objectForKey:@"adtype"] forKey:@"showADType"];
        [de synchronize];
    }
    //    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    //    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
    NSLog(@"get msg : %@",userInfo);
}
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
//    UNNotificationRequest *request = notification.request; // 收到推送的请求
//    UNNotificationContent *content = request.content; // 收到推送的消息内容
//
//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
//    NSString *title = content.title;  // 推送消息的标题
//
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    } // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    [JPUSHService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"GetToken");
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)dx_applicationDidBecomeActive:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [self dx_applicationDidBecomeActive:application];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

@end
