//
//  MainMenuButton.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/9/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "MainMenuButton.h"

@implementation MainMenuButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// Storyboard initialize with initWithCoder function, overing this function to add features to touch up and touch down event
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSLog(@"Custom button init Event");
    self = [super initWithCoder:aDecoder];
    
    // Create a gradient touch up sublayer and insert it to index 0th position
    self.gradientTouchUp = [CAGradientLayer layer];
    self.gradientTouchUp.frame = self.bounds;
    self.gradientTouchUp.colors =  [NSArray arrayWithObjects:(id)([UIColor colorWithRed:0.0 green:0.296 blue:0.70 alpha:1.00].CGColor),(id)([UIColor colorWithRed:0.33 green:0.83 blue:1.00 alpha:1.00].CGColor) , nil];
    self.gradientTouchUp.startPoint = CGPointMake(0.5, 0);
    self.gradientTouchUp.endPoint = CGPointMake(0.5, 1);
    [self.layer insertSublayer:self.gradientTouchUp atIndex:0];
    
    // Create a gradient touch down sublayer
    self.gradientTouchDown = [CAGradientLayer layer];
    self.gradientTouchDown.frame = self.bounds;
    self.gradientTouchDown.colors =  [NSArray arrayWithObjects:(id)([UIColor colorWithRed:0.2 green:0.5 blue:1 alpha:1.00].CGColor),(id)([UIColor colorWithRed:0.5 green:1 blue:1.00 alpha:1.00].CGColor) , nil];
    self.gradientTouchDown.startPoint = CGPointMake(0.5, 0);
    self.gradientTouchDown.endPoint = CGPointMake(0.5, 1);
    
    // Register touch events handlers
    [self addTarget:self action:@selector(rcTouchDownEvent) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(rcTouchCancelEvent) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(rcTouchCancelEvent) forControlEvents:UIControlEventTouchUpOutside];
    return self;
}

//
//- (void) setHighlighted:(BOOL)highlighted {
//    [super setHighlighted:highlighted];
//    
//    // Do something if highlighted
//    if (highlighted){

//    } else {

//    }
//    
//}

- (void) setCustomGradient{
    
}

// Change state to being depressed
- (void) rcTouchDownEvent {
    // Show touch down background
    [self.layer replaceSublayer:self.gradientTouchUp with:self.gradientTouchDown];
}

// Return image state to normal
- (void) rcTouchCancelEvent {
    // Show touch up background
    [self.layer replaceSublayer:self.gradientTouchDown with:self.gradientTouchUp];
}
@end
