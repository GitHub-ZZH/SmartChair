//
//  TouchPassthroughView.h
//  SmartChair
//
//  Created by 张志恒 on 2026/1/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TouchPassthroughView : UIView

@property (nonatomic, strong) NSArray<UIView *> *touchableViews;

@end

NS_ASSUME_NONNULL_END
