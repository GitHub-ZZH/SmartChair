//
//  DeviceViewController.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "DeviceViewController.h"
#import <Masonry/Masonry.h>
#import "DeviceControlView.h"
#import "DeviceConnectView.h"
#import "DeviceMemoryView.h"
#import "DeviceSettingViewController.h"
#import "MyBluetoothManager.h"
#import "BluetoothMessage.h"
#import "SideViewController.h"
#import "AppDelegateTools.h"
#import "TouchPassthroughView.h"
#import "LanguageManager.h"
#import <UnityFramework/UnityFramework.h>
#import "GlobalToast.h"
#import "GuideManager.h"

#define kMainColor [UIColor colorWithRed:225/255.0 green:136/255.0 blue:49/255.0 alpha:1]

@interface DeviceViewController ()

@property(nonatomic, strong) UIWindow *keyWindow;
@property(nonatomic, strong) id ufw;

@property(nonatomic, strong) TouchPassthroughView *touchView;

// 连接状态相关
@property (nonatomic, strong) DeviceConnectView *connectionContainer;

// 设备显示相关
@property (nonatomic, strong) UIImageView *deviceFullScreenView;

@property(nonatomic, strong) UIButton *buttonSetting;
@property(nonatomic, strong) UILabel *labelProgress;
@property(nonatomic, strong) UIView *leftControlView;
@property(nonatomic, strong) UIView *rightContolView;
@property(nonatomic, strong) UIView *bottomControlView;
@property(nonatomic, strong) UIWindow *alertWindow;
@property(nonatomic, strong) UIView *viewHorizontal;
@property(nonatomic, strong) UIView *viewHeight;
@property(nonatomic, strong) UIView *viewBackrest;
@property(nonatomic, strong) UIView *viewSeat;
@property(nonatomic, strong) UIView *viewLegrest;

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = kMainColor;
    
//    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    
    [self buildNavItem];
    
//    [self setupConnectionUI];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self connectDevice];
        
        NSLog(@"绘制。。。。。。。。。");
        [self setupDeviceDisplayUI];
        
//        [self testView];
    });

    /*
    [self buildLeftControlItem];
    [self buildRightControlItem];
    [self buildSwitchItem];
//    [self buildMemoryItem];
    
    [self showDeviceFullScreenView];
    [self buildMotorList];
    */
    
    [[GuideManager shared] startMonitor];
    /* 隐藏
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[GuideManager shared] startMonitor];
        // 🔥 启动立即显示一次
        [[GuideManager shared] showGuide];
    });
     */
}

- (void)testView
{
    UIWindow *unityWindow = [self.ufw appController].window;
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    playBtn.frame = CGRectMake(200, 100, 100, 50);
    playBtn.backgroundColor = [UIColor blueColor];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(testAction)
     forControlEvents:UIControlEventTouchUpInside];
    [unityWindow addSubview:playBtn];
    
    // 3️⃣ UIKit 按钮
    UIButton *playBtn22 = [UIButton buttonWithType:UIButtonTypeSystem];
    playBtn22.frame = CGRectMake(200, 200, 100, 50);
    playBtn22.backgroundColor = [UIColor blueColor];
    [playBtn22 setTitle:@"复位" forState:UIControlStateNormal];
    [playBtn22 addTarget:self action:@selector(testAction222)
     forControlEvents:UIControlEventTouchUpInside];
    [unityWindow addSubview:playBtn22];
    
    
//    UISwitch *switchButton = [[UISwitch alloc] init];
////    [view addSubview:switchButton];
//    [switchButton addTarget:self action:@selector(testAction) forControlEvents:UIControlEventValueChanged];
//    switchButton.frame = CGRectMake(200, 200, 30, 20);
//    [self.touchView addSubview:switchButton];
//    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(view);
//        make.top.equalTo(label.mas_bottom).offset(5);;
//    }];
//    self.touchView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    self.touchView.touchableViews = @[playBtn22];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.view addSubview:self.touchView];
        NSLog(@"========%@", self.view.subviews);
    });
}

- (void)testAction
{
    NSLog(@"=======testAction");
    
    [self.ufw sendMessageToGOWithName:"零重力"
                         functionName:"Play"
                              message:"1"];

}
- (void)testAction222
{
    NSLog(@"=======testAction");
    
    [self.ufw sendMessageToGOWithName:"高度调节倾斜"
                         functionName:"ExitCurrent"
                              message:"1"];
}

// - (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
////    [[MyBluetoothManager sharedInstance] startScan];
//}

