//
//  AddUserViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/24/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "rcAzureDataTable.h"

@interface AddUserViewController : UIViewController <UITextFieldDelegate>
// UI elements
@property (strong, nonatomic) IBOutlet UITextField *rcAddUser;
@property (strong, nonatomic) IBOutlet UIButton *rcButton_Adduser;
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;

// UI Events
- (IBAction)AddUser_TouchUpInside:(id)sender;

@end
