//
//  UIView+UIView_ViewAnimations.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/5/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

// Define a constant fading duration
#define fadeDuration 1

#import "UIView+UIView_ViewAnimations.h"

@implementation UIView (UIView_ViewAnimations)

- (void)viewFadeInWithCompletion:(void (^ _Nullable)(BOOL rcFinished))rcCompletion {
    [UIView animateWithDuration:fadeDuration animations:^{
        // Perform fading animation by adjusting alpha
        [self setAlpha:1];
    } completion:rcCompletion];
}

- (void)viewFadeOutWithCompletion:(void (^ _Nullable)(BOOL rcFinished))rcCompletion {
    [UIView animateWithDuration:fadeDuration animations:^{
        // Perform fading animation by adjusting alpha
        [self setAlpha:0];
    } completion:rcCompletion];
}

@end
