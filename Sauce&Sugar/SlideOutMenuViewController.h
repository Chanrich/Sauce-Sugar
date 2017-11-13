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
@protocol SlideOutMenuViewControllerDelegate <NSObject>
@optional
- (void) menuOptionSelected;

// @required

@end

@interface SlideOutMenuViewController : UITableViewController
@property (nonatomic, assign) id<SlideOutMenuViewControllerDelegate> delegate;
// UI Cell outlets
@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;

// Send a notification message to slide super view back
- (IBAction)slideMenuSlideBackButton_TouchUpInside:(id)sender;

@end
