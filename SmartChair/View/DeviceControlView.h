//
//  DeviceControlView.h
//  SmartChair
//
//  Created by 张志恒 on 2025/11/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceControlView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  withMotorID:(NSInteger)motorID
                      button1:(NSDictionary *)button1
                      button2:(NSDictionary *)button2  isRight:(BOOL)right;

@end

NS_ASSUME_NONNULL_END