- (void)connectDevice
{
    NSUUID *uuid = [MyBluetoothManager sharedInstance].savedUUID;
    
    [[MyBluetoothManager sharedInstance] setOnDiscoverPeripheral:^(CBPeripheral * _Nonnull peripheral, NSDictionary * _Nonnull advertisementData, NSNumber * _Nonnull RSSI) {
        if ([peripheral.identifier.UUIDString isEqualToString:uuid.UUIDString]) {
            [[MyBluetoothManager sharedInstance] connectDeviceWith:peripheral];
            [[MyBluetoothManager sharedInstance] stopScan];
        }
    }];
    [[MyBluetoothManager sharedInstance] connectDeviceWithUUID:uuid];
    [[MyBluetoothManager sharedInstance] setOnConnectSuccess:^(CBPeripheral * _Nonnull peripheral) {
        self.navigationItem.title = @"智能座椅+连接成功";
        [[MyBluetoothManager sharedInstance] stopScan];
    }];
    [[MyBluetoothManager sharedInstance] setOnConnectFail:^(CBPeripheral * _Nullable peripheral, NSError * _Nullable error) {
        self.navigationItem.title = @"智能座椅+连接失败";
    }];
}

- (void)buildNavItem {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];   // 不透明背景（常用）
    appearance.backgroundColor = kMainColor; // 自定义颜色
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size:24]};

    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.standardAppearance = appearance;
    navBar.scrollEdgeAppearance = appearance;  // 解决大标题滚动颜色不一致
    navBar.compactAppearance = appearance;

    navBar.tintColor = UIColor.whiteColor; // 返回按钮颜色
    
    /*
    self.navigationItem.title = @"智能座椅";
    
    self.navigationItem.leftBarButtonItem = nil;
    
    UIBarButtonItem *itemLanguage = [[UIBarButtonItem alloc] initWithTitle:@"中英文切换" style:UIBarButtonItemStyleDone target:self action:@selector(buttonLanguageAction)];
    UIBarButtonItem *itemSetting = [[UIBarButtonItem alloc] initWithTitle:@"后台设置" style:UIBarButtonItemStyleDone target:self action:@selector(buttonRightAction)];
    */
//    self.navigationItem.rightBarButtonItems = @[itemSetting,/*itemLanguage*/];
}

- (void)buildLeftControlItem {
    CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.leftControlView = [[UIView alloc] init];
    [self.view addSubview:self.leftControlView];
    [self.leftControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(120);
        make.top.equalTo(self.view).offset(statusHeight+navbarHeight);
        make.bottom.equalTo(self.view);
        make.width.mas_equalTo(150);
    }];
    
    DeviceControlView *view1 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:1
                                button1:@{@"title":@"向前", @"tag":@(SeatKey_BackForward)}
                                button2:@{@"title":@"向后", @"tag":@(SeatKey_BackBackward)}
                                isRight:NO];
    [self.leftControlView addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftControlView);
        make.size.mas_equalTo(CGSizeMake(130, 80));
        make.top.equalTo(self.leftControlView).offset(30);
    }];
    
    DeviceControlView *view2 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:2
                                button1:@{@"title":@"上移", @"tag":@(SeatKey_LumbarUp)}
                                button2:@{@"title":@"下移", @"tag":@(SeatKey_LumbarDown)}
                                isRight:NO];
    [self.leftControlView addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view1.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view3 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:3
                                button1:@{@"title":@"左移", @"tag":@(SeatKey_LumbarLeft)}
                                button2:@{@"title":@"右移", @"tag":@(SeatKey_LumbarRight)}
                                isRight:NO];
    [self.leftControlView addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view2.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view4 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:4
                                button1:@{@"title":@"抬高", @"tag":@(SeatKey_CushionTiltUp)}
                                button2:@{@"title":@"降低", @"tag":@(SeatKey_CushionTiltDown)}
                                isRight:NO];
    [self.leftControlView addSubview:view4];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view3.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view5 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:5
                                button1:@{@"title":@"升高", @"tag":@(SeatKey_CushionUp)}
                                button2:@{@"title":@"降低", @"tag":@(SeatKey_CushionDown)}
                                isRight:NO];
    [self.leftControlView addSubview:view5];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view4.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view6 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:6
                                button1:@{@"title":@"前移", @"tag":@(SeatKey_CushionForward)}
                                button2:@{@"title":@"后移", @"tag":@(SeatKey_CushionBackward)}
                                isRight:NO];
    [self.leftControlView addSubview:view6];
    [view6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view5.mas_bottom).offset(15);
    }];
}

