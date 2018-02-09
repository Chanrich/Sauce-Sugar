//
//  AddUserViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/24/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AddUserViewController.h"
#import "GlobalNames.h"

@interface AddUserViewController () <UIGestureRecognizerDelegate>


@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set textfield delegate to self to hide keyboard
    self.rcAddUser.delegate = self;
    self.rcUserPasswordTextField.delegate = self;
    
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Set all UI elements alpha to 0 before fading in
    [self.rcPasswordLabel setAlpha:0];
    [self.rcUserPasswordTextField setAlpha:0];
    [self.rcUsernameLabel setAlpha:0];
    [self.rcAddUser setAlpha:0];
    [self.rcButton_Adduser setAlpha:0];
    
    // Fade in UI elements
    [self.rcPasswordLabel viewFadeInWithCompletion:nil];
    [self.rcUserPasswordTextField viewFadeInWithCompletion:nil];
    [self.rcButton_Adduser viewFadeInWithCompletion:nil];
    [self.rcAddUser viewFadeInWithCompletion:nil];
    [self.rcUsernameLabel viewFadeInWithCompletion:nil];
    
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

#pragma mark - UI Events

// Insert user info into table rcUserDataInfo
- (IBAction)AddUser_TouchUpInside:(id)sender {
    // Remove text from the button and start spinning indicator
    [self.rcButton_Adduser setTitle:@"Create" forState:UIControlStateNormal];
    [self.rcButton_Adduser setTitle:@"" forState:UIControlStateDisabled];
    [self.rcButton_Adduser setEnabled:FALSE];
    [self.rcActivityIndicator startAnimating];
    
    // Remove keyboard
    [[self view] endEditing:YES];
    
    [self.rcDataConnection verifyUsername:self.rcAddUser.text Callback:^(BOOL callbackItem) {
        if (callbackItem == YES){
            NSLog(@"Creating new user");
            // Prepare username into dictionary collection
            [self.rcDataConnection InsertIntoUserTableWithUsername:self.rcAddUser.text Password:self.rcUserPasswordTextField.text Callback:^(NSDictionary* returnedDictionary) {
                // Stop animation
                [self.rcActivityIndicator stopAnimating];
                if (returnedDictionary != nil){
                    // User successfully created
                    [self.rcButton_Adduser setTitle:@"Completed" forState:UIControlStateDisabled];
                    
                    // Login current user
                    NSString *newUsername = [returnedDictionary objectForKey:AZURE_USER_TABLE_USERNAME];
                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUsername:newUsername];
                    
                    // ============== Store User Credential ===============
                    // Save username and password into keychain
                    NSURLCredential *credential;
                    
                    // Create a credential object with username name and password, set persistence to NSURLCredentialPersistencePermanent so it will be stored in keychain
                    credential = [NSURLCredential credentialWithUser:self.rcAddUser.text password:self.rcUserPasswordTextField.text persistence:NSURLCredentialPersistencePermanent];
                    
                    // Call app delegate method to store credential
                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCredential:credential];
                    // ========================================================
                    
                    // Show welcome message
                    NSString *welcomeMsg = [NSString stringWithFormat:@"User %@ is logged in", newUsername];
                    
                    // Create a UI AlertController to show welcome message
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Welcome" message:welcomeMsg preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alert addAction:okAction];
                    [self presentViewController:alert animated:YES completion:NULL];
                    
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
            NSLog(@"Error: username existing. User is not created");
            // ========= Create Alert =========
            // Create a UI AlertController to show warning message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Username already existed" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:NULL];
            // ===== Reset UI =====
            [self.rcAddUser setText:@""];
            [self.rcUserPasswordTextField setText:@""];
            [self.rcButton_Adduser setEnabled:YES];
            // Stop spinning
            [self.rcActivityIndicator stopAnimating];
        }
    }];

    
}

#pragma mark - Text Field Handling
// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.rcAddUser){
        NSLog(@"Move to next field");
        [self.rcUserPasswordTextField becomeFirstResponder];
    } else if (textField == self.rcUserPasswordTextField){
        // Click on the create button
        [self AddUser_TouchUpInside:textField];
    }
   
    return NO;
}

// This is called when background view is tapped
- (void) tapping{
    // End text edit
    [[self view] endEditing:YES];
}
@end
