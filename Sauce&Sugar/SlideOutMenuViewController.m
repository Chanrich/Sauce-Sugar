//
//  SlideOutMenuViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/20/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "SlideOutMenuViewController.h"

@interface SlideOutMenuViewController ()

@end

@implementation SlideOutMenuViewController {
    CreditsViewController *creditVC;
    UIStoryboard *sb;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *username = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.usernameCell.textLabel.text = [NSString stringWithFormat:@"Hi, %@", username];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // indexPath.row is the currently selected row, use it to access menu items
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Selected indexPath.row: %ld", (long)indexPath.row);
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            // Reset slide menu button so it will allow this menu to slide back again
            [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewItem" object:nil];

            break;
        case 3: // LOGIN BUTTON
            // Reset slide menu button so it will allow this menu to slide back again
            [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
            
            break;
        case 4: // SIGN UP BUTTON
            // Reset slide menu button so it will allow this menu to slide back again
            [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
            
            // Call target vc from main view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpNewUser" object:nil];
            break;
        case 5: //Credit
            // Reset slide menu button so it will allow this menu to slide back again
            [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
            
            // Call target vc from main view
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showCredit" object:nil];
            break;
        default:
            break;
    }
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// Send a notification message to slide super view back
- (IBAction)slideMenuSlideBackButton_TouchUpInside:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
}
@end
