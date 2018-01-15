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
    [self.creditsTextView insertText:@"Stew icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"User icon: Icon made by Smashicons from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"User_profile icon: Icon made by Chanut is Industries from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Contract icon: Icon made by Prosymbols from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Restaurant icon: Icon made by Freepik from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Add button icon: Icon made by Google Material Design from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Login button icon: Icon made by Anatoly from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Add User icon: Icon made by Freepik from www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Credit icon: Icon made by Catalin Fertu from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Credit icon: Icon made by Google Material Design from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Error icon: Icon made by Smashicons from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/checked_291201#term=check&page=1&position=5
    [self.creditsTextView insertText:@"Green check icon: Icon made by Maxim Basinski from  www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Star icon: Icon made by Freepik from www.flaticon.com\n"];
    [self.creditsTextView insertText:@"Search Table User icon: Icon made by Smashicons from www.flaticon.com\n"];
    // Food Type
    // https://www.flaticon.com/free-icon/rice_184532#term=rice&page=1&position=77
    [self.creditsTextView insertText:@"Rice icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/noodles_605282#term=noodles&page=2&position=51
    [self.creditsTextView insertText:@"Noodles icon: Icon made by Smashicons from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/ice-cream_422929#term=ice cream&page=1&position=59
    [self.creditsTextView insertText:@"Ice cream icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/doughnut_135559#term=doughnut&page=1&position=2
    [self.creditsTextView insertText:@"Doughnut icon: Icon made by Smashicons from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/water_648636#term=water&page=1&position=24
    [self.creditsTextView insertText:@"Water icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/info_148769#term=question&page=1&position=3
    [self.creditsTextView insertText:@"Info icon: Icon made by Smashicons from www.flaticon.com\n"];
    
    // New
    
    // https://www.flaticon.com/free-icon/soup_454570#term=soup&page=1&position=33
    [self.creditsTextView insertText:@"Soup icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/steak_415686#term=steak&page=1&position=47
    [self.creditsTextView insertText:@"Steak icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/waffle_454557#term=waffle&page=1&position=11
    [self.creditsTextView insertText:@"Waffle icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/fried-egg_119500#term=egg&page=1&position=66
    [self.creditsTextView insertText:@"Fried-Egg icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/salad_579103#term=salad&page=1&position=26
    [self.creditsTextView insertText:@"Salad icon: Icon made by Twitter from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/taco_579028#term=taco&page=1&position=16
    [self.creditsTextView insertText:@"Taco icon: Icon made by Twitter from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/burger_199636#term=hamburger&page=1&position=16
    [self.creditsTextView insertText:@"Burger icon: Icon made by Freepik from www.flaticon.com\n"];
    
    // https://www.flaticon.com/free-icon/store_123403#term=restaurant&page=1&position=6
    [self.creditsTextView insertText:@"Store icon: Icon made by Freepik from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/users_149066#term=users&page=1&position=19
    [self.creditsTextView insertText:@"Users icon: Icon made by Smashicons from www.flaticon.com\n"];
    // https://www.flaticon.com/free-icon/food_608857#term=food&page=1&position=53
    [self.creditsTextView insertText:@"Food icon: Icon made by Smashicons from www.flaticon.com\n"];
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
