//
//  ToolUtils.m
//  SmartChair
//
//  Created by 张志恒 on 2026/1/4.
//

#import "ToolUtils.h"

#define kSettingsPasswordKey @"SettingsPassword"

@implementation ToolUtils

+ (instancetype)sharedInstance {
    static ToolUtils *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ToolUtils alloc] init];
    });
    return instance;
}

// 保存密码
+ (void)savePassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password
                                              forKey:kSettingsPasswordKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 读取密码
+ (NSString *)loadPassword {
    NSString *password = [[NSUserDefaults standardUserDefaults]
                          stringForKey:kSettingsPasswordKey];
    if (password.length == 0) {
        return @"888888";
    }
    return password;
}

@end
