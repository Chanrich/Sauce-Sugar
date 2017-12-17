//
//  MainMenuTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/10/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "MainMenuTableViewController.h"
#import "GlobalNames.h"

@interface MainMenuTableViewController ()

@end

@implementation MainMenuTableViewController {
    // View created to dismiss slide-out menu view when main view is clicked while slide-out menu is out
    UIView* blockingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Hide navigation bar's shadow line
    [self.navigationController.navigationBar setValue:@(YES) forKey:@"hidesShadow"];
    
    // Listen for button click event in slide-out menu to return panel to original position
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSuperViewToOriginal) name:@"slideSuperViewBack" object:nil];
    
    // Listen for ADD button click event slide-out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:@"addNewItem" object:nil];
    
    // Listen for SIGN UP button click event slide-out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushAddUserViewController) name:@"signUpNewUser" object:nil];
    
    // Listen for credit button click event in slide-out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushCreditsViewController) name:@"showCredit" object:nil];
    
    // Listen for credit button click event in slide-out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushSignInViewConroller) name:@"showSignIn" object:nil];
    
    // Listen for credit button click event in slide-out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLogout) name:@"userLogout" object:nil];
    
    // Request current GPS location
    // Initialize singleton instances
    rcAzureDataTable *rcDataConnection;
    rcDataConnection = [rcAzureDataTable sharedDataTable];
    // The location will be store at the rcDataConnection currentGPSLocation member;
    [rcDataConnection requestLocationData];
    
    // Request for sequence number to speed up process.
    NSString *username = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    [rcDataConnection getUniqueNumber_WithUsername:username Callback:^(NSDictionary *callbackItem) {
        // Do nothing with the returned data. Data should already be stored locally within the class
        NSLog(@"Sequence number is pre-loaded");
    }];
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
    return 1;
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


#pragma mark - Camera
// Bring up the camera and then add to database view
- (void) startCamera{
    // If camera module is not available, show alert message
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSLog(@"Camera not available");
        // ========= Create Alert =========
        // Create a UI AlertController to show warning message
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Camera not detected" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:okAction];
        // Show alert
        [self presentViewController:alert animated:YES completion:NULL];
        // ================================
    } else {
        // Camera is available
        NSLog(@"Camera detected");
        
        // Create a image picker controller to start camera
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Display camera
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

// After a picture is taken from camera, show AddToDataBaseViewController view
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *compressedImage = [self resizeImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    // Start a view to add information to database
    UIStoryboard *rcStoryBoard = [UIStoryboard storyboardWithName:@"insertToDatabase" bundle:nil];
    // Get a reference to the view
    AddToDatabase_ViewController *vc = [rcStoryBoard instantiateViewControllerWithIdentifier:@"AddToDataBaseViewController"];
    // Load image into the view's property
    vc.rcImageHolder = compressedImage;
    // Change entry animation
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    // Show view to insert new data
    [self showViewController:vc sender:NULL];
}

// Credit to stack overflow user: user4261201
-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 800;
    float maxWidth = 800;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.7; // Compression factor
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *originalImageData = UIImageJPEGRepresentation(image, 1);
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    // Debug, print out sizes
    NSLog(@"Original image size: %lu", (unsigned long)[originalImageData length]);
    NSLog(@"Compressed image size: %lu", (unsigned long)[imageData length]);
    
    return [UIImage imageWithData:imageData];
    
}

// If camera is cancelled, dismiss picker view controller
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Slide Out Menu Functions
// ===================== Slide Out Menu functions =====================

// Animate a slide out menu option to the right of the super view
- (void) slideSuperViewToRight{
    UIView *childView = [self getSlideOutMenuView];
    [self.tabBarController.view.superview sendSubviewToBack:childView];
    
    // If user click on main view while slide-out menu view is out, slide-out menu will be dismissed
    blockingView = [self blockUserInteractionAtCGRect:self.tabBarController.view.bounds];
    [self.tabBarController.view addSubview:blockingView];
    [blockingView viewFadeInToHalfAlphaWithCompletion:nil];
    
    [UIView animateWithDuration:SLIDE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tabBarController.view.frame = CGRectMake(SLIDEMENU_WIDTH, 0, self.tabBarController.view.frame.size.width, self.tabBarController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        if (finished){
            // Tag = 0, Menu is slided out
            self.rcSlideOutImage.tag = 0;
        }
    }];
}

