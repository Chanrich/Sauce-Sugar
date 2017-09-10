//
//  MainMenuButton.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/9/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuButton : UIButton

@property CAGradientLayer *gradientTouchUp;
@property CAGradientLayer *gradientTouchDown;

- (void) setCustomGradient;
@end
