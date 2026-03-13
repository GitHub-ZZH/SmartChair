//
//  TouchPassthroughView.m
//  SmartChair
//
//  Created by 张志恒 on 2026/1/29.
//

#import "TouchPassthroughView.h"

@implementation TouchPassthroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"🟡 hitTest point = %@", NSStringFromCGPoint(point));
    for (UIView *view in self.touchableViews) {
        CGPoint p = [self convertPoint:point toView:view];
        if ([view pointInside:p withEvent:event]) {
            return view;   // 命中按钮，UIKit 处理
        }
    }
    return nil; // 其余区域 → 事件下穿到 Unity
}

@end
