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
    self.photoImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    // Start a view to add information to database
    UIStoryboard *rcStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddToDatabase_ViewController *vc = [rcStoryBoard instantiateViewControllerWithIdentifier:@"AddToDataBaseViewController"];
    vc.rcImageHolder = info[UIImagePickerControllerEditedImage];
    // Change entry animation
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self showViewController:vc sender:NULL];
    //[self presentViewController:vc animated:YES completion:NULL];
    
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
@end
