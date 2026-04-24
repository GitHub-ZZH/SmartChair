//
//  DeviceMemoryView.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/23.
//

#import "DeviceMemoryView.h"
#import <Masonry/Masonry.h>
#import "MyBluetoothManager.h"
#import "BluetoothMessage.h"

#define kMainColor [UIColor colorWithRed:225/255.0 green:136/255.0 blue:49/255.0 alpha:1]

@interface DeviceMemoryView ()

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

@implementation DeviceMemoryView

- (instancetype)initWithFrame:(CGRect)frame
                  withMotorID:(NSInteger)motorID
                withImageName:(NSString *)imageName
                      button1:(NSDictionary *)button1
                      button2:(NSDictionary *)button2  isRight:(BOOL)right
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor blueColor];
        self.moveUpButton = [self buildButtonWith:button1];
        self.moveDownButton = [self buildButtonWith:button2];
        
        self.motorID = motorID;
        [self buildSubviews:motorID imageName:imageName isRight:right];
    }
    return self;
}

- (void)buildSubviews:(NSInteger)motorID imageName:(NSString *)imageName isRight:(BOOL)right {
//    self.alpha = 0.0;
//    self.transform = CGAffineTransformMakeTranslation(100, 0); // 初始在屏幕外
    
    // 按钮容器
    self.buttonContainer = [[UIButton alloc] init];
    [self addSubview:self.buttonContainer];
//    self.buttonContainer.layer.cornerRadius = 10;
//    self.buttonContainer.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.buttonContainer.layer.shadowOffset = CGSizeMake(0, 4);
//    self.buttonContainer.layer.shadowOpacity = 0.15;
//    self.buttonContainer.layer.shadowRadius = 8;
//    [self.buttonContainer setTitle:title forState:UIControlStateNormal];
    [self.buttonContainer addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (right) {
            make.left.equalTo(self);
        } else {
            make.right.equalTo(self);
        }
        make.size.mas_equalTo(CGSizeMake(100, 80));
    }];
    
//    UILabel *labelTitle = [[UILabel alloc] init];
//    [self.buttonContainer addSubview:labelTitle];
//    labelTitle.textColor = [UIColor whiteColor];
//    labelTitle.font = [UIFont systemFontOfSize:16];
//    [labelTitle sizeToFit];
//    labelTitle.textAlignment = NSTextAlignmentCenter;
//    labelTitle.text = [MotorModel nameDescription:motorID];
////    [labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.centerX.equalTo(self.buttonContainer);
////        make.top.equalTo(self.buttonContainer).offset(4);
////    }];
//    [labelTitle mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.buttonContainer);
//    }];
    
    [self.buttonContainer setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    self.controlBg = [[UIView alloc] init];
    [self addSubview:self.controlBg];
    [self.controlBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        if (right) {
            make.left.equalTo(self.buttonContainer.mas_right).offset(10);
        } else {
            make.right.equalTo(self.buttonContainer.mas_left).offset(-10);
        }
        make.size.mas_equalTo(CGSizeMake(100, 120));
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

    button.tag = [dict[@"tag"] integerValue];
    [button setTitle:dict[@"title"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 10;
//    button.layer.borderWidth = 2;
//    button.layer.borderColor = kMainColor.CGColor;
    button.backgroundColor = kMainColor;
    [button addTarget:self action:@selector(moveButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
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
- (void)moveButtonTouch:(UIButton *)sender {
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

- (void)foldView:(BOOL)fold
{
    if (fold) {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlBg.alpha = 0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.controlBg.alpha = 1;
        }];
    }
    
}

@end
