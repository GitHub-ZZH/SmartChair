//
//  DeviceControlView.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "DeviceControlView.h"
#import <Masonry/Masonry.h>
#import "MyBluetoothManager.h"
#import "BluetoothMessage.h"

@interface DeviceControlView ()

@property(nonatomic, strong) UIButton *buttonContainer;
@property(nonatomic, strong) UILabel *labelProgress;
@property(nonatomic, strong) UILabel *labelStatus;
@property(nonatomic, assign) NSInteger motorID;

@property(nonatomic, strong) UIView *controlBg;
@property(nonatomic, strong) UIButton *moveUpButton;
@property(nonatomic, strong) UIButton *moveDownButton;

@property(nonatomic, assign) NSInteger buttonTag;
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation DeviceControlView

- (instancetype)initWithFrame:(CGRect)frame
                  withMotorID:(NSInteger)motorID
                      button1:(NSDictionary *)button1
                      button2:(NSDictionary *)button2  isRight:(BOOL)right
{
    self = [super initWithFrame:frame];
    if (self) {
        self.moveUpButton = [self buildButtonWith:button1];
        self.moveDownButton = [self buildButtonWith:button2];
        
        self.motorID = motorID;
        [self buildSubviews:motorID isRight:right];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMototList:) name:@"update_motor_list" object:nil];
    }
    return self;
}

- (void)buildSubviews:(NSInteger)motorID isRight:(BOOL)right {
//    self.alpha = 0.0;
//    self.transform = CGAffineTransformMakeTranslation(100, 0); // 初始在屏幕外
    
    // 按钮容器
    self.buttonContainer = [[UIButton alloc] init];
    [self addSubview:self.buttonContainer];
    self.buttonContainer.backgroundColor = [UIColor whiteColor];
    self.buttonContainer.layer.cornerRadius = 10;
    self.buttonContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.buttonContainer.layer.shadowOffset = CGSizeMake(0, 4);
    self.buttonContainer.layer.shadowOpacity = 0.15;
    self.buttonContainer.layer.shadowRadius = 8;
//    [self.buttonContainer setTitle:title forState:UIControlStateNormal];
    [self.buttonContainer addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.buttonContainer.backgroundColor = [UIColor colorWithRed:209/255.0 green:124/255.0 blue:74/255.0 alpha:1];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (right) {
            make.left.equalTo(self);
        } else {
            make.right.equalTo(self);
        }
        make.size.mas_equalTo(CGSizeMake(80, 60));
    }];
    
    UILabel *labelTitle = [[UILabel alloc] init];
    [self.buttonContainer addSubview:labelTitle];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont systemFontOfSize:16];
    [labelTitle sizeToFit];
    labelTitle.textAlignment = NSTextAlignmentCenter;
    labelTitle.text = [MotorModel nameDescription:motorID];
    [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.buttonContainer);
        make.top.equalTo(self.buttonContainer).offset(4);
    }];
    
    if (motorID < 100) {
        self.labelProgress = [[UILabel alloc] init];
        [self.buttonContainer addSubview:self.labelProgress];
        self.labelProgress.textColor = [UIColor whiteColor];
        self.labelProgress.font = [UIFont systemFontOfSize:12];
        [self.labelProgress sizeToFit];
        self.labelProgress.textAlignment = NSTextAlignmentCenter;
        [self.labelProgress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.buttonContainer);
            make.top.equalTo(labelTitle.mas_bottom).offset(4);
        }];
        
        self.labelStatus = [[UILabel alloc] init];
        [self.buttonContainer addSubview:self.labelStatus];
        self.labelStatus.textColor = [UIColor whiteColor];
        self.labelStatus.font = [UIFont systemFontOfSize:12];
        [self.labelStatus sizeToFit];
        self.labelStatus.textAlignment = NSTextAlignmentCenter;
        [self.labelStatus mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.buttonContainer);
            make.top.equalTo(self.labelProgress.mas_bottom).offset(4);
        }];
    } else {
        [labelTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.buttonContainer);
        }];
    }
    
    
    self.controlBg = [[UIView alloc] init];
    [self addSubview:self.controlBg];
    [self.controlBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (right) {
            make.left.equalTo(self.buttonContainer.mas_right).offset(10);
        } else {
            make.right.equalTo(self.buttonContainer.mas_left).offset(-10);
        }
        make.size.mas_equalTo(CGSizeMake(50, 80));
    }];
    self.controlBg.alpha = 0;
    
    // 上移按钮
    [self.controlBg addSubview:self.moveUpButton];
    
    // 下移按钮
    [self.controlBg addSubview:self.moveDownButton];
    
    [self.moveUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.controlBg);
        make.bottom.equalTo(self.controlBg.mas_centerY).offset(-10);
    }];
    [self.moveDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.controlBg);
        make.top.equalTo(self.controlBg.mas_centerY).offset(10);
    }];
