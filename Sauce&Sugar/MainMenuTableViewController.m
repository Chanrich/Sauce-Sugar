//
//  MainMenuTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/10/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "MainMenuTableViewController.h"
#import "GlobalNames.h"

@interface MainMenuTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation MainMenuTableViewController {
    // View created to dismiss slide-out menu view when main view is clicked while slide-out menu is out
    UIView* blockingView;
    IBOutlet UICollectionView *typeSelectCollectView;
    // Initialize singleton instances
    rcAzureDataTable *rcDataConnection;

    // UI elements
    IBOutlet UIView *rcAroundContainerView;
    IBOutlet UILabel *rcRestaurantNumLabel;
    IBOutlet UILabel *rcUsersNumLabel;
    IBOutlet UILabel *rcFoodNumLabel;
    // Activity Indicators
    IBOutlet UIActivityIndicatorView *resActivityIndicator;
    IBOutlet UIActivityIndicatorView *userActivityIndicator;
    IBOutlet UIActivityIndicatorView *foodActivityIndicator;
    
    // Declare private variables
    NSString *gUsername;
    
    // Last loaded counts by <setupDataCountContainerView>
    NSNumber *lastLoadedFoodCount;
    NSNumber *lastLoadedRestaurantCount;
    NSNumber *lastLoadedUsersCount;
    
    // Store camera picture compression that will be send to Insert new data view controller
    unsigned long orignalImageSize;
    unsigned long newImageSize;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Hide navigation bar's shadow line
    [self.navigationController.navigationBar setValue:@(YES) forKey:@"hidesShadow"];
    
    // Hide the container view
    rcAroundContainerView.alpha = 0;
    
    // Initialize last counts
    lastLoadedFoodCount = @(-1);
    lastLoadedRestaurantCount = @(-1);
    lastLoadedUsersCount = @(-1);
    
    // Fade in the rcAroundContainerView that holds What's Around Me UIs
    [rcAroundContainerView viewFadeInWithCompletion:nil];
    
    // Clear all text labels in What's Around Me container as the function <setupDataCountContainerView> should update these text
    [rcRestaurantNumLabel setText:@"Restaurant:"];
    [rcUsersNumLabel setText:@"Users:"];
    [rcFoodNumLabel setText:@"Food:"];
    [resActivityIndicator startAnimating];
    [userActivityIndicator startAnimating];
    [foodActivityIndicator startAnimating];
    
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
    

    rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Request current GPS location
    [rcDataConnection requestLocationData];
    
    // Verify stored user identification
    NSURLCredential *userCred = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUserCredentail];
    if (userCred == nil){
        NSLog(@"No Credential is found");
        gUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    } else {
        NSLog(@"User credential retrieved... Username: %@\tPassword:%@", userCred.user, userCred.password);
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUsername:userCred.user];
        
        // =========== Show welcome message ============
        UIAlertController *alert;
        UIAlertAction *okAction;
        NSString *welcomeMsg = [NSString stringWithFormat:@"User %@ is logged on", userCred.user];
        alert = [UIAlertController alertControllerWithTitle:@"WELCOME BACK" message:welcomeMsg     preferredStyle:UIAlertControllerStyleAlert];
        okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
    }
    

    
    NSLog(@"Make contact with server...");
    [rcDataConnection getUniqueNumber_WithUsername:gUsername Callback:^(NSDictionary *callbackItem) {
        // Contact is created with the server, this should allow faster connection at next contact
        NSLog(@"<getUniqueNumber_WithUsername> Contacted the server");
    }];
    
    typeSelectCollectView.delegate = self;
}

// Every time the view appear, refresh data
- (void) viewDidAppear:(BOOL)animated{
    // Update username
    gUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    
    // Wait for a small delay to let GPS find current location
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Perform What's Around Me Section
        NSLog(@"<setupDataCountContainerView>");
        [self setupDataCountContainerView];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


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
    // Store image size comparisons
    vc.originalRcImageSize = [NSNumber numberWithUnsignedLong:orignalImageSize];
    vc.nRcImageSize = [NSNumber numberWithUnsignedLong:newImageSize];
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
    
    orignalImageSize = (unsigned long)[originalImageData length];
    newImageSize = (unsigned long)[imageData length];
    // Debug, print out sizes
    NSLog(@"Original image size: %lu", orignalImageSize);
    NSLog(@"Compressed image size: %lu", newImageSize);
    
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
    // Remove user credential
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] cleanUserCredential];
    
    // Show log out message
    NSString *sLogoutBody = [NSString stringWithFormat:@"%@ is logged out", gUsername];
    // Log out current user
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutUser];
    // ========= Create Alert =========
    // Create a UI AlertController to show warning message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:gUsername message:sLogoutBody preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
    [alert addAction:okAction];
    // Show alert
    [self presentViewController:alert animated:YES completion:NULL];
    // ================================
}
#pragma mark - Collection View Delegate