// Animate super view back to original position
- (void) slideSuperViewToOriginal{
    [UIView animateWithDuration:SLIDE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tabBarController.view.frame = CGRectMake(0, 0, self.tabBarController.view.frame.size.width, self.tabBarController.view.frame.size.height);
        
        [blockingView viewFadeOutWithCompletion:^(BOOL rcFinished) {
            // Also dismiss the blocking view
            [blockingView removeFromSuperview];
        }];
        
    } completion:^(BOOL finished) {
        if (finished){
            [self.rcSlideOutMenuView.view removeFromSuperview];
            self.rcSlideOutMenuView = nil;
            // Tag = 1, Menu is in its original position
            self.rcSlideOutImage.tag = 1;
            
            // Reset shadow to default
            // [self setShadowForSlideOutMenu:NO offset:0];
        }
    }];
}

// Create a instance of slide-out menu and return its view
- (UIView *) getSlideOutMenuView{
    if (_rcSlideOutMenuView == nil){
        // Get storyboard
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"slideMenu" bundle:nil];
        
        // Get the view controller from storyboard
        self.rcSlideOutMenuView = (SlideOutMenuViewController*)[sb instantiateViewControllerWithIdentifier:@"SlideOutMenuID"];
        
        self.rcSlideOutMenuView.view.tag = SLIDEOUT_VIEW_TAG;
        self.rcSlideOutMenuView.delegate = self;
        
        // Add slide out menu view to the fullscreen tabBarController
        [self.tabBarController.view.superview addSubview:self.rcSlideOutMenuView.view];
        
        [self.rcSlideOutMenuView didMoveToParentViewController:self.tabBarController];
        
        // Set location of the slide out view to origin and size to fullscreen
        self.rcSlideOutMenuView.view.frame = CGRectMake(0, 0, self.tabBarController.view.frame.size.width , self.tabBarController.view.frame.size.height);
    }
    // Set shadow
    // [self setShadowForSlideOutMenu:YES offset:-2];

    return self.rcSlideOutMenuView.view;
}

// Gesture recognizer method to detect clicking of the menu image
- (IBAction)rcSlideMenu_Tapped:(id)sender {
    // Slide the menu out or in depending on the tag of the sender button
    // Tag = 0: Slideout Menu is in out position so slide it back in
    // Tag = 1: Slideout Menu is in in position so slide it out.
    switch (self.rcSlideOutImage.tag) {
        case 0:
            // Slide menu back to original position
            [self slideSuperViewToOriginal];
            break;
            
        case 1:
            // Slide menu out
            [self slideSuperViewToRight];
            break;
        default:
            NSLog(@"reached rcButton.tag default value. Program is not supposed to be here");
            break;
    }
}

// Set shadow of the super view to create cool effects
- (void) setShadowForSlideOutMenu:(BOOL)flag offset:(double)offset{
    if (flag){
        [self.tabBarController.view.layer setCornerRadius:CORNER_RADIUS];
        [self.tabBarController.view.layer setShadowColor: [UIColor blackColor].CGColor];
        [self.tabBarController.view.layer setShadowOpacity:0.8];
        [self.tabBarController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    } else {
        [self.tabBarController.view.layer setCornerRadius:0];
        // Return to default value
        [self.tabBarController.view.layer setShadowOffset:CGSizeMake(0.0  , -3.0)];
    }
}

// Create a view that cover whole main view while the slide-out menu is slided out thus any click on the main view will dismiss the slide-out menu
- (UIView*) blockUserInteractionAtCGRect:(CGRect)frameLocation{
    UIView *blockingView = [[UIView alloc] init];
    
    /* ============= Blur Effect ============= 
    // Blur is now removed as the blur is too strong for this effect. The code is kept here for future use.
    if (!UIAccessibilityIsReduceTransparencyEnabled()){
        // Add blur effect to the view
        NSLog(@"Blocking blur view is created");
        // If transparenct is not disabled
        UIBlurEffect *blurFx = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        blockingView = [[UIVisualEffectView alloc] initWithEffect:blurFx];
        blockingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        NSLog(@"Blocking normal view is created");
        blockingView = [[UIView alloc] init];
    }
    */
    blockingView.backgroundColor = [UIColor blackColor];
    blockingView.alpha = 0;
    blockingView.frame = frameLocation;
    blockingView.userInteractionEnabled = YES;
    
    // Create gesture recognizer to catch single tap event
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideSuperViewToOriginal)];
    [blockingView addGestureRecognizer:singleTap];
    
    return blockingView;
}

