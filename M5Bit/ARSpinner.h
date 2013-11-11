//
//  ARSpinner.h
//  Art.sy
//
//  Created by orta therox on 20/12/2012.
//  Copyright (c) 2012 Art.sy. All rights reserved.
//

@interface ARSpinner : UIView

- (void)fadeIn;
- (void)fadeOut;

- (void)startAnimating;
- (void)stopAnimating;

@property (nonatomic, strong) UIColor *spinnerColor;

@end
