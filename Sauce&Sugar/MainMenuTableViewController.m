//
//  MainMenuTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/10/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "MainMenuTableViewController.h"
#define SLIDEMENU_WIDTH 275
#define SLIDE_DURATION 0.2
#define CORNER_RADIUS 4
#define SLIDEOUT_VIEW_TAG 2

@interface MainMenuTableViewController ()

@end

@implementation MainMenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Listen for button click event in slideout menu to return panel to original position
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSuperViewToOriginal) name:@"slideSuperViewBack" object:nil];
    
    // Listen for ADD button click event slide out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:@"addNewItem" object:nil];
    
    // Request current GPS location
    // Initialize singleton instances
    rcAzureDataTable *rcDataConnection;
    rcDataConnection = [rcAzureDataTable sharedDataTable];
    // The location will be store at the rcDataConnection currentGPSLocation member;
    [rcDataConnection requestLocationData];
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

// ===================== Slide Out Menu functions =====================

- (IBAction)rcSlideOutMenuButton_TouchUpInside:(id)sender {
    UIButton *rcButton = sender;
    // Slide the menu out or in depending on the tag of the sender button
    // Tag = 0: Slideout Menu is in out position so slide it back in
    // Tag = 1: Slideout Menu is in in position so slide it out.
    switch (rcButton.tag) {
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

// Animate a slide out menu option to the right of the super view
- (void) slideSuperViewToRight{
    UIView *childView = [self getSlideOutMenuView];
    [self.tabBarController.view.superview sendSubviewToBack:childView];
    [UIView animateWithDuration:SLIDE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tabBarController.view.frame = CGRectMake(SLIDEMENU_WIDTH, 0, self.tabBarController.view.frame.size.width, self.tabBarController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        if (finished){
            // Tag = 0, Menu is slided out
            self.rcSlideOutMenuButton.tag = 0;
            
            // Enable fullscreen button to return to original position
            // self.slideBackButton.enabled = YES;
        }
    }];
}

// Animate super view back to original position
- (void) slideSuperViewToOriginal{
    [UIView animateWithDuration:SLIDE_DURATION delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.tabBarController.view.frame = CGRectMake(0, 0, self.tabBarController.view.frame.size.width, self.tabBarController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        if (finished){
            [self.rcSlideOutMenuView.view removeFromSuperview];
            self.rcSlideOutMenuView = nil;
            // Tag = 1, Menu is in its original position
            self.rcSlideOutMenuButton.tag = 1;
            
            // Reset shadow to default
            [self setShadowForSlideOutMenu:NO offset:0];
            
            // Disable fullscreen button for sliding original panel back
            // self.slideBackButton.enabled = NO;
        }
    }];
}

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
        self.rcSlideOutMenuView.view.frame = CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height);
        
        
    }
    
    // Set shadow
    [self setShadowForSlideOutMenu:YES offset:-2];

    UIView *returnView = self.rcSlideOutMenuView.view;
    return returnView;
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
- (IBAction)RiceClicked:(id)sender {
    NSLog(@"RiceClicked");
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"searchTable" bundle:nil];
    // Get the view controller from storyboard
    ShowItemsTableViewController *showdataVC = (ShowItemsTableViewController*)[sb instantiateViewControllerWithIdentifier:@"searchTableID"];
    // Set the enum constant
    showdataVC.searchFoodType = RICE;
    
    // Push the view controller onto navigation stack
    [self.navigationController pushViewController:showdataVC animated:YES];
    
}

- (IBAction)NoodlesClicked:(id)sender {
    NSLog(@"NoodlesClicked");
}

- (IBAction)IceCreamClicked:(id)sender {
    NSLog(@"IceCreamClicked");
}


- (IBAction)DrinkClicked:(id)sender {
    NSLog(@"DrinkClicked");
}
@end
