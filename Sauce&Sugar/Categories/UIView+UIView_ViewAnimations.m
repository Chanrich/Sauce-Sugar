//
//  UIView+UIView_ViewAnimations.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/5/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

// Define a constant fading duration

#import "UIView+UIView_ViewAnimations.h"
#import "GlobalNames.h"
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

- (void) viewFadeInToHalfAlphaWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion{
    [UIView animateWithDuration:fadeDuration_fast animations:^{
        // Perform fading animation by adjusting alpha
        [self setAlpha:0.5];
    } completion:rcCompletion];
}

@end
