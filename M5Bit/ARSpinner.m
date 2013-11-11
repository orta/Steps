//
//  ARSpinner.m
//  Art.sy
//
//  Created by orta therox on 20/12/2012.
//  Copyright (c) 2012 Art.sy. All rights reserved.
//

#import "ARSpinner.h"
#import <QuartzCore/QuartzCore.h>

@interface ARSpinner()
@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;
@end


@implementation ARSpinner

CGFloat RotationDuration = 0.6;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupBar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupBar];
    }
    return self;
}

- (void)setupBar {
    _spinnerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 5)];
    _spinnerView.backgroundColor = [UIColor blackColor];
    [self layoutSubviews];
    [self addSubview:_spinnerView];
}

- (void)layoutSubviews {
    _spinnerView.center = CGPointMake( CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)fadeIn {
    self.alpha = 0;
    [self startAnimating];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)fadeOut {
    self.alpha = 1;
    [self stopAnimating];

    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    }];
}

- (void)startAnimating {
    [self animate:HUGE_VAL];
}

- (void)animate:(NSInteger)times {
    CATransform3D rotationTransform = CATransform3DMakeRotation(-1.01f * M_PI, 0, 0, 1.0);
    _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];

    _rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    _rotationAnimation.duration = RotationDuration;
    _rotationAnimation.cumulative = YES;
    _rotationAnimation.repeatCount = times;
	[self.layer addAnimation:_rotationAnimation forKey:@"transform"];
}

- (void)stopAnimating {
    [self.layer removeAllAnimations];
    [self animate:1];
}

- (UIColor *)spinnerColor
{
    return self.spinnerView.backgroundColor;
}

- (void)setSpinnerColor:(UIColor *)spinnerColor
{
    self.spinnerView.backgroundColor = spinnerColor;
}

@end
