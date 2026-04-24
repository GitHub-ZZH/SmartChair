//
//  MyBluetoothManager.m
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import "MyBluetoothManager.h"
#import "BluetoothMessage.h"
#import <CommonCrypto/CommonCryptor.h>

//#define MyLog(...)          DDLogInfo(__VA_ARGS__)
#ifdef DEBUG
#define NSLog(...) printf("time=%f :  %s\n",[[NSDate date] timeIntervalSince1970],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#else
//#define NSLog(format, ...)
#endif


#define UUID_CHARARCTERISTIC_WRITE @"1521"

#define kSavedPeripheralUUID @"savedPeripheralUUID"
//#define kTargetDeviceName @"smart_chair"
#define kTargetDeviceName @"JE_BT"

@interface MyBluetoothManager ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) CBCharacteristic *deviceStatusChar;
@property (nonatomic, strong) CBCharacteristic *motorStatusChar;

@property(nonatomic, strong) NSMutableArray <NSData *>*messageArr;

@end

@implementation MyBluetoothManager

+ (instancetype)sharedInstance {
    static MyBluetoothManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MyBluetoothManager alloc] init];
        instance.allMotorArr = [NSMutableArray array];
        instance.messageArr = [NSMutableArray array];
        instance.originalData = [NSMutableData data];
        [instance.originalData setLength:8];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // 读取本地存储的 UUID
        NSString *uuidStr = [[NSUserDefaults standardUserDefaults] stringForKey:kSavedPeripheralUUID];
        if (uuidStr) {
            _savedUUID = [[NSUUID alloc] initWithUUIDString:uuidStr];
        }
    }
    return self;
}

#pragma mark - Public

- (void)startScan {
    
    if (_centralManager.state != CBManagerStatePoweredOn) return;

    NSLog(@"开始扫描...");
    [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
}

- (void)stopScan {
    NSLog(@"停止扫描...");
    [self.centralManager stopScan];
}


#pragma mark -
- (void)connectDeviceWithUUID:(NSUUID *)uuid
{
    NSLog(@"蓝牙状态000。。。。。%ld=====uuid=%@",_centralManager.state, uuid);
    if (_centralManager.state != CBManagerStatePoweredOn) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectDeviceWithUUID:uuid];
        });
        return;
    };
    
    NSLog(@"蓝牙已开启");
    // 连接设备
    NSArray *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[uuid]];
    CBPeripheral *peripheral = peripherals.firstObject;
    if (!peripheral) {
        if (self.onConnectFail) {
            self.onConnectFail(nil, nil);
        }
        [self startScan];
        return;
    }
    NSLog(@"正在连接设备...");
    self.connectedPeripheral = peripheral;
    [self.centralManager connectPeripheral:peripheral options:nil];
}

- (void)connectDeviceWith:(CBPeripheral *)peripheral
{
    NSLog(@"蓝牙状态000。。。。。%ld=====uuid=%@",_centralManager.state, peripheral.identifier);
    if (_centralManager.state != CBManagerStatePoweredOn) return;
    
    NSLog(@"蓝牙已开启");
    // 连接设备
//    NSArray *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:@[peripheral]];
//    CBPeripheral *peripheral = peripherals.firstObject;
//    if (!peripheral) {
//        if (self.onConnectFail) {
//            self.onConnectFail(nil, nil);
//        }
//        return;
//    }
    NSLog(@"正在连接设备...");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
    });
}

