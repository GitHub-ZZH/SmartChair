//
//  BluetoothMessage.h
//  SmartChair
//
//  Created by 张志恒 on 2025/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef struct {
//    Byte header;
//    Byte cmd;
//    Byte len;
//    Byte payload[5];
//} MessagePacket;

typedef NS_ENUM(NSUInteger, MotorID) {
    MotorIDSeatForwardBackward   = 1,  // 座垫前后电机
    MotorIDSeatUpDown            = 2,  // 座垫上下电机
    MotorIDBackrestForwardBack   = 3,  // 靠背前后电机
    MotorIDSeatTilt              = 4,  // 座垫倾斜电机
    MotorIDLegRestUpDown          = 5,  // 腿托高低电机
    MotorIDLumbarUpDown           = 6,  // 腰部上下电机
    MotorIDLumbarLeftRight        = 7,  // 腰部左右电机
    MotorIDLegRestExtend          = 8,  // 腿托伸缩电机
    MotorIDHeadrestUpDown         = 9,  // 头枕上下电机
    MotorIDSeatbeltWarning        = 10, // 安全带预警电机
    MotorIDBackMassage            = 11, // 背部按摩电机
    MotorIDSeatVentilation        = 12  // 座椅通风电机
};

typedef NS_ENUM(NSInteger, SeatKey) {
    // DATA2
    SeatKey_BackForward        = 1,   // K1
    SeatKey_BackBackward,             // K2
    SeatKey_LumbarUp,                 // K3
    SeatKey_LumbarDown,               // K4
    SeatKey_LumbarLeft,               // K5
    SeatKey_LumbarRight,              // K6
    SeatKey_CushionTiltUp,            // K7
    SeatKey_CushionTiltDown,          // K8

    // DATA3
    SeatKey_CushionUp,                // K9
    SeatKey_CushionDown,              // K10
    SeatKey_CushionForward,           // K11
    SeatKey_CushionBackward,          // K12
    SeatKey_LegExtend,                // K13
    SeatKey_LegRetract,               // K14
    SeatKey_LegUp,                    // K15
    SeatKey_LegDown,                  // K16

    // DATA4
    SeatKey_HeadrestUp,               // K17
    SeatKey_HeadrestDown,             // K18
    SeatKey_SeatbeltWarning,          // K19
    SeatKey_Massage,                  // K20
    SeatKey_Ventilation,              // K21

    // DATA5
    SeatKey_Memory1Start = 25,         // K25
    SeatKey_Memory1Set,
    SeatKey_Memory2Start,
    SeatKey_Memory2Set,
    SeatKey_Memory3Start,
    SeatKey_Memory3Set,
    SeatKey_Memory4Start,
    SeatKey_Memory4Set,

    // DATA6
    SeatKey_ZeroGravityOn = 33,        // K33
    SeatKey_ZeroGravityReset,          // K34
    SeatKey_FastAdjust,                // K35
    SeatKey_SelfLearning,
    
    // DATA7
    SeatKey_Learning1 = 41, // K41
    SeatKey_Learning2 = 42,
    SeatKey_Learning3 = 43,
    SeatKey_Learning4 = 44,
    SeatKey_Learning5 = 45,
    SeatKey_Learning6 = 46,
    SeatKey_Learning7 = 47,
    SeatKey_Learning8 = 48,
    SeatKey_Learning9 = 49,
};



@interface BluetoothMessage : NSObject

/**
 index: 指令
 pressed: 开/关
 save: 是否保留数据
 */
+ (NSData *)messageWith:(NSInteger)index pressed:(BOOL)pressed needSave:(BOOL)save;

+ (NSData *)messagePositionWith:(NSArray *)positionArr;

//打包数据
+ (NSData *)packetMessageWithData:(Byte *)byteData;

+ (void)analysisData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END



//@interface SeatControlManager : NSObject
//
///// DATA 字节数（默认 5）
//@property (nonatomic, assign, readonly) NSInteger dataLength;
//
///// 设置按键状态
//- (void)setKey:(SeatKey_)key pressed:(BOOL)pressed;
//
///// 清空所有按键
//- (void)clearAll;
//
///// 获取发送数据
//- (NSData *)packetData;
//
///// 调试用
//- (void)logCurrentData;
//
//@end

