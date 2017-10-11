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
@interface ViewController ()

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set content mode to scale image proportionally
    //_AddButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.AddButton setContentMode:UIViewContentModeScaleAspectFit];
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


- (IBAction)TouchUp_CameraButton:(id)sender {
    
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
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *compressedImage = [self resizeImage:chosenImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    // Start a view to add information to database
    UIStoryboard *rcStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
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
@end
