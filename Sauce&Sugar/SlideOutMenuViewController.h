//
//  SlideOutMenuViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/20/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToDatabase_ViewController.h"
#import "CreditsViewController.h"
#import "AppDelegate.h"

// Another way to implement
@protocol SlideOutMenuViewControllerDelegate <NSObject>
@optional
// Another way to ask main view controller to execute function is with delegate calling. However, This is currently not implemented. Notification center is used to interact with main view controller
- (void) menuOptionSelected;

// @required

@end

@interface SlideOutMenuViewController : UITableViewController
@property (nonatomic, assign) id<SlideOutMenuViewControllerDelegate> delegate;

@end