- (void)buildRightControlItem {
    CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.rightContolView = [[UIView alloc] init];
    [self.view addSubview:self.rightContolView];
    [self.rightContolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-100);
        make.top.equalTo(self.view).offset(statusHeight+navbarHeight);
        make.bottom.equalTo(self.view);
        make.width.mas_equalTo(150);
    }];
    
    DeviceControlView *view1 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:7
                                button1:@{@"title":@"伸出", @"tag":@(SeatKey_LegExtend)}
                                button2:@{@"title":@"回缩", @"tag":@(SeatKey_LegRetract)}
                                isRight:YES];
    [self.rightContolView addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightContolView);
        make.size.mas_equalTo(CGSizeMake(130, 80));
        make.top.equalTo(self.rightContolView).offset(30);
    }];
    
    DeviceControlView *view2 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:8
                                button1:@{@"title":@"抬高", @"tag":@(SeatKey_LegUp)}
                                button2:@{@"title":@"降低", @"tag":@(SeatKey_LegDown)}
                                isRight:YES];
    [self.rightContolView addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view1.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view3 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:9
                                button1:@{@"title":@"上移", @"tag":@(SeatKey_HeadrestUp)}
                                button2:@{@"title":@"下移", @"tag":@(SeatKey_HeadrestDown)}
                                isRight:YES];
    [self.rightContolView addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view2.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view4 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:101
                                button1:@{@"title":@"启动", @"tag":@(SeatKey_Memory1Start)}
                                button2:@{@"title":@"设置", @"tag":@(SeatKey_Memory1Set)}
                                isRight:YES];
    [self.rightContolView addSubview:view4];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view3.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view5 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:102
                                button1:@{@"title":@"启动", @"tag":@(SeatKey_Memory2Start)}
                                button2:@{@"title":@"设置", @"tag":@(SeatKey_Memory2Set)}
                                isRight:YES];
    [self.rightContolView addSubview:view5];
    [view5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view4.mas_bottom).offset(15);
    }];
    
    DeviceControlView *view6 = [[DeviceControlView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:201
                                button1:@{@"title":@"开启", @"tag":@(SeatKey_ZeroGravityOn)}
                                button2:@{@"title":@"复位", @"tag":@(SeatKey_ZeroGravityReset)}
                                isRight:YES];
    [self.rightContolView addSubview:view6];
    [view6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1);
        make.size.equalTo(view1);
        make.top.equalTo(view5.mas_bottom).offset(15);
    }];
}

- (void)setupConnectionUI{
    self.connectionContainer = [[DeviceConnectView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.connectionContainer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showDeviceFullScreenView];
    });
}

-(void)buildSwitchItem {
    UIView *bottomView = [[UIView alloc] init];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.height.mas_equalTo(70);
        make.centerX.equalTo(self.view);
    }];
    self.bottomControlView = bottomView;
    
    UIView *view1 = [self switchViewWith:@"安全带预警" select:@selector(switchAction1:)];
    [bottomView addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView);
        make.size.mas_equalTo(CGSizeMake(100, 70));
        make.bottom.equalTo(bottomView);
    }];
    
    UIView *view2 = [self switchViewWith:@"背部按摩" select:@selector(switchAction2:)];
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1.mas_right).offset(10);
        make.size.equalTo(view1);
        make.bottom.equalTo(view1);
    }];
    
    UIView *view3 = [self switchViewWith:@"座椅通风" select:@selector(switchAction3:)];
    [self.view addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view2.mas_right).offset(10);
        make.size.equalTo(view1);
        make.bottom.equalTo(view1);
    }];
    
    UIView *view4 = [self switchViewWith:@"座椅快调" select:@selector(switchAction4:)];
    [self.view addSubview:view4];
    [view4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view3.mas_right).offset(10);
        make.size.equalTo(view1);
        make.bottom.equalTo(view1);
        make.right.equalTo(bottomView);
    }];
    
}

- (void)buildMemoryItem
{
    
    UIView *view1 = [[UIView alloc] init];
    [self.view addSubview:view1];
    view1.backgroundColor = kMainColor;
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10);
        make.size.mas_equalTo(CGSizeMake(200, 100));
        make.left.equalTo(self.view).offset(500);
    }];
    
    UILabel *label1 = [[UILabel alloc] init];
    [view1 addSubview:label1];
    label1.textColor = [UIColor blackColor];
//    labelTitle.font = kFont(kSize_S4, kWeight_W2);
    [label1 sizeToFit];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"座椅记忆1";
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view1);
        make.left.equalTo(view1);
    }];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [view1 addSubview:button1];
//    button.titleLabel.font = kFont(kSize_S2, kWeight_W2);
//    [button setTitleColor:kColor_Title forState:UIControlStateNormal];
    [button1 setTitle:@"设置" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button1.backgroundColor = [UIColor blueColor];
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view1.mas_centerY).offset(-5);
        make.right.equalTo(view1);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [view1 addSubview:button2];
