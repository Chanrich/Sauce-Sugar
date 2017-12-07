//
//  LoginViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 12/6/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

// UI outlets
@property (strong, nonatomic) IBOutlet UITextField *rcUsernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *rcPasswordTextField;
@property (strong, nonatomic) IBOutlet UIButton *rcLoginButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *rcActivityIndicator;



@end
