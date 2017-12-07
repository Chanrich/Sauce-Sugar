//
//  LoginViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 12/6/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "LoginViewController.h"
#import "rcAzureDataTable.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    // Singleton instance of table data management
    rcAzureDataTable *rcDataConnection;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Initialize singleton instances
    rcDataConnection = [rcAzureDataTable sharedDataTable];
    
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

// If the username and password match any entry in the user data base, log in the user.
- (IBAction)LoginButtonPressed:(id)sender {
}

@end
