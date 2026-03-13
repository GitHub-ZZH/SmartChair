//
//  DeviceConnectView.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "DeviceConnectView.h"

@interface DeviceConnectView ()

@property(nonatomic, strong) UIView *connectionContainer;
@property(nonatomic, strong) UIActivityIndicatorView *connectionIndicator;
@property(nonatomic, strong) UILabel *connectionStatusLabel;

@end

@implementation DeviceConnectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupConnectionUI];
        
    }
    return self;
}


- (void)setupConnectionUI {
    // 连接容器
    self.connectionContainer = [[UIView alloc] init];
    self.connectionContainer.backgroundColor = [UIColor whiteColor];
    self.connectionContainer.layer.cornerRadius = 12;
    self.connectionContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.connectionContainer.layer.shadowOffset = CGSizeMake(0, 4);
    self.connectionContainer.layer.shadowOpacity = 0.08;
    self.connectionContainer.layer.shadowRadius = 8;
    [self addSubview:self.connectionContainer];
    
    // 连接指示器
    self.connectionIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.connectionIndicator.color = [UIColor colorWithRed:66/255.0 green:133/255.0 blue:244/255.0 alpha:1.0];
    [self.connectionContainer addSubview:self.connectionIndicator];
    
    // 连接状态文字
    self.connectionStatusLabel = [[UILabel alloc] init];
    self.connectionStatusLabel.text = @"正在连接设备...";
    self.connectionStatusLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:17];
    self.connectionStatusLabel.textColor = [UIColor colorWithRed:30/255.0 green:32/255.0 blue:41/255.0 alpha:1.0];
    [self.connectionContainer addSubview:self.connectionStatusLabel];
    
    // 设置约束
    [self setupConnectionConstraints];
}

- (void)setupConnectionConstraints {
    self.connectionContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // 连接容器约束（居中显示）
        [self.connectionContainer.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [self.connectionContainer.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.connectionContainer.widthAnchor constraintEqualToConstant:220],
        [self.connectionContainer.heightAnchor constraintEqualToConstant:120],
        
        // 指示器约束
        [self.connectionIndicator.centerXAnchor constraintEqualToAnchor:self.connectionContainer.centerXAnchor],
        [self.connectionIndicator.topAnchor constraintEqualToAnchor:self.connectionContainer.topAnchor constant:20],
        
        // 状态文字约束
        [self.connectionStatusLabel.centerXAnchor constraintEqualToAnchor:self.connectionContainer.centerXAnchor],
        [self.connectionStatusLabel.topAnchor constraintEqualToAnchor:self.connectionIndicator.bottomAnchor constant:15]
    ]];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self simulateDeviceConnection];
    });
}


- (void)simulateDeviceConnection {
    [self.connectionIndicator startAnimating];
    
    // 模拟2秒连接时间
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.connectionStatusLabel.text = @"连接成功！";
        
        // 显示成功动画
        [UIView animateWithDuration:0.5 animations:^{
            self.connectionIndicator.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.connectionContainer.alpha = 0.0;
                self.connectionContainer.transform = CGAffineTransformMakeScale(0.9, 0.9);
            } completion:^(BOOL finished) {
                [self.connectionContainer removeFromSuperview];
                
                // 显示设备全屏视图
                
            }];
        }];
    });
}


@end
