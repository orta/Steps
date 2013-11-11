//
//  ARReusableLoadingView.m
//  Art.sy
//
//  Created by orta therox on 28/12/2012.
//  Copyright (c) 2012 Art.sy. All rights reserved.
//

#import "ARReusableLoadingView.h"
#import "ARSpinner.h"

@interface ARReusableLoadingView()
@property (nonatomic, strong) ARSpinner *spinner;
@end

@implementation ARReusableLoadingView

- (void)layoutSubviews
{
    if (!self.spinner) {
        self.spinner = [[ARSpinner alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];

        [self startIndeterminate];
        [self.contentView addSubview:self.spinner];
    }
    self.spinner.center = CGPointMake( CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)prepareForReuse {
    [_spinner removeFromSuperview];
}

- (void)startIndeterminate {
    [_spinner fadeIn];
}

- (void)stopIndeterminate {
    [_spinner fadeOut];
}

- (CGSize)intrinsicContentSize
{
    return (CGSize){ 44, 44 };
}

@end
