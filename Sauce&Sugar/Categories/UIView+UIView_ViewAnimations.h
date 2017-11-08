//
//  UIView+UIView_ViewAnimations.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/5/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_ViewAnimations)
- (void) viewFadeInWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion;
- (void) viewFadeOutWithCompletion:(void(^ __nullable)(BOOL rcFinished))rcCompletion;
@end
