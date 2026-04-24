//
//  UIApplication+Hook.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import "UIApplication+Hook.h"
#import <objc/runtime.h>
#import "GuideManager.h"

@implementation UIApplication (Hook)

+ (void)load {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        Method originalMethod = class_getInstanceMethod(self, @selector(sendEvent:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(hook_sendEvent:));

        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)hook_sendEvent:(UIEvent *)event {

    // 调用原方法
    [self hook_sendEvent:event];

    // 🔥 全局监听所有触摸（Unity 也逃不掉）
    if (event.type == UIEventTypeTouches) {
        [[GuideManager shared] resetTimer];
    }
}
 
@end