//    button.titleLabel.font = kFont(kSize_S2, kWeight_W2);
//    [button setTitleColor:kColor_Title forState:UIControlStateNormal];
    [button2 setTitle:@"重置" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button2.backgroundColor = [UIColor blueColor];
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_centerY).offset(5);
        make.right.equalTo(view1);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    UIView *view2 = [[UIView alloc] init];
    [self.view addSubview:view2];
    view2.backgroundColor = kMainColor;
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-10);
        make.size.mas_equalTo(CGSizeMake(200, 100));
        make.left.equalTo(view1.mas_right).offset(40);
    }];
    
    UILabel *label2 = [[UILabel alloc] init];
    [view2 addSubview:label2];
    label2.textColor = [UIColor blackColor];
//    labelTitle.font = kFont(kSize_S4, kWeight_W2);
    [label2 sizeToFit];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"座椅记忆2";
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view2);
        make.left.equalTo(view2);
    }];
    
    UIButton *buttonTop2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [view2 addSubview:buttonTop2];
//    button.titleLabel.font = kFont(kSize_S2, kWeight_W2);
//    [button setTitleColor:kColor_Title forState:UIControlStateNormal];
    [buttonTop2 setTitle:@"设置" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    buttonTop2.backgroundColor = [UIColor blueColor];
    [buttonTop2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view2.mas_centerY).offset(-5);
        make.right.equalTo(view2);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
    
    UIButton *buttonBottom2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [view2 addSubview:buttonBottom2];
//    button.titleLabel.font = kFont(kSize_S2, kWeight_W2);
//    [button setTitleColor:kColor_Title forState:UIControlStateNormal];
    [buttonBottom2 setTitle:@"重置" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    buttonBottom2.backgroundColor = [UIColor blueColor];
    [buttonBottom2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view2.mas_centerY).offset(5);
        make.right.equalTo(view2);
        make.size.mas_equalTo(CGSizeMake(50, 30));
    }];
}

- (UIView *)switchViewWith:(NSString *)title select:(SEL)action
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = kMainColor;
    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).offset(5);
    }];
    
    UISwitch *switchButton = [[UISwitch alloc] init];
    [view addSubview:switchButton];
    [switchButton addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(label.mas_bottom).offset(5);;
    }];
    
    return view;
}

- (void)buildMotorList
{
//    SideViewController *vc = [[SideViewController alloc] init];
//    [self addChildViewController:vc];
//    [self.view addSubview:vc.view];
//    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.top.bottom.equalTo(self.view);
//        make.top.equalTo(self.view);
//        make.bottom.equalTo(self.view).offset(-100);
//        make.centerX.equalTo(self.view);
//        make.width.mas_equalTo(100);
//    }];
}

#pragma mark - 设备全屏显示UI

- (void)setupDeviceDisplayUI {
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    self.keyWindow = [UIApplication sharedApplication].delegate.window;
    
    
    // Do any additional setup after loading the view.
    id ufw = [AppDelegateTools instance].ufw;
    if (!ufw) {
        ufw = UnityFrameworkLoad();
        [ufw setDataBundleId:"com.unity3d.framework"];
        [ufw runEmbeddedWithArgc:AppDelegateTools.instance.argc argv:AppDelegateTools.instance.argv appLaunchOpts:AppDelegateTools.instance.launchOptions];
    }
    
    [AppDelegateTools instance].ufw = ufw;
    self.ufw = ufw;
    
    UIWindow *unityWindow = [self.ufw appController].window;
    //    [unityWindow makeKeyAndVisible];
    //    unityWindow.hidden = NO;
    //    unityWindow.windowLevel = UIWindowLevelNormal;
    //    CGFloat navbarHeight = self.navigationController.navigationBar.frame.size.height;
    //    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect frame = self.view.bounds;
    //    frame.origin.y = navbarHeight+statusHeight;
    //    frame.size.height -= frame.origin.y;
    //    unityWindow.frame = frame;
    [self.view addSubview:unityWindow];
    
    // 2️⃣ 透明触摸层（顶层）
    //    self.touchView = [[TouchPassthroughView alloc] initWithFrame:self.view.bounds];
    //    self.touchView.backgroundColor = UIColor.clearColor;
    //    [unityWindow addSubview:self.touchView];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    [[LanguageManager shared] setLanguage:@"zh-Hans"];
    UIButton *settingBtn = [self buttonWithImage:@"chair_setting" tag:0 action:@selector(buttonRightAction)];
    [unityWindow addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unityWindow).offset(-20);
        make.top.equalTo(unityWindow).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 70));
    }];
    self.buttonSetting = settingBtn;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(resetPassword)];
    longPress.minimumPressDuration = 2;
    [settingBtn addGestureRecognizer:longPress];
    
    [self buildSubview:unityWindow];
}

