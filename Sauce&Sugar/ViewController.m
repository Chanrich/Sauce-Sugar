//
//  ViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "ViewController.h"
#import "LocationDataController.h"
#import "Location.h"

#define SLIDEMENU_WIDTH 275
#define SLIDE_DURATION 0.2
#define CORNER_RADIUS 4
#define SLIDEOUT_VIEW_TAG 2
@interface ViewController () <SlideOutMenuViewControllerDelegate>
@property (nonatomic,assign) BOOL showingMenu;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set content mode to scale image proportionally
    //_AddButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.AddButton setContentMode:UIViewContentModeScaleAspectFit];

    self.navigationItem.title = @"Home";
    
    // Listen for button click event in slideout menu to return panel to original position
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideSuperViewToOriginal) name:@"slideSuperViewBack" object:nil];
    
    // Listen for ADD button click event slide out menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCamera) name:@"addNewItem" object:nil];
}
- (void)viewDidAppear:(BOOL)animated{
//    LocationDataController *model = [[LocationDataController alloc] init];
//    Location *poi = [model getPointOfInterest];
//    self.addressLabel.text = poi.address;
    //[self.photoImageView setImage:[UIImage imageNamed:poi.photofilename]];
    
    // Give button a custom gradient
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.AddButton.bounds;
//    gradient.colors =  [NSArray arrayWithObjects:(id)([UIColor colorWithRed:0.33 green:0.596 blue:1.00 alpha:1.00].CGColor),(id)([UIColor colorWithRed:0.33 green:0.83 blue:1.00 alpha:1.00].CGColor) , nil];
//    gradient.startPoint = CGPointMake(0.5, 0);
//    gradient.endPoint = CGPointMake(0.5, 1);
//    [self.AddButton.layer insertSublayer:gradient atIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Bring up the camera and then add to database view
- (IBAction)TouchUp_CameraButton:(id)sender {
    [self startCamera];
}

// Bring up the camera and then add to database view
- (void) startCamera{
    // If camera module is not available, show message
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        NSLog(@"Camera not available");
        // Create a UI AlertController to show warning message
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Camera not detected" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        NSLog(@"Camera detected");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

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
    [self showViewController:vc sender:NULL];
    //[self presentViewController:vc animated:YES completion:NULL];
}

// Credit to stack overflow user: user4261201
-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 300.0;
    float maxWidth = 400.0;
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)MenuTouchUpInside:(id)sender {
    UIButton *rcButton = sender;
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
            break;
    }
}

- (IBAction)slidePanelBackFullscreenButtonTouchUpInside:(id)sender {
    // Slide panel back in place
    [self slideSuperViewToOriginal];
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
            self.SlideMenuButton.tag = 0;
            
            // Enable fullscreen button to return to original position
            self.slideBackButton.enabled = YES;
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
            // Set flag to false
            self.showingMenu = NO;
            // Tag = 1, Menu is in its original position
            self.SlideMenuButton.tag = 1;
            
            // Reset shadow to default
            [self setShadowForSlideOutMenu:NO offset:0];
            
            // Disable fullscreen button for sliding original panel back
            self.slideBackButton.enabled = NO;
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
    self.showingMenu = YES;
    
    // Set shadow
    [self setShadowForSlideOutMenu:YES offset:-2];
    
    UIView *returnView = self.rcSlideOutMenuView.view;
    
    return returnView;
}

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

@end
