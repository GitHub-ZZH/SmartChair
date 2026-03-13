//
//  MyBluetoothManager.h
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MotorModel.h"
//#import "DCLogger.h"


//// 在项目的公共头文件（如pch）或宏定义文件中
//#ifdef DEBUG
//// Debug模式下：打印带文件、行号、自定义时间的日志
//#define MyLog(format, ...) NSLog((@"[%s][行号:%d][%@] " format), __FILE__, __LINE__, [[NSDate date] description], ##__VA_ARGS__)
//#else
//// Release模式下：不打印任何日志
//#define MyLog(...)
//#endif

NS_ASSUME_NONNULL_BEGIN


@interface MyBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

/// 扫描到外设
@property (nonatomic, copy, nullable) void (^onDiscoverPeripheral)(
    CBPeripheral *peripheral,
    NSDictionary *advertisementData,
    NSNumber *RSSI
);

/// 连接成功
@property (nonatomic, copy, nullable) void (^onConnectSuccess)(
    CBPeripheral *peripheral
);

/// 连接失败
@property (nonatomic, copy, nullable) void (^onConnectFail)(
    CBPeripheral * _Nullable peripheral,
    NSError * _Nullable error
);


@property(nonatomic, strong) NSMutableArray <MotorModel *>*allMotorArr;
@property (nonatomic, strong) NSUUID *savedUUID;

@property (nonatomic, strong) NSMutableData *originalData;

+ (instancetype)sharedInstance;

- (void)connectDeviceWithUUID:(NSUUID *)uuid;
- (void)connectDeviceWith:(CBPeripheral *)peripheral;

- (void)startScan;
- (void)stopScan;
- (void)disconnect;

- (void)sendMessageWith:(NSData *)message;
- (void)sendMessageWithArr:(NSArray<NSData *> *)messageArr;

- (void)saveDeviceUUID:(NSString *)uuid;
- (void)clear;

@end

NS_ASSUME_NONNULL_END