- (void)buildSubview:(UIWindow *)unityWindow
{
    UIImageView *imageLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chair_logo"]];
    [unityWindow addSubview:imageLogo];
    [imageLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(unityWindow);
        make.size.mas_equalTo(CGSizeMake(250*1.4, 130*1.4));
    }];
    
    UILabel *labelProgress = [[UILabel alloc] init];
    [unityWindow addSubview:labelProgress];
    [labelProgress sizeToFit];
    labelProgress.textAlignment = NSTextAlignmentCenter;
    labelProgress.text = @"";
    labelProgress.textColor = [UIColor colorWithRed:235/255.0 green:160/255.0 blue:60/255.0 alpha:1];
    labelProgress.font = [UIFont monospacedSystemFontOfSize:28 weight:UIFontWeightBold];
    [labelProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(unityWindow).offset(40);
        make.centerX.equalTo(unityWindow);
        make.size.mas_equalTo(CGSizeMake(1000, 50));
    }];
    self.labelProgress = labelProgress;
    
    UIButton *playBtn = [self buttonWithImage:@"chair_zero" tag:SeatKey_ZeroGravityOn action:@selector(playAction:)];
    [unityWindow addSubview:playBtn];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unityWindow).offset(-20);
        make.bottom.equalTo(unityWindow).offset(-20);
        make.size.mas_equalTo(CGSizeMake(100, 80));
    }];
    
    UIButton *resetBtn = [self buttonWithImage:@"chair_reset" tag:SeatKey_ZeroGravityReset action:@selector(resetAction:)];
    [unityWindow addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(playBtn.mas_left).offset(-10);
        make.bottom.equalTo(playBtn);
        make.size.equalTo(playBtn);
    }];
    
    UIButton *rotationBtn = [self buttonWithImage:@"chair_rotation" tag:SeatKey_ZeroGravityReset action:@selector(rotationAction:)];
    [unityWindow addSubview:rotationBtn];
    [rotationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(resetBtn.mas_left).offset(-10);
        make.bottom.equalTo(playBtn);
        make.size.equalTo(playBtn);
    }];
    
    [self buildMemoryViewTest:unityWindow];
    [self buildStatusView:unityWindow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUnityRotation:)
                                                 name:@"UnityRotationCallback"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(languageChanged:)
                                                 name:@"languageChangedCallback"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zeroOnAction:)
                                                 name:@"kNotice_ZeroGravityOn"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(zeroOffAction:)
                                                 name:@"kNotice_ZeroGravityOff"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMototList:) name:@"update_motor_list" object:nil];
}

- (void)buildMemoryViewTest:(UIWindow *)unityWindow
{
    DeviceMemoryView *view2 = [[DeviceMemoryView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:1
                               withImageName:@"chair_memory2"
                                button1:@{@"title":@"Memory", @"tag":@(SeatKey_Memory2Set)}
                                button2:@{@"title":@"Start", @"tag":@(SeatKey_Memory2Start)}
                                isRight:NO];
    [unityWindow addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(unityWindow);
        make.right.equalTo(unityWindow).offset(-20);
        make.size.mas_equalTo(CGSizeMake(220, 120));
    }];
    
    DeviceMemoryView *view1 = [[DeviceMemoryView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:1
                               withImageName:@"chair_memory1"
                                button1:@{@"title":@"Memory", @"tag":@(SeatKey_Memory1Set)}
                                button2:@{@"title":@"Start", @"tag":@(SeatKey_Memory1Start)}
                                isRight:NO];
    [unityWindow addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(unityWindow).offset(-160);
        make.right.equalTo(view2);
        make.size.equalTo(view2);
    }];
    
    DeviceMemoryView *view3 = [[DeviceMemoryView alloc]
                                initWithFrame:CGRectZero
                                withMotorID:1
                               withImageName:@"chair_memory3"
                                button1:@{@"title":@"Memory", @"tag":@(SeatKey_Memory3Set)}
                                button2:@{@"title":@"Start", @"tag":@(SeatKey_Memory3Start)}
                                isRight:NO];
    [unityWindow addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(unityWindow).offset(160);
        make.right.equalTo(view2);
        make.size.equalTo(view2);
    }];
}

- (void)buildStatusView:(UIWindow *)unityWindow
{
    UIView *statusBgView = [[UIView alloc] init];
    [unityWindow addSubview:statusBgView];
    [statusBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(unityWindow);
        make.left.equalTo(unityWindow);
        make.size.mas_equalTo(CGSizeMake(50, 260));
    }];
    
    self.viewHorizontal = [[UIView alloc] init];
    
    self.viewHeight = [[UIView alloc] init];
    
    self.viewBackrest = [[UIView alloc] init];
    
    self.viewSeat = [[UIView alloc] init];
    
    self.viewLegrest = [[UIView alloc] init];
    
    NSArray *viewArr = @[self.viewHorizontal,
                         self.viewHeight,
                         self.viewBackrest,
                         self.viewSeat,
                         self.viewLegrest];
    for (UIView *view in viewArr) {
        [statusBgView addSubview:view];
        view.backgroundColor = [UIColor greenColor];
        view.layer.cornerRadius = 4;
        view.layer.masksToBounds = YES;
    }
    
    CGFloat dotSize = 8;
    [viewArr mas_distributeViewsAlongAxis:MASAxisTypeVertical
                      withFixedItemLength:dotSize
                              leadSpacing:0
                              tailSpacing:0];
    [viewArr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(statusBgView);
        make.width.mas_equalTo(dotSize);
        make.height.mas_equalTo(dotSize);
    }];
}

