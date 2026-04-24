//
//  AppDelegate.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/13.
//

#import "AppDelegate.h"
#import "AppDelegateTools.h"
#import "ViewController.h"
#import "MyBluetoothManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    AppDelegateTools.instance.launchOptions = launchOptions;
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSUUID *uuid = [MyBluetoothManager sharedInstance].savedUUID;
    if (uuid) {
        [ViewController switchToHomeVC:self.window];
    } else {
        ViewController *mainVc = [ViewController new];
        self.window.rootViewController = mainVc;
    }
    sleep(1);
    [self.window makeKeyAndVisible];
    
    [self checkAppExpireDate];
    
    return YES;
}

- (void)checkAppExpireDate {
    // 设置过期时间：2026-04-01 00:00:00（北京时间）
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year  = 2027;
    components.month = 4;
    components.day   = 1;
    components.hour  = 12;
    components.minute = 0;
    components.second = 0;

    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    NSDate *expireDate = [calendar dateFromComponents:components];
    NSDate *now = [NSDate date];

    if ([now compare:expireDate] != NSOrderedAscending) {
        // 已过期 → 崩溃
        abort();
    }
}

@end
