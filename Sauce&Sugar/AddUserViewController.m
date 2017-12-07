//
//  AddUserViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/24/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AddUserViewController.h"
#import "GlobalNames.h"

@interface AddUserViewController ()


@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"Entering Sign up page");
    // Set textfield delegate to self to hide keyboard
    self.rcAddUser.delegate = self;
    self.rcUserPasswordTextField.delegate = self;
    
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    NSLog(@"Start setting alpha to 0");
    // Set all UI elements alpha to 0 before fading in
    [self.rcPasswordLabel setAlpha:0];
    [self.rcUserPasswordTextField setAlpha:0];
    [self.rcUsernameLabel setAlpha:0];
    [self.rcAddUser setAlpha:0];
    [self.rcButton_Adduser setAlpha:0];
    
    NSLog(@"Start animation");
    // Fade in UI elements
    [self.rcPasswordLabel viewFadeInWithCompletion:^(BOOL rcFinished) {
        [self.rcUserPasswordTextField viewFadeInWithCompletion:^(BOOL rcFinished) {
            [self.rcButton_Adduser viewFadeInWithCompletion:nil];
        }];
    }];
    [self.rcUsernameLabel viewFadeInWithCompletion:^(BOOL rcFinished) {
        [self.rcAddUser viewFadeInWithCompletion:nil];
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Insert user info into table rcUserDataInfo
- (IBAction)AddUser_TouchUpInside:(id)sender {
    // Remove text from the button and start spinning indicator
    [self.rcButton_Adduser setTitle:@"Create" forState:UIControlStateNormal];
    [self.rcButton_Adduser setTitle:@"" forState:UIControlStateDisabled];
    [self.rcButton_Adduser setEnabled:FALSE];
    [self.rcActivityIndicator startAnimating];
    
    [self.rcDataConnection verifyUsername:self.rcAddUser.text Callback:^(BOOL callbackItem) {
        if (callbackItem == YES){
            NSLog(@"Creating new user");
            // Prepare username into dictionary collection
            [self.rcDataConnection InsertIntoTableWithUsername:self.rcAddUser.text Password:self.rcUserPasswordTextField.text Callback:^(NSNumber *completeFlag) {
                // Stop animation
                [self.rcActivityIndicator stopAnimating];
                if ([completeFlag isEqualToNumber:@YES]){
                    // User successfully created
                    [self.rcButton_Adduser setTitle:@"Completed" forState:UIControlStateDisabled];
                    // Delay 2 seconds and then exit this view
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        // Dismiss view controller
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } else {
                    // Something went wrong
                    // ========= Create Alert =========
                    // Create a UI AlertController to show warning message
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error occured while creating new user" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:NULL];
                    // ================================
                    [self.rcButton_Adduser setEnabled:FALSE];
                    [self.rcButton_Adduser setTitle:@"Error.." forState:UIControlStateDisabled];
                    
                    
                }
            }];
        } else{
            // Stop spinning
            [self.rcActivityIndicator stopAnimating];
            NSLog(@"Error: username existing. User is not created");
            // ========= Create Alert =========
            // Create a UI AlertController to show warning message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Username already existed" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:NULL];
            // ================================
            [self.rcButton_Adduser setEnabled:YES];
        }
    }];

    
}

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
@end
