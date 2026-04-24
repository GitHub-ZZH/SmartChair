//
//  CustomWindow.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import "CustomWindow.h"
#import "GuideManager.h"

@implementation CustomWindow

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];

    if (event.allTouches.count > 0) {
        UITouch *touch = event.allTouches.anyObject;
        if (touch.phase == UITouchPhaseBegan) {
            [[GuideManager shared] resetTimer];
        }
    }
}

@end
