//
//  MotorModel.m
//  SmartChair
//
//  Created by 张志恒 on 2025/12/24.
//

#import "MotorModel.h"

@implementation MotorModel

+ (NSString *)nameDescription:(NSInteger)motorID
{
    switch (motorID) {
        case 1:     return @"水平调节";
        case 2:     return @"高度调节";
        case 3:     return @"靠背调节";
        case 4:     return @"座盆调节";
        case 5:     return @"腿托调节";
        case 6:     return @"腰托调节";
        case 7:     return @"腰部左右";//无
        case 8:     return @"腿托伸缩";//无
        case 9:     return @"头枕调节";
        case 10:    return @"安全带";
        case 11:    return @"背部按摩";//无
        case 12:    return @"座椅通风";//无
        case 101:   return @"记忆1";
        case 102:   return @"记忆2";
        case 103:   return @"记忆3";
        case 104:   return @"记忆4";
        case 201:   return @"零重力";
        default:                      return @"未知状态";
    }
}
//static inline NSString * MotorStatusDescription(MotorStatus status) {
+ (NSString *)statusDescription:(NSInteger)status
{
    switch (status) {
        case MotorStatusStandby:      return @"待机";
        case MotorStatusRunning:      return @"运行";
        case MotorStatusLearning:     return @"自学习";
        case MotorStatusOverCurrent:  return @"过流";
        case MotorStatusStall:        return @"堵转";
        case MotorStatusLowVoltage:   return @"低压";
        case MotorStatusHighVoltage:  return @"高压";
        case MotorStatusHallFault:    return @"霍尔故障";
//        case MotorStatusOverTemp:     return @"过温";
        default:                      return @"未知状态";
    }
}


@end
