//
//  DeviceSettingCell.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "DeviceSettingCell.h"
#import <Masonry/Masonry.h>
#import "BluetoothMessage.h"

@interface DeviceSettingCell ()



@end

@implementation DeviceSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews
{
    
//    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chair_selected"]];
//    UITextField *textField = [[UITextField alloc] init];
//    [self.contentView addSubview:textField];
//    textField.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
//    textField.placeholder = @"参数配置";
//    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.textLabel.mas_right).offset(20);
//        make.centerY.equalTo(self.contentView);
//        make.size.mas_equalTo(CGSizeMake(150, 40));
//    }];
    
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.contentView addSubview:button1];
    [button1 setTitle:@"自学习" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1Action:) forControlEvents:UIControlEventTouchUpInside];
    button1.backgroundColor = [UIColor colorWithRed:100/255.0 green:120/255.0 blue:140/255.0 alpha:1];
    button1.layer.cornerRadius = 8;
    button1.layer.masksToBounds = YES;
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-10);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
}

#pragma mark - Setter
- (void)setModel:(MotorModel *)model
{
    _model = model;
    
    self.textLabel.text = [MotorModel nameDescription:model.motorID];
    self.detailTextLabel.text = [MotorModel statusDescription:model.status];
}

#pragma mark - Action
- (void)button1Action:(UIButton *)sender
{
    SeatKey command = self.model.motorID+40;
    NSData *data = [BluetoothMessage messageWith:command pressed:YES needSave:NO];
    [[MyBluetoothManager sharedInstance] sendMessageWith:data];
}

- (void)button2Action:(UIButton *)sender
{
    
}

@end
