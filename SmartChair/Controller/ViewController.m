//
//  ViewController.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/13.
//

#import "ViewController.h"
#import "DeviceViewController.h"
#import "HomeViewController.h"
#import "DeviceListVC.h"
#import "MyBluetoothManager.h"
#import <Masonry/Masonry.h>

@interface ViewController ()<DeviceListVCDelegate>

@property (nonatomic, strong) UIImageView *deviceImageView;
@property (nonatomic, strong) UILabel *titleLabel;
//@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *addDeviceButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupConstraints];
    [self setupAnimations];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}

- (void)setupUI {
    // 背景色
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    // 设备插图
    self.deviceImageView = [[UIImageView alloc] init];
    self.deviceImageView.image = [UIImage imageNamed:@"no_device"]; // 请替换为实际图片
    self.deviceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.deviceImageView];
    
    // 标题标签
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"暂无已添加设备";
    self.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:22];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
//    // 副标题标签
//    self.subtitleLabel = [[UILabel alloc] init];
//    self.subtitleLabel.text = @"添加设备后即可在这里查看和管理";
//    self.subtitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
//    self.subtitleLabel.textColor = [UIColor colorWithRed:148/255.0 green:153/255.0 blue:164/255.0 alpha:1.0];
//    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:self.subtitleLabel];

    
    // 添加设备按钮
    self.addDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addDeviceButton setTitle:@"添加设备" forState:UIControlStateNormal];
    [self.addDeviceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.addDeviceButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    self.addDeviceButton.layer.cornerRadius = 28;
    self.addDeviceButton.layer.masksToBounds = YES;
    self.addDeviceButton.backgroundColor = [UIColor blueColor];
    
    // 按钮点击事件
    [self.addDeviceButton addTarget:self action:@selector(addDeviceButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.addDeviceButton];
}

- (void)setupConstraints {
    // 禁用autoresizingMask
    self.deviceImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.addDeviceButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 设备插图约束
    [NSLayoutConstraint activateConstraints:@[
        [self.deviceImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.deviceImageView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:60],
        [self.deviceImageView.widthAnchor constraintEqualToConstant:240],
        [self.deviceImageView.heightAnchor constraintEqualToConstant:180]
    ]];
    
    // 标题标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:100],
        [self.titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:40],
        [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-40]
    ]];
    
//    // 副标题标签约束
//    [NSLayoutConstraint activateConstraints:@[
//        [self.subtitleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
//        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12],
//        [self.subtitleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:40],
//        [self.subtitleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-40]
//    ]];
    
    // 添加设备按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.addDeviceButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.addDeviceButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-40],
        [self.addDeviceButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:200],
        [self.addDeviceButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-200],
        [self.addDeviceButton.heightAnchor constraintEqualToConstant:56]
    ]];
    
//    // 调整按钮图片和文字间距
//    self.addDeviceButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
//    self.addDeviceButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
}

- (void)setupAnimations {
    // 初始状态
    self.deviceImageView.alpha = 0.0;
    self.deviceImageView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    
    self.titleLabel.alpha = 0.0;
    self.titleLabel.transform = CGAffineTransformMakeTranslation(0, 20);
    
//    self.subtitleLabel.alpha = 0.0;
//    self.subtitleLabel.transform = CGAffineTransformMakeTranslation(0, 20);
    
//    self.addDeviceButton.alpha = 0.0;
//    self.addDeviceButton.transform = CGAffineTransformMakeTranslation(0, 40);
    
    // 动画序列
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.deviceImageView.alpha = 1.0;
            self.deviceImageView.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.titleLabel.alpha = 1.0;
            self.titleLabel.transform = CGAffineTransformIdentity;
        } completion:nil];
    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self.subtitleLabel.alpha = 1.0;
//            self.subtitleLabel.transform = CGAffineTransformIdentity;
//        } completion:nil];
//    });
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self.addDeviceButton.alpha = 1.0;
//            self.addDeviceButton.transform = CGAffineTransformIdentity;
//        } completion:nil];
//    });
    
//    // 按钮呼吸动画
//    [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.addDeviceButton.layer.shadowRadius = 20;
//            self.addDeviceButton.layer.shadowOpacity = 0.4;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                self.addDeviceButton.layer.shadowRadius = 16;
//                self.addDeviceButton.layer.shadowOpacity = 1.0;
//            } completion:nil];
//        }];
//    }];
}

#pragma mark - 按钮点击事件

- (void)addDeviceButtonTapped {
    
    DeviceListVC *vc = [DeviceListVC new];
    vc.delegate = self;
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:vc animated:YES completion:nil];
    
}

#pragma mark -
- (void)connectSuccess:(NSString *)uuid
{
    [[MyBluetoothManager sharedInstance] saveDeviceUUID:uuid];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [ViewController switchToHomeVC:window];
}

+ (void)switchToHomeVC:(UIWindow *)keyWindow
{
//    HomeViewController *homeVC = [HomeViewController new];
//    window.rootViewController = homeVC;
    
    DeviceViewController *homeVC = [DeviceViewController new];
    UINavigationController *nav =
        [[UINavigationController alloc] initWithRootViewController:homeVC];
    keyWindow.rootViewController = nav;

    NSLog(@"切换根控制器。。。。。");
    // 可选：切换动画
    [UIView transitionWithView:keyWindow
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:nil];
}


@end