//    self.moveUpButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
//    self.moveDownButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (UIButton *)buildButtonWith:(NSDictionary *)dict
{
    // 下移按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.controlBg addSubview:self.moveDownButton];
//    [button setImage:[UIImage imageNamed:@"down_icon"] forState:UIControlStateNormal]; // 请替换为实际图片
    button.tag = [dict[@"tag"] integerValue];
    [button setTitle:dict[@"title"] forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:0/255.0 green:108/255.0 blue:185/255.0 alpha:1.0]];
    button.layer.cornerRadius = 8;
    button.layer.masksToBounds = YES;
    button.backgroundColor = [UIColor colorWithRed:0/255.0 green:108/255.0 blue:185/255.0 alpha:1.0];
    if (button.tag == SeatKey_ZeroGravityOn ||
        button.tag == SeatKey_ZeroGravityReset ||
        button.tag == SeatKey_Memory1Start ||
        button.tag == SeatKey_Memory1Set ||
        button.tag == SeatKey_Memory2Start ||
        button.tag == SeatKey_Memory2Set) {
        [button addTarget:self action:@selector(moveButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor colorWithRed:100/255.0 green:108/255.0 blue:15/255.0 alpha:1.0];
    } else {
        [button addTarget:self action:@selector(moveUpButtonTouchBegin:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(moveUpButtonTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(moveUpButtonTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(moveUpButtonTouchEnd:) forControlEvents:UIControlEventTouchCancel];
    }
    
    return  button;
}

- (void)animateButtonTap:(UIButton *)button {
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        button.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            button.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

#pragma mark - Action
- (void)moveUpButtonTouchBegin:(UIButton *)sender {
    // 上移按钮点击动画
    [self animateButtonTap:sender];
    NSLog(@"设备上移======开始-----");
    
    self.buttonTag = sender.tag;
    [self startTimer];
    
    // 可添加设备上移的实际逻辑（如发送指令给设备）
//    NSData *data = [BluetoothMessage messageWith:1];
//    [[BluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)moveUpButtonTouchEnd:(UIButton *)sender {
    // 上移按钮点击动画
    [self animateButtonTap:sender];
    NSLog(@"设备上移 ======= 结束-----");
    
    [self stopTimer];
    self.buttonTag = 0;
    
    //结束
//    NSData *data = [BluetoothMessage messageWith:0];
//    [[BluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)moveButtonTouch:(UIButton *)sender {
    // 上移按钮点击动画
    [self animateButtonTap:sender];
    
    //结束
    NSData *data = [BluetoothMessage messageWith:sender.tag pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)buttonAction:(UIButton *)sender
{
    if (self.controlBg.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlBg.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlBg.alpha = 0;
        }];
    }
    
}


#pragma mark -
- (void)startTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerBegin:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)stopTimer
{
    [_timer invalidate];
    NSLog(@"=====进度条定时器---停止");
    
    NSData *data = [BluetoothMessage messageWith:self.buttonTag pressed:NO needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)timerBegin:(NSTimer *)timer
{
    NSData *data = [BluetoothMessage messageWith:self.buttonTag pressed:YES needSave:YES];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

#pragma mark - Notice
- (void)updateMototList:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
        for (MotorModel *temp in [MyBluetoothManager sharedInstance].allMotorArr) {
            if (temp.motorID == self.motorID) {
//                model.status = temp.status;
                self.labelProgress.text = [NSString stringWithFormat:@"%ld%%",temp.progress];
                self.labelStatus.text = [MotorModel statusDescription:temp.status];
            }
        }
    });
}
@end
