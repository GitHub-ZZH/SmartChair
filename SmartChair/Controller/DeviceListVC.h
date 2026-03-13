//
//  DeviceListVC.h
//  SmartChair
//
//  Created by 张志恒 on 2026/1/4.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class DeviceListVC;

@protocol DeviceListVCDelegate <NSObject>
//- (void)deviceListVC:(DeviceListVC *)vc
//     didSelectDevice:(CBPeripheral *)peripheral;

- (void)connectSuccess:(NSString *)uuid;

@end

@interface DeviceListVC : UIViewController
@property (nonatomic, weak) id<DeviceListVCDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
