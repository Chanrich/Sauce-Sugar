//
//  AddUserViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/24/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AddUserViewController.h"

@interface AddUserViewController ()

@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set textfield delegate to self to hide keyboard
    self.rcAddUser.delegate = self;
    self.rcUserPasswordTextField.delegate = self;
    
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
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
    // TODO: check for existing username with same name
    [self.rcDataConnection verifyUsername:self.rcAddUser.text Callback:^(BOOL callbackItem) {
        if (callbackItem == YES){
            NSLog(@"Creating new user");
            // Prepare username into dictionary collection
            [self.rcDataConnection InsertIntoTableWithUsername:self.rcAddUser.text];
        } else{
            NSLog(@"Error: username existing. User is not created");
        }
    }];

    
}

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
@end
