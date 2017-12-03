//
//  CreditsViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/9/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "CreditsViewController.h"

@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.creditsTextView insertText:@"Credits:\n"];
    [self.creditsTextView insertText:@"Rice icon: Icon made by Freepik from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Noodles icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Drink icon: Icon made by Iconnice from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Ice cream icon: Icon made by Freepik from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Cake icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Stew icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"User icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"User_profile icon: Icon made by Chanut is Industries from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Contract icon: Icon made by Prosymbols from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Restaurant icon: Icon made by Freepik from  www.flaticon.com\n"];
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
- (IBAction)DoneButton_TouchUpInside:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
