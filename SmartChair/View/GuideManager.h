//
//  GuideManager.h
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import <Foundation/Foundation.h>
#import "GuideView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GuideManager : NSObject

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GuideView *guideView;

+ (instancetype)shared;

- (void)startMonitor;
- (void)resetTimer;

- (void)showGuide;

@end

NS_ASSUME_NONNULL_END
