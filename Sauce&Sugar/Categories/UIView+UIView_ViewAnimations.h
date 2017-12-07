//
//  UIView+UIView_ViewAnimations.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/5/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_ViewAnimations)
// Completely fade in the view
- (void) viewFadeInWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion;
- (void) viewFadeOutWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion;

// Fade to alpha 0.5
- (void) viewFadeInToHalfAlphaWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion;
@end