// Collection view should read icon names from rcDataConnection
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Declare a collection view cell designed in storyboard
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"mainCollectionViewCellID" forIndexPath:indexPath];
    
    // In storyboard, set:
    // - UIImageView's tag  to 9
    // - Label's tag        to 8
    UIImageView *cellImage = (UIImageView*)[cell viewWithTag:9];
    UILabel *cellLabel = (UILabel*)[cell viewWithTag:8];
    
    // Icon name and food type name will be returned from rcDataConnection
    NSString *iconName = [rcDataConnection getFoodIconNameWithIndex:indexPath.row];
    NSString *foodTypeName = [rcDataConnection getFoodTypeNameWithIndex:indexPath.row];
    
    // Set cell contents
    [cellLabel setText:foodTypeName];
    [cellImage setImage:[UIImage imageNamed:iconName]];
    
    return cell;
}

// Load all food types from rcDataConnection
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [rcDataConnection getTotalNumberOfType];
}


// When user tap on any item in the collectino view, push a view controller to show search result for that item
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger selectedIndex = indexPath.row;
    NSLog(@"selected : %ld", (long)selectedIndex);
    NSNumber *foodEnum = [rcDataConnection getFoodTypeEnumWithIndex:indexPath.row];
    NSLog(@"\t Enum: %@", foodEnum);
    [self pushShowItemsViewControllerWithType:(enum FoodTypesEnum)[foodEnum intValue]];
}

#pragma mark - Data Count Setup
// This function will retrieve all data for the region around the user and count/sort the returned data
- (void) setupDataCountContainerView{
    // Get all food type and from all users so pass in nil to user name field
    [rcDataConnection getDatafromUser:nil FoodType:FOODTYPE_ALL RangeOfSearch_Lat:0.8 RangeOfSearch_Long:0.8 Callback:^(NSArray *callbackItem) {
        // Data returned
        if (callbackItem == nil){
            // Nothing is performed
            NSLog(@"Abort, nothing is returned for <setupDataCountContainerView>");
        } else {
            NSNumber *totalCount = [NSNumber numberWithUnsignedLong:[callbackItem count]];

            NSLog(@"Total number of entries retrieved %@", totalCount);
            NSCountedSet *ResNameCSet = [NSCountedSet new];
            NSCountedSet *UserNameCSet = [NSCountedSet new];
            NSCountedSet *FoodTypeCSet = [NSCountedSet new];
            // Loop through each entry and count
            for (NSDictionary* oneDictionaryEntry in callbackItem){
                // Debug
                // NSLog(@"Print out dictionary in callbackItem: %@", oneDictionaryEntry);
                NSString *currentResName = [oneDictionaryEntry objectForKey:AZURE_DATA_TABLE_RESTAURANT_NAME];
                NSString *currentUserName = [oneDictionaryEntry objectForKey:AZURE_DATA_TABLE_USERNAME];
                NSNumber *currentFoodType = [oneDictionaryEntry objectForKey:AZURE_DATA_TABLE_FOODTYPE];
                // Check for repeats
                [ResNameCSet addObject:currentResName];
                [UserNameCSet addObject:currentUserName];
                [FoodTypeCSet addObject:currentFoodType];
            };
            // Get main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![lastLoadedUsersCount isEqualToNumber:@([UserNameCSet count])]){
                    NSLog(@"lastLoadedUsersCount changed");
                    // Stop spinning
                    [userActivityIndicator stopAnimating];
                    // Fade out and then fade in if there is a value change
                    [rcUsersNumLabel viewFadeOutWithCompletion:^(BOOL rcFinished) {
                        // Update text
                        [rcUsersNumLabel setText:[NSString stringWithFormat:@"Users: %lu", (unsigned long)[UserNameCSet count]]];
                        // Fade in
                        [rcUsersNumLabel viewFadeInWithCompletion:nil];
                    }];
                }
                
                if (![lastLoadedRestaurantCount isEqualToNumber:@([ResNameCSet count])]){
                    NSLog(@"lastLoadedRestaurantCount changed");
                    // Stop spinning
                    [resActivityIndicator stopAnimating];
                    // Fade out and then fade in if there is a value change
                    [rcRestaurantNumLabel viewFadeOutWithCompletion:^(BOOL rcFinished) {
                        // Update text
                        [rcRestaurantNumLabel setText:[NSString stringWithFormat:@"Restaurants: %lu", (unsigned long)[ResNameCSet count]]];
                        // Fade in
                        [rcRestaurantNumLabel viewFadeInWithCompletion:nil];
                    }];
                }
                NSLog(@"lastLoadedFoodCount: %@\t totalCount:%@",lastLoadedFoodCount, totalCount);
                if (![lastLoadedFoodCount isEqualToNumber:totalCount]){
                    NSLog(@"lastLoadedFoodCount changed");
                    // Stop spinning
                    [foodActivityIndicator stopAnimating];
                    // Fade out and then fade in if there is a value change
                    [rcFoodNumLabel viewFadeOutWithCompletion:^(BOOL rcFinished) {
                        // Update text
                        [rcFoodNumLabel setText:[NSString stringWithFormat:@"Foods: %@", totalCount]];
                        // Fade in
                        [rcFoodNumLabel viewFadeInWithCompletion:nil];
                    }];
                }
                
                // Store last counts
                lastLoadedRestaurantCount = [NSNumber numberWithUnsignedLong:[ResNameCSet count]];
                lastLoadedUsersCount = [NSNumber numberWithUnsignedLong:[UserNameCSet count]];
                lastLoadedFoodCount = totalCount;
            }); // End of dispatch to main queue
        } // End of callbackItem not nil, something is returned
    }]; // End of rcDataConnection getDatafromUser
}

@end
