//
//  ViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddToDatabase_ViewController.h"
#import "MainMenuButton.h"
#import "SlideOutMenuViewController.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *AddButton;
// Placeholder for slideout menu
@property (strong, nonatomic) IBOutlet UIButton *SlideMenuButton;
@property (strong, nonatomic) SlideOutMenuViewController *rcSlideOutMenuView;
@property (strong, nonatomic) IBOutlet UIButton *slideBackButton;

- (IBAction)TouchUp_CameraButton:(id)sender;
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

- (IBAction)MenuTouchUpInside:(id)sender;
- (IBAction)slidePanelBackFullscreenButtonTouchUpInside:(id)sender;


@end

