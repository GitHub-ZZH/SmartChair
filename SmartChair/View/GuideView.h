//
//  GuideView.h
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuideView : UIView

@property (nonatomic, copy) void(^onDismiss)(void);

@end

NS_ASSUME_NONNULL_END
