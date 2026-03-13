//
//  AppDelegateTools.h
//  UnityTest
//
//  Created by 张志恒 on 2026/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegateTools : NSObject

+ (instancetype)instance;
@property(nonatomic, strong) NSDictionary *launchOptions;
@property(nonatomic, assign) int argc;
@property(nonatomic, assign) char * _Nonnull * _Nullable argv;

@property(nonatomic, strong) id ufw;

@end

NS_ASSUME_NONNULL_END
