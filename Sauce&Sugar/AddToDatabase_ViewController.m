//
//  AddToDatabase_ViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

/*
 The purpose of this view is to capture:
     1. Restaurant Name -> Azure Data Table
     2. Camera Image -> Azure Blob Storage
 The data should be save to their respective data objects during segue to next view
 
 */

#import "AddToDatabase_ViewController.h"

@interface AddToDatabase_ViewController ()

@end

// Declare function
void createBlobContainer(NSString *contianerName);
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer);


@implementation AddToDatabase_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set all textfield and image view to transparent so they can be faded in later
    [self.TextField_RestaurantName setAlpha:0];
    [self.MainImageView setAlpha:0];
    
    // Perform animation to fade in restaurant textfield first
    [self.TextField_RestaurantName viewFadeInWithCompletion:^(BOOL rcFinished) {
        if (rcFinished == YES){
            // Then fade in image view
            [self.MainImageView viewFadeInWithCompletion:nil];
        }
    }]; // End of fading in UI elements
    
    // get current username
    self.currentUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    
    // Load image to Azure Blob Storage if image is valid
    if (_rcImageHolder != nil){
        // Initialize a singleton instance for Azure Blob
        self.rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
        
        // Store image to blob container
        [self.rcBlobstorage insertImage:_rcImageHolder];
        
        // Set UI Image display
        [self.MainImageView setImage:_rcImageHolder];
    }
    
    
    
    // Initialize a singleton instance for Azure Data
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    
    // ================== UI Interaction ==================
    // Set delegate to self to hide keyboard after pressing return
    [self.TextField_RestaurantName setDelegate:self];
    
    // Register a tap recognizer to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybaord)];
    [self.view addGestureRecognizer:tap];
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

/* Next button clicked
 - Insert restaurant name to Azure Data Table
 - Proceed to next view
 */
- (IBAction)NextButton_TouchUpInside:(id)sender {
    // If restaurant text field is empty, stop the segue to next view and display alert
    if ([self.TextField_RestaurantName.text isEqualToString:@""]){
        // Alert user to enter a text
        // ----- Create a UI AlertController to show warning message -----
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Restaurant name is empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
        // ---------------------------------------------------------------
    } else {
        // Restaurant name is valid
        NSLog(@"Adding restuarant name to rcDataConnection");
        // Set restaurant name to Azure Data placeholder
        [self.rcDataConnection insertResNameData:self.TextField_RestaurantName.text];
        

        
        // Proceed to next view
        [self performSegueWithIdentifier:@"ShowFoodTypeSegue" sender:sender];
    }
    
}

// Hide keyboard when a single tap occured
- (void) dismissKeybaord{
    // Hide keyboard for restaurant textbox
    [self.TextField_RestaurantName resignFirstResponder];
}

// Hide keyboard when return is pressed
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