- (void)buildMemoryViewTest222:(UIWindow *)unityWindow
{
    UIButton *memoryStart1 = [self buttonWithTitle:@"记忆1启动" tag:SeatKey_Memory1Start action:@selector(memoryStartAction:)];
    [unityWindow addSubview:memoryStart1];
    [memoryStart1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unityWindow);
        make.bottom.equalTo(unityWindow).offset(-55);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    
    UIButton *memorySet1 = [self buttonWithTitle:@"记忆1设置" tag:SeatKey_Memory1Set action:@selector(memorySetAction:)];
    [unityWindow addSubview:memorySet1];
    [memorySet1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(memoryStart1.mas_left).offset(-5);
        make.bottom.equalTo(memoryStart1);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    
    UIButton *memoryStart2 = [self buttonWithTitle:@"记忆2启动" tag:SeatKey_Memory2Start action:@selector(memoryStartAction:)];
    [unityWindow addSubview:memoryStart2];
    [memoryStart2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unityWindow);
        make.bottom.equalTo(memoryStart1.mas_top).offset(-5);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    
    UIButton *memorySet2 = [self buttonWithTitle:@"记忆2设置" tag:SeatKey_Memory2Set action:@selector(memorySetAction:)];
    [unityWindow addSubview:memorySet2];
    [memorySet2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(memoryStart2.mas_left).offset(-5);
        make.bottom.equalTo(memoryStart2);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    
    UIButton *memoryStart3 = [self buttonWithTitle:@"记忆3启动" tag:SeatKey_Memory3Start action:@selector(memoryStartAction:)];
    [unityWindow addSubview:memoryStart3];
    [memoryStart3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unityWindow);
        make.bottom.equalTo(memoryStart2.mas_top).offset(-5);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
    
    UIButton *memorySet3 = [self buttonWithTitle:@"记忆3设置" tag:SeatKey_Memory3Set action:@selector(memorySetAction:)];
    [unityWindow addSubview:memorySet3];
    [memorySet3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(memoryStart3.mas_left).offset(-5);
        make.bottom.equalTo(memoryStart3);
        make.size.mas_equalTo(CGSizeMake(80, 50));
    }];
}

#pragma mark - Notice
- (void)onUnityRotation:(NSNotification *)noti
{
    NSString *jsonString = noti.object;
    NSLog(@"🎯 最终拿到 Unity 值 = %@", jsonString);

    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error) {
        NSLog(@"JSON 解析失败 ❌：%@", error);
    } else {
        NSLog(@"JSON 解析成功 ✅：%@", jsonDict);
        
        NSLog(@"---------name=%@, value= %@", jsonDict[@"name"], jsonDict[@"progress"]);
        
        NSString *name = jsonDict[@"name"];
        int progress = [jsonDict[@"progress"] intValue];
        if (progress > 100 || progress < 0) {
            return;
        }
        
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        [dictM setValue:@(progress) forKey:@"progress"];
        
        NSString *unit = Localized(@"chair_key_unit");
        int tempProgress = progress;
        NSString *motorName = @"";
        if ([name isEqualToString:@"靠背"]) {
            [dictM setValue:@(MotorIDBackrestForwardBack) forKey:@"motorID"];
            motorName = Localized(@"chair_key_backrest_adjustment");
            tempProgress = ceil(progress/100.0*(135-88)+88);
        } else if ([name isEqualToString:@"腿托"]) {
            [dictM setValue:@(MotorIDLegRestUpDown) forKey:@"motorID"];
            motorName = Localized(@"chair_key_legrest_adjustment");
            tempProgress = ceil(progress/100.0*(175-105)+105);
        } else if ([name isEqualToString:@"坐盆"]) {
            [dictM setValue:@(MotorIDSeatTilt) forKey:@"motorID"];
            motorName = Localized(@"chair_key_seat_adjustment");
            tempProgress = ceil(progress/100.0*(45-15)+15);
        } else if ([name isEqualToString:@"水平调节"]) {
            [dictM setValue:@(MotorIDSeatForwardBackward) forKey:@"motorID"];
            motorName = Localized(@"chair_key_horizontal_adjustment");
            unit = @"%";
        } else if ([name isEqualToString:@"高度"]) {
            [dictM setValue:@(MotorIDSeatUpDown) forKey:@"motorID"];
            motorName = Localized(@"chair_key_height_adjustment");
            unit = @"%";
        }
        
        NSString *progressStr = @"";
        if (tempProgress >= 100) {
            progressStr = [NSString stringWithFormat:@"%d",tempProgress];
        } else if (tempProgress >= 10) {//1个空格
            progressStr = [NSString stringWithFormat:@" %d",tempProgress];
        } else {//两个空格
            progressStr = [NSString stringWithFormat:@"  %d",tempProgress];
        }
        if (motorName.length > 0) {
            self.labelProgress.text = [NSString stringWithFormat:@"%@ %@%@", motorName, progressStr, unit];
        } else {
            self.labelProgress.text = @"";
        }
        
        NSString *event = jsonDict[@"event"];
        if ([event isEqualToString:@"release"]) {
            NSData *data = [BluetoothMessage messagePositionWith:@[dictM]];
            [[MyBluetoothManager sharedInstance] sendMessageWith:data];
        }
    }
}

