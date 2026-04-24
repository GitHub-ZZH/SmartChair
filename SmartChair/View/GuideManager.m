//
//  GuideManager.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import "GuideManager.h"

@implementation GuideManager

+ (instancetype)shared {
    static GuideManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GuideManager alloc] init];
    });
    return instance;
}

#pragma mark - 开始监听

- (void)startMonitor {
    [self resetTimer];
    
    // 监听全局触摸事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidInteract)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)resetTimer {
    [self.timer invalidate];
    self.timer = nil;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:60*5
                                                  target:self
                                                selector:@selector(sendZeroAction)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)sendZeroAction
{
    //开关关闭时，定时器也在持续运行
    bool isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"zeroAutoPlay"];
    if (isOpen == NO) {
        NSLog(@"=========开关关闭，重置定时器");
        [self resetTimer];
        return;
    }
    
    NSString *zeroKey = @"lastZeroAction";
    
    NSString *lastAction = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastZeroAction"];
    if ([lastAction isEqualToString:@"zeroOn"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotice_ZeroGravityOff" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"zeroOff" forKey:zeroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotice_ZeroGravityOn" object:nil];
        [[NSUserDefaults standardUserDefaults] setObject:@"zeroOn" forKey:zeroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSLog(@"==============重置定时器，发送零重力");
    
    [self resetTimer];
}

- (void)showGuide {

    UIWindow *window = UIApplication.sharedApplication.keyWindow;

    if (!self.guideView) {
        self.guideView = [[GuideView alloc] initWithFrame:window.bounds];

        __weak typeof(self) weakSelf = self;
        self.guideView.onDismiss = ^{
            // 🔥 点击后重新开始计时
            [weakSelf resetTimer];
        };
    }

    if (!self.guideView.superview) {
        self.guideView.alpha = 0;
        [window addSubview:self.guideView];

        [UIView animateWithDuration:0.2 animations:^{
            self.guideView.alpha = 1;
        }];
    }
}

@end
