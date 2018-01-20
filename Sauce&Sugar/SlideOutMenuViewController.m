//
//  SlideOutMenuViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/20/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "SlideOutMenuViewController.h"
#import "GlobalNames.h"
@interface SlideOutMenuViewController ()

@end

@implementation SlideOutMenuViewController {
    CreditsViewController *creditVC;
    UIStoryboard *sb;
    IBOutlet UITableView *rcTableview;
    IBOutlet UILabel *LoginLogoutLabel;
    IBOutlet UIImageView *LoginLogoutImage;
    // The label at the top of the menu
    IBOutlet UILabel *usernameLabel;
    // Store user info
    NSString *username;
    bool bUserLoggedIn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    username = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if ([username isEqualToString:AZURE_USER_GUEST]){
        // Username invalid
        usernameLabel.text = [NSString stringWithFormat:@"Please Login"];
        
        // Allow user to log in
        [LoginLogoutLabel setText:@"Login"];
        bUserLoggedIn = 0;
    } else {
        usernameLabel.text = [NSString stringWithFormat:@"Hi, %@", username];
        
        // Current user can logout with this button
        [LoginLogoutLabel setText:@"LOGOUT"];
        bUserLoggedIn = 1;
    }
    
    // === Following code enable tap-dismiss on the background of the tableview ===
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSlideOutMenu)];
    UIView *bkgView = [[UIView alloc] init];
    rcTableview.backgroundView = bkgView;
    [rcTableview.backgroundView addGestureRecognizer:tapGesture];
    // =============================================================================
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
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SLIDE_DURATION * NSEC_PER_SEC));

    
    switch (indexPath.row) {
        case 0:
            break;
        case 1:
            break;
        case 2:
            // Reset slide menu button so it will allow this menu to slide back again
            [self dismissSlideOutMenu];
            
            // Wait for main view to return to original position
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addNewItem" object:nil];
            });


            break;
        case 3: // LOGIN/OUT BUTTON
            // Reset slide menu button so it will allow this menu to slide back again
            [self dismissSlideOutMenu];
            
            // Log the user out if a user is logged in
            if (bUserLoggedIn == 1){
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // Call target vc from main view
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"userLogout" object:nil];
                });
            } else {
                // Show sign in page if no user is logged in
                // Wait for main view to return to original position
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    // Call target vc from main view
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showSignIn" object:nil];
                });

            }
            break;
        case 4: // SIGN UP BUTTON
            // Reset slide menu button so it will allow this menu to slide back again
            [self dismissSlideOutMenu];
            
            // Wait for main view to return to original position
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Call target vc from main view
                [[NSNotificationCenter defaultCenter] postNotificationName:@"signUpNewUser" object:nil];
            });
            break;
        case 5: //Credit
            // Reset slide menu button so it will allow this menu to slide back again
            [self dismissSlideOutMenu];
            // Wait for main view to return to original position
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Call target vc from main view
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showCredit" object:nil];
            });

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

#pragma mark - Dismiss Self
- (void) dismissSlideOutMenu{
    // Send a message to main view to dismiss the slide-out view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"slideSuperViewBack" object:nil];
}


#pragma mark - Footer
// Set footer content, there is only 1 section
- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    // Create a footer with width of the slideout view minus some margin
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SLIDEMENU_WIDTH - 20, 30)];
    footer.backgroundColor = [UIColor darkGrayColor];
    
    // Extract versioning information
    NSDictionary *pinfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionString = [NSString stringWithFormat:@"v%@(%@)", [pinfo objectForKey:@"CFBundleShortVersionString"], [pinfo objectForKey:@"CFBundleVersion"]];
    
    // Configure version label to display current version information
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:footer.frame];
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.text = versionString;
    versionLabel.textAlignment = NSTextAlignmentRight;
    
    [footer addSubview:versionLabel];
    
    return footer;
}

// Set footer height
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    // Just return height of 30 points as there is only 1 section
    return 30;
}
@end