- (void)languageChanged:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *language = notice.object;
//        [self.buttonSetting setTitle:Localized(@"chair_key_background_settings") forState:UIControlStateNormal];
    });
}

- (void)updateMototList:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *motorArr = [MyBluetoothManager sharedInstance].allMotorArr;
        for (MotorModel *temp in motorArr) {
            UIColor *color = [UIColor redColor];
            if (temp.status == 0) {
                color = [UIColor greenColor];
            } else if (temp.status == 1 || temp.status == 2) {
                color = [UIColor yellowColor];
            }
            if (temp.motorID == 1) {
                self.viewHorizontal.backgroundColor = color;
            } else if (temp.motorID == 2) {
                self.viewHeight.backgroundColor = color;
            } else if (temp.motorID == 3) {
                self.viewBackrest.backgroundColor = color;
            } else if (temp.motorID == 4) {
                self.viewSeat.backgroundColor = color;
            } else if (temp.motorID == 5) {
                self.viewLegrest.backgroundColor = color;
            }
        }
    });
}

- (void)zeroOnAction:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playAction:nil];
        NSLog(@"-------------收到通知=====1111111");
    });
}

- (void)zeroOffAction:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self resetAction:nil];
        NSLog(@"-------------收到通知=====222222");
    });
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    
//    NSLog(@"------");
////    [self.ufw quitApplication:0];
//    
////    if (self.dismissCallback) {
////        self.dismissCallback();
////    }
//}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger)tag action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
//    btn.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action
     forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 10;
    btn.layer.borderWidth = 2;
    btn.layer.borderColor = kMainColor.CGColor;
    if (tag) {
        btn.tag = tag;
    }
    return btn;
}

- (UIButton *)buttonWithImage:(NSString *)imageName tag:(NSInteger)tag action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:action
     forControlEvents:UIControlEventTouchUpInside];
    if (tag) {
        btn.tag = tag;
    }
    return btn;
}


- (void)dealloc
{
    NSLog(@"%s", __func__);
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UnityAppController *appController =
        [UnityFramework getInstance].appController;

    UIWindow *unityWindow = appController.window;
    if (unityWindow) {
        unityWindow.hidden = NO;
        unityWindow.windowLevel = UIWindowLevelNormal;
    }
    [unityWindow makeKeyWindow];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    UnityAppController *appController =
        [UnityFramework getInstance].appController;

    UIWindow *unityWindow = appController.window;

    if (unityWindow) {
        unityWindow.hidden = YES;
        unityWindow.windowLevel = UIWindowLevelNormal - 1;
    }

    [self.keyWindow makeKeyAndVisible];
}

- (void)setupDeviceDisplayUI2222 {
    
//    UIView *bgView = [[UIView alloc] init];
//    [self.view addSubview:bgView];
//    bgView.backgroundColor = [UIColor blueColor];
//    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    // 设备全屏显示视图
    self.deviceFullScreenView = [[UIImageView alloc] init];
    self.deviceFullScreenView.image = [UIImage imageNamed:@"device_screen"]; // 请替换为实际设备图片
    self.deviceFullScreenView.contentMode = UIViewContentModeScaleToFill;
    self.deviceFullScreenView.clipsToBounds = YES;
    self.deviceFullScreenView.alpha = 0.0; // 初始隐藏
//    self.deviceFullScreenView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.deviceFullScreenView];
    [self.deviceFullScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(150, 150, 150, 150));
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(800, 600));
    }];
}

#pragma mark - 模拟设备连接流程

