//
//  DeviceSettingCell.h
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import <UIKit/UIKit.h>
#import "MyBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceSettingCell : UITableViewCell

@property(nonatomic, strong) MotorModel *model;

@end

NS_ASSUME_NONNULL_END
