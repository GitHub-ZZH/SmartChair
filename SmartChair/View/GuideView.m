//
//  GuideView.m
//  SmartChair
//
//  Created by 张志恒 on 2026/3/30.
//

#import "GuideView.h"


@implementation GuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.image = [UIImage imageNamed:@"chair_guide"];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];

        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dismiss {
    [self removeFromSuperview];

    if (self.onDismiss) {
        self.onDismiss();  // 🔥 通知外部
    }
}

@end