#pragma mark - UI Touch Events
/* ================ UI Touch Events ================ */

- (IBAction)RiceClicked:(id)sender {
    NSLog(@"RiceClicked");
    [self pushShowItemsViewControllerWithType:RICE];
    
}

- (IBAction)NoodlesClicked:(id)sender {
    NSLog(@"NoodlesClicked");
    [self pushShowItemsViewControllerWithType:NOODLES];
    
}

- (IBAction)IceCreamClicked:(id)sender {
    NSLog(@"IceCreamClicked");
    [self pushShowItemsViewControllerWithType:ICECREAM];
}


- (IBAction)DrinkClicked:(id)sender {
    NSLog(@"DrinkClicked");
    [self pushShowItemsViewControllerWithType:DRINK];
}

- (IBAction)DessertClicked:(id)sender {
    NSLog(@"DessertClicked");
    [self pushShowItemsViewControllerWithType:DESSERT];
}


#pragma mark - Create View Controllers for slide-out menu

// This private method will be called by each filter button to create data display view controller with filter pre-selected in parameter type
- (void) pushShowItemsViewControllerWithType:(enum FoodTypesEnum)type{
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"searchTable" bundle:nil];
    // Get the view controller from storyboard
    ShowItemsTableViewController *showdataVC = (ShowItemsTableViewController*)[sb instantiateViewControllerWithIdentifier:@"searchTableID"];
    // Set the enum constant
    showdataVC.searchFoodType = type;
    // Show view controller
    [self.navigationController pushViewController:showdataVC animated:YES];
    
    }

// SlideOutMenuView will call this method when sign up button is clicked.
// This method will show AddUserViewController.
- (void) pushAddUserViewController{
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"slideMenu" bundle:nil];
    // Get the view controller from storyboard
    ShowItemsTableViewController *vc = (ShowItemsTableViewController*)[sb instantiateViewControllerWithIdentifier:@"AddUserViewControllerID"];
    
    // Hide tab bar
    vc.hidesBottomBarWhenPushed = YES;
    // Show vc
    [self.navigationController pushViewController:vc animated:YES];
}

// SlideOutMenuView will call this method when credit button is clicked.
// This method will show CreditsViewController.
- (void) pushCreditsViewController{
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"slideMenu" bundle:nil];
    // Get the view controller from storyboard
    ShowItemsTableViewController *vc = (ShowItemsTableViewController*)[sb instantiateViewControllerWithIdentifier:@"creditsVC_ID"];
    
    // Hide tab bar
    vc.hidesBottomBarWhenPushed = YES;
    // Show vc
    [self.navigationController pushViewController:vc animated:YES];
}

// SlideOutMenuView will call this method when sign pu button is clicked
- (void) pushSignInViewConroller{
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"slideMenu" bundle:nil];
    // Get the view controller from storyboard
    LoginViewController *vc = (LoginViewController*)[sb instantiateViewControllerWithIdentifier:@"LoginViewControllerID"];
    
    // Hide tab bar
    vc.hidesBottomBarWhenPushed = YES;
    // Show vc
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark User logout
// SlideOutMenuView will call this method when sign pu button is clicked
- (void) userLogout{
    // Request username
    NSString *username = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    // Show log out message
    NSString *sLogoutBody = [NSString stringWithFormat:@"%@ is logged out", username];
    // Log out current user
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutUser];
    // ========= Create Alert =========
    // Create a UI AlertController to show warning message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:username message:sLogoutBody preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    [alert addAction:okAction];
    // Show alert
    [self presentViewController:alert animated:YES completion:NULL];
    // ================================
}



@end
