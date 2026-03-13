//
//  MotorModel.h
//  SmartChair
//
//  Created by 张志恒 on 2025/12/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(UInt8, MotorStatus) {
    MotorStatusStandby      = 0, // 待机
    MotorStatusRunning      = 1, // 运行
    MotorStatusLearning     = 2, // 自学习
    MotorStatusOverCurrent  = 3, // 过流
    MotorStatusStall        = 4, // 堵转
    MotorStatusLowVoltage   = 5, // 低压
    MotorStatusHighVoltage  = 6, // 高压
    MotorStatusHallFault    = 7, // 霍尔故障
//    MotorStatusLostPosition = 7, // 失位
//    MotorStatusOverTemp     = 8  // 过温
};

@interface MotorModel : NSObject

@property(nonatomic, assign) NSInteger motorID;
@property(nonatomic, assign) MotorStatus status;
@property(nonatomic, assign) NSInteger progress;

+ (NSString *)nameDescription:(NSInteger)motorID;
+ (NSString *)statusDescription:(NSInteger)status;

@end

NS_ASSUME_NONNULL_END
