//
//  LoginViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 12/6/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "LoginViewController.h"
#import "rcAzureDataTable.h"
#import "GlobalNames.h"
#import "UIView+UIView_ViewAnimations.h"

@interface LoginViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@end

@implementation LoginViewController {
    // Singleton instance of table data management
    rcAzureDataTable *rcDataConnection;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide all view
    [self.rcUsernameTextField setAlpha:0];
    [self.rcPasswordTextField setAlpha:0];
    [self.rcUsernameLabel setAlpha:0];
    [self.rcPasswordLabel setAlpha:0];
    [self.rcLoginButton setAlpha:0];
    
    // Initialize singleton instances
    rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Set text field delegate
    self.rcUsernameTextField.delegate = self;
    self.rcPasswordTextField.delegate = self;
    
    // Fade in all views
    [self.rcUsernameTextField viewFadeInWithCompletion:nil];
    [self.rcPasswordTextField viewFadeInWithCompletion:nil];
    [self.rcUsernameLabel viewFadeInWithCompletion:nil];
    [self.rcPasswordLabel viewFadeInWithCompletion:nil];
    [self.rcLoginButton viewFadeInWithCompletion:nil];
    
    // Tap anywhere on view to remove keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapping)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
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

#pragma mark - UI events
// If the username and password match any entry in the user data base, log in the user.
- (IBAction)LoginButtonPressed:(id)sender {
    NSString *textUsername = self.rcUsernameTextField.text;
    NSString *textPassword = self.rcPasswordTextField.text;
    
    // Enable UI
    [self.rcActivityIndicator startAnimating];
    
    // Remove keyboard
    [[self view] endEditing:YES];
    
    // Disable command button
    [self.rcLoginButton setTitle:@"" forState:UIControlStateDisabled];
    [self.rcLoginButton setEnabled:NO];
    
    // Search for the username and password combination in database
    [rcDataConnection verifyUserAccount:textUsername Password:textPassword Callback:^(BOOL callbackItem) {
        // Stop indicator from spinning
        [self.rcActivityIndicator stopAnimating];
        
        // Re-enable command button
        [self.rcLoginButton setEnabled:YES];
        
        // ========= Create Alert =========
        // Create a UI AlertController to show warning message
        UIAlertController *alert;
        UIAlertAction *okAction;
        // ================================
        
        // User is found if callbackItem is YES
        if (callbackItem == TRUE){
            // Login successful, set username and password
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUsername:textUsername];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] setPassword:textPassword];
            
            NSString *welcomeMsg = [NSString stringWithFormat:@"User %@ is logged on", textUsername];
            alert = [UIAlertController alertControllerWithTitle:@"Successful" message:welcomeMsg     preferredStyle:UIAlertControllerStyleAlert];
            okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // Update UI in main thread and return to main menu
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Wait for few seconds and then return to main menu
                    [self performSelector:@selector(returnToMainMenu) withObject:nil afterDelay:0.5];
                });
            }];
            
            
            // Create a credential object with username name and password, set persistence to NSURLCredentialPersistencePermanent so it will be stored in keychain
            NSURLCredential *credential;
            credential = [NSURLCredential credentialWithUser:textUsername password:textPassword persistence:NSURLCredentialPersistencePermanent];
            
            // Call app delegate method to store credential
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCredential:credential];
            
        } else {
            // Login failed, set username to null
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUsername:@""];
            
            // Set fail msg and alert
            NSString *failedMsg = [NSString stringWithFormat:@"User %@ is not logged on", textUsername];
            alert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:failedMsg     preferredStyle:UIAlertControllerStyleAlert];
            okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            // Clear text field and set focus to username field
            [self.rcUsernameTextField setText:@""];
            [self.rcPasswordTextField setText:@""];
            [self.rcUsernameTextField becomeFirstResponder];
        }
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
    }];
}

#pragma mark - Text Field Handling
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.rcUsernameTextField){
        NSLog(@"Move to next field");
        [self.rcPasswordTextField becomeFirstResponder];
    } else if (textField == self.rcPasswordTextField){
        // Click on the create button
        [self LoginButtonPressed:textField];
    }
    return NO;
}

// This is called when background view is tapped
- (void) tapping{
    // End text edit
    [[self view] endEditing:YES];
}

#pragma mark - Window Exiting
    
    // This function will be called when everything completes to return to main menu
- (void) returnToMainMenu{
        [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
