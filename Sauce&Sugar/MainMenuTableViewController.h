//
//  MainMenuTableViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/10/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToDatabase_ViewController.h"
#import "SlideOutMenuViewController.h"
#import "ShowItemsTableViewController.h"
#import "LoginViewController.h"
@interface MainMenuTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, SlideOutMenuViewControllerDelegate>
// UI ImageView button to call slideout menu
@property (strong, nonatomic) IBOutlet UIImageView *rcSlideOutImage;

- (IBAction)rcSlideMenu_Tapped:(id)sender;


// Custom slide out menu view controller
@property (strong, nonatomic) SlideOutMenuViewController *rcSlideOutMenuView;
// Start camera capture view, and after a picture is taken, transition to AddToDataBaseViewController
- (void) startCamera;

// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