- (void)showDeviceFullScreenView {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.deviceFullScreenView.alpha = 1.0;
    } completion:nil];
}

#pragma mark - 点击事件处理

- (void)tapAreaTapped {
    
}

#pragma mark - Action
- (void)resetPassword
{
    NSLog(@"重置密码");
    [[NSUserDefaults standardUserDefaults] setObject:@"666666"
                                              forKey:@"SettingsPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [GlobalToast show:@"密码重置完成。666666"];
}

- (void)switchAction1:(UISwitch *)sender
{
    NSData *data = [BluetoothMessage messageWith:SeatKey_SeatbeltWarning pressed:sender.on needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)switchAction2:(UISwitch *)sender
{
    NSData *data = [BluetoothMessage messageWith:SeatKey_Massage pressed:sender.on needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)switchAction3:(UISwitch *)sender
{
    NSData *data = [BluetoothMessage messageWith:SeatKey_Ventilation pressed:sender.on needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)switchAction4:(UISwitch *)sender
{
    NSData *data = [BluetoothMessage messageWith:SeatKey_FastAdjust pressed:sender.on needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}


- (void)buttonLanguageAction
{
    
}

- (void)buttonRightAction {
//    [self.navigationController pushViewController:[DeviceSettingViewController new] animated:YES];
    [self showPasswordAlert];
    
}

- (void)playAction:(UIButton *)sender
{
    [self.ufw sendMessageToGOWithName:"AppBridge"
                         functionName:"ZeroGravityOn"
                              message:"1"];
    
    NSData *data = [BluetoothMessage messageWith:SeatKey_ZeroGravityOn pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)resetAction:(UIButton *)sender
{
    [self.ufw sendMessageToGOWithName:"AppBridge"
                         functionName:"ResetToMiddle"
                              message:"1"];
    
    NSData *data = [BluetoothMessage messageWith:SeatKey_ZeroGravityReset pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)rotationAction:(UIButton *)sender
{
    [self.ufw sendMessageToGOWithName:"AppBridge"
                         functionName:"EnterRotationAdjust"
                              message:"1"];
}

- (void)memoryStartAction:(UIButton *)sender
{
    NSData *data = [BluetoothMessage messageWith:sender.tag pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}
- (void)memorySetAction:(UIButton *)sender
{
    NSData *data = [BluetoothMessage messageWith:sender.tag pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)showPasswordAlert {
    
//    [self.navigationController pushViewController:[DeviceSettingViewController new] animated:YES];
//    return;
    
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.windowLevel = UIWindowLevelAlert + 1;
    
    UIViewController *vc = [UIViewController new];
    self.alertWindow.rootViewController = vc;
    [self.alertWindow makeKeyAndVisible];
    
    UIViewController *unityVC = [self.ufw appController].rootViewController;
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"请输入密码"
                                        message:@"密码为6位数字，验证后进入设置界面"
                                 preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
//        tf.secureTextEntry = YES;
        tf.placeholder = @"密码";
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.returnKeyType = UIReturnKeyDone;
    }];

    __weak typeof(self) weakSelf = self;

    UIAlertAction *confirm =
    [UIAlertAction actionWithTitle:@"确认"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
        NSLog(@"---------------222222222");
        [self dismissAlertWindow];
        
        NSString *input = alert.textFields.firstObject.text;
        NSString *saved = [weakSelf loadPassword];

        if ([input isEqualToString:saved]) {
//            [weakSelf pushSettingsVC];
            [weakSelf.navigationController pushViewController:[DeviceSettingViewController new] animated:YES];
        } else {
//            [weakSelf showError:@"密码错误"];
            [GlobalToast show:@"密码错误"];
        }
    }];

    [alert addAction:confirm];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *action) {
        NSLog(@"---------------11111111");
        [self dismissAlertWindow];
    }]];

    [vc presentViewController:alert animated:YES completion:nil];
}

// 读取密码
- (NSString *)loadPassword {
    NSString *password = [[NSUserDefaults standardUserDefaults]
                          stringForKey:@"SettingsPassword"];
    if (password.length == 0) {
        return @"888888";
    }
    return password;
}

- (void)dismissAlertWindow
{
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

UnityFramework* UnityFrameworkLoad()
{
    NSString* bundlePath = nil;
    bundlePath = [[NSBundle mainBundle] bundlePath];
    bundlePath = [bundlePath stringByAppendingString: @"/Frameworks/UnityFramework.framework"];

    NSBundle* bundle = [NSBundle bundleWithPath: bundlePath];
    if ([bundle isLoaded] == false) [bundle load];

    UnityFramework* ufw = [bundle.principalClass getInstance];
    if (![ufw appController])
    {
        // unity is not initialized
        [ufw setExecuteHeader: &_mh_execute_header];
    }
    return ufw;
}

@end
