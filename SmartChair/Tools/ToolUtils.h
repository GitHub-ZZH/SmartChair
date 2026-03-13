//
//  ToolUtils.h
//  SmartChair
//
//  Created by 张志恒 on 2026/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToolUtils : NSObject

+ (instancetype)sharedInstance;

// 保存密码
+ (void)savePassword:(NSString *)password;
// 读取密码
+ (NSString *)loadPassword;

@end

NS_ASSUME_NONNULL_END