- (void)disconnect {
    if (self.connectedPeripheral) {
        [_centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral = nil;
    }
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"蓝牙状态。。。。。%ld",central.state);
    
    if (central.state == CBManagerStatePoweredOn) {
        if (self.savedUUID) {
            [self connectDeviceWithUUID:_savedUUID];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {

    if (peripheral.name.length == 0) {
        return;
    }
//    NSLog(@"发现设备：%@ == %@", peripheral, peripheral.name);
//    NSLog(@"rssi = %@ , data===========%@", RSSI, advertisementData);
    
    // 过滤目标设备
    if ([peripheral.name isEqualToString:kTargetDeviceName]) {

//        NSLog(@"发现 smart_chair，开始连接...%@",peripheral);
        NSLog(@"==========%@", peripheral.identifier.UUIDString);
//        
//        self.connectedPeripheral = peripheral;
//        self.connectedPeripheral.delegate = self;
//
//        [self stopScan];
//
//        // 连接
//        [self.centralManager connectPeripheral:peripheral options:nil];
        if (self.onDiscoverPeripheral) {
            self.onDiscoverPeripheral(peripheral, advertisementData, RSSI);
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    NSLog(@"连接成功：%@", peripheral);
    
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;

    if (self.onConnectSuccess) {
        self.onConnectSuccess(peripheral);
    }
    
    // 开始发现服务
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {

    NSLog(@"连接失败：%@", error.localizedDescription);

    if (self.onConnectFail) {
        self.onConnectFail(peripheral, error);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {

    NSLog(@"设备断开连接");

    // 自动重连
    [self.centralManager connectPeripheral:peripheral options:nil];
    [self startScan];
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    NSLog(@"设备改名了、、、、、、%@", peripheral);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"设备信号值、、、、、、%@", RSSI);
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"发现服务。、、、uuid=%@",[peripheral.services firstObject].UUID);
    for (CBService *service in peripheral.services) {
       //4. 1对外设扫描到的服务进行特征扫描
        NSLog(@"serveice uuid == %@。。。。。。。", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// 外设发现特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {

    NSLog(@"发现特征。。、、、、");
    for (CBService *serv in peripheral.services) {
        if (serv == service) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                NSLog(@"特征UUID == %@, ---- char=%@", characteristic.UUID.UUIDString, characteristic);
                ///0002:写数据， 0003:设备回复状态  0004:设备回复电机位置
                if ([characteristic.UUID.UUIDString isEqualToString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"]) {
                    // 4.2 记录特征
                    self.characteristic = characteristic;
                } else if ([characteristic.UUID.UUIDString isEqualToString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"]) {
                    self.deviceStatusChar = characteristic;
                    [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                } else if ([characteristic.UUID.UUIDString isEqualToString:@"6E400004-B5A3-F393-E0A9-E50E24DCCA9E"]) {
                    self.motorStatusChar = characteristic;
                    [self.connectedPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"❌ 写入失败: %@", error);
    } else {
        NSLog(@"✅ 写入成功");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"开启通知失败：%@", error.localizedDescription);
    } else {
        NSLog(@"通知已开启：%@", characteristic);
    }
}

// 当特征的值发生变化时回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSData *data = characteristic.value;
    NSLog(@"✅ ✅ ✅ Receive data notification %@",data);
    
    if (characteristic == self.deviceStatusChar) {
        
    } else if (characteristic == self.motorStatusChar) {
        [BluetoothMessage analysisData:data];
    }
    
    if (self.messageArr.count > 0) {
        [self writeMessage:self.messageArr[0]];
    }
}

- (void)peripheralIsReadyToSendWriteWithoutResponse:(CBPeripheral *)peripheral
{
    NSLog(@"✅ ✅ IsReady");
    
}

- (void)writeMessage:(NSData *)message
{
    if (self.connectedPeripheral == nil ||
        self.characteristic == nil) {
        return;
    }
    [self.connectedPeripheral writeValue:message
                       forCharacteristic:self.characteristic
                                    type:CBCharacteristicWriteWithResponse];
    if ([self.messageArr containsObject:message]) {
        NSInteger index = [self.messageArr indexOfObject:message];
        [self.messageArr removeObjectAtIndex:index];
    }
    NSLog(@"-------------发送111--%@ === ", message);
}

#pragma mark - send
- (void)sendMessageWith:(NSData *)message
{
    [self.messageArr addObject:message];
    
    [self writeMessage:self.messageArr[0]];
}

- (void)sendMessageWithArr:(NSArray<NSData *> *)messageArr
{
    [self.messageArr addObjectsFromArray:messageArr];

    [self writeMessage:self.messageArr[0]];
}


- (void)sendMessageWithList:(NSArray<NSData *> *)array index:(NSInteger)index
{
    if (index >= array.count) {
        return;
    }

    NSData *message = array[index];

    [self.connectedPeripheral writeValue:message
                       forCharacteristic:self.characteristic
                                    type:CBCharacteristicWriteWithResponse];
    NSLog(@"-------------发送222--%@",message);

    //如果改为50ms，会丢失一半的回复，实测100ms较好
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendMessageWithList:array index:index + 1];
    });
}

#pragma mark -

- (void)saveDeviceUUID:(NSString *)uuid
{
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:kSavedPeripheralUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _savedUUID = [[NSUUID alloc] initWithUUIDString:uuid];
}

- (void)clear
{
    [self disconnect];
    
    // 保存 UUID 到本地
    [self saveDeviceUUID:@""];
    _savedUUID = nil;
    
    self.originalData = [NSMutableData data];
    [self.originalData setLength:8];
}

@end
