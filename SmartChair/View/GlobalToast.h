//
//  GlobalToast.h
//  SmartChair
//
//  Created by 张志恒 on 2026/3/23.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalToast : NSObject

+ (void)show:(NSString *)message;
+ (void)show:(NSString *)message duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
