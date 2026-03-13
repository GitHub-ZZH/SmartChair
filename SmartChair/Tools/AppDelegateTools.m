//
//  AppDelegateTools.m
//  UnityTest
//
//  Created by 张志恒 on 2026/1/8.
//

#import "AppDelegateTools.h"

@implementation AppDelegateTools

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static AppDelegateTools *_instance;
    dispatch_once(&onceToken, ^{
        _instance = [AppDelegateTools new];
    });
    return _instance;
}

@end
