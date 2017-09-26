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
    
    // Prepare username into dictionary collection
    [self.rcDataConnection prepareUserData:self.rcAddUser.text];
    
    NSLog(@"Inserting data into Azure table");
    // Insert data into table rcUserDataInfo
    [self.rcDataConnection InsertDataIntoTable:@"rcUserDataInfo"];
}

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}
@end
