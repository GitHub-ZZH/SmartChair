//
//  GlobalToast.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/23.
//

#import "GlobalToast.h"
#import <UIKit/UIKit.h>

@implementation GlobalToast

static UIWindow *_toastWindow = nil;

+ (UIWindow *)toastWindow {
    if (!_toastWindow) {
        _toastWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _toastWindow.windowLevel = UIWindowLevelAlert + 1;
        _toastWindow.backgroundColor = [UIColor clearColor];

        // 👇 必须设置 rootViewController（iOS13+ 很关键）
        UIViewController *vc = [UIViewController new];
        vc.view.backgroundColor = UIColor.clearColor;
        _toastWindow.rootViewController = vc;

        [_toastWindow makeKeyAndVisible];
    }
    return _toastWindow;
}

+ (void)show:(NSString *)message {
    [self show:message duration:2.0];
}

+ (void)show:(NSString *)message duration:(NSTimeInterval)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window = [self toastWindow];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = message;
        label.textColor = UIColor.whiteColor;
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.layer.cornerRadius = 8;
        label.clipsToBounds = YES;
        
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40;
        CGSize size = [label sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        
        label.frame = CGRectMake(0, 0, size.width + 20, size.height + 16);
        label.center = window.center;
        
        [window addSubview:label];
        
        label.alpha = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            label.alpha = 1;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.25 animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
                _toastWindow.hidden = YES;
                _toastWindow = nil;
            }];
            
        });
    });
}

@end
