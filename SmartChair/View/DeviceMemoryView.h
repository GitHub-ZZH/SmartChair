//
//  DeviceMemoryView.h
//  SmartChair
//
//  Created by 张志恒 on 2026/3/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceMemoryView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  withMotorID:(NSInteger)motorID
                withImageName:(NSString *)imageName
                      button1:(NSDictionary *)button1
                      button2:(NSDictionary *)button2  isRight:(BOOL)right;

- (void)foldView:(BOOL)fold;

@end

NS_ASSUME_NONNULL_END
