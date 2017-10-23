//
//  AddToDatabase_ViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AddToDatabase_ViewController.h"

@interface AddToDatabase_ViewController ()

@end

// Declare function
void createBlobContainer(NSString *contianerName);
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer);


@implementation AddToDatabase_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.MainImageView setImage:_rcImageHolder];
    self.rcImageUploadCompleted = @NO;
    self.rcDataUploadCompleted = @NO;
    self.Button_AddDatabase.enabled = NO;
    
    // Set delegate to self to hide keyboard after pressing return
    [self.TextField_Name setDelegate:self];
    [self.TextField_RestaurantName setDelegate:self];
    [self.TextView_Comment setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybaord)];
    [self.view addGestureRecognizer:tap];
    

    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Request a unique serial number
    [self.rcDataConnection getUniqueNumber_WithUsername:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername] Callback:^(NSDictionary *callbackItem) {
        // Get a handle of the dictionary data passed back
        self.rcDownloadedDictionary = callbackItem;
        
        // Get data by its key
        NSLog(@"Type of data returned:%@", [[callbackItem objectForKey:@"SequenceNumber"] class]);
        NSLog(@"Retrieved unique number: %@", [callbackItem objectForKey:@"SequenceNumber"]);
        // Copy the unique number
        self.rcUniqueNumber = [NSNumber numberWithInt:[[callbackItem objectForKey:@"SequenceNumber"] intValue]] ;
        
        // Enabled add button
        self.Button_AddDatabase.enabled = YES;
    }];
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

// Button touch up inside event has been triggered.
- (IBAction)ButtonTouchedUpInside_Add:(id)sender {
    // Clear button text to reveal indicator, and start animating activity indicator
    [self.Button_AddDatabase setTitle:@"" forState:UIControlStateNormal];
    [self.rcActivityIndicator startAnimating];
    
    // Grab username from singleton
    NSString *myUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    
    // Initialize BlobStorage instance
    rcAzureBlobContainer* rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
    
    // Connect to container
    [rcBlobstorage connectToContainerWithName:myUsername];

    // Upload the image into blob storage
    NSLog(@"Uploading Image...");
    [rcBlobstorage createImageWithBlobContainer:myUsername BlobName:[self.rcUniqueNumber stringValue] ImageData:self.rcImageHolder rcCallback:^(NSNumber *rcCompleteFlag) {
        if ([rcCompleteFlag isEqualToNumber:@YES]){
            // Upload complete
            NSLog(@"Insert image into blob storage successful");
            self.rcImageUploadCompleted = @YES;
            
            if ([self.rcDataUploadCompleted isEqualToNumber:@YES]){
                // Increment index and pop current view
                [self updateDictionaryAndExit];
            } else {
                NSLog(@"Data table upload is not completed, waiting...");
            }
        } else {
            // Upload failed
            NSLog(@"Insert image into blob storage failed");
            self.rcImageUploadCompleted = @NO;
        }
    }];
    NSLog(@"Image uploaded");
    
    // Insert data into DataTable Class
    [self.rcDataConnection prepareFoodData:self.TextField_Name.text resName:self.TextField_RestaurantName.text comment:self.TextView_Comment.text username:myUsername sequenceNumber:self.rcUniqueNumber rcLike:self.rcLikeStatus];
    
    // Insert Data collection into table name:rcMainDataTable
    [self.rcDataConnection InsertDataIntoTable:@"rcMainDataTable" rcCallback:^(NSNumber *rcCompleteFlag) {
        if ([rcCompleteFlag isEqualToNumber:@YES]){
            // Upload complete
            NSLog(@"Insert data into table successful");
            self.rcDataUploadCompleted = @YES;
            if ([self.rcImageUploadCompleted isEqualToNumber:@YES]){
                // Increment index and pop current view
                [self updateDictionaryAndExit];
            } else {
                // Debug
                NSLog(@"Image upload is not completed, waiting...");
            }
        } else {
            // Upload failed, issue a warnning
            NSLog(@"Insert data into table failed");
            self.rcDataUploadCompleted = @NO;
        }
        
    }];
}

// Download image from blobName inside blobCotainer and set UIImageView to this image
- (void)getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer{
    // Create a blob
    AZSCloudBlockBlob *blockblob = [blobContainer blockBlobReferenceFromName:blobName];
    
    // Perform blob download
    [blockblob downloadToDataWithCompletionHandler:^(NSError * _Nullable error, NSData * _Nullable downloadedData) {
        if (error){
            NSLog(@"Error when downloading:\b %@", error);
        } else {
            NSLog(@"Download successful");
            UIImage *imagefromdata = [UIImage imageWithData:downloadedData];
            // Set UIImageView to downloaded image
            [self.MainImageView setImage:imagefromdata];
        }
        
    }];
}

- (void) updateDictionaryAndExit{
    // Debug
    NSLog(@"Upload is completed, increment sequence number and dismissing add view");
    
    // Increment the sequence number
    [self.rcDataConnection incrementSequenceNumberWithDictionary:self.rcDownloadedDictionary];
    
    // Return to main menu, pop view controller in main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        // Leave this view
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

// Hide keyboard when a single tap occured
- (void) dismissKeybaord{
    // Hide keyboard for comment box
    [self.TextView_Comment resignFirstResponder];
    // Hide keyboard for restaurant textbox
    [self.TextField_RestaurantName resignFirstResponder];
}

- (IBAction)TouchUpInside_LikeButton:(id)sender {
    // Highlight Like button
    self.Button_Like.highlighted = YES;
    self.Button_NoLike.highlighted = NO;
    // Set flag
    self.rcLikeStatus = @YES;
}

- (IBAction)TouchUpInside_NoLikeButton:(id)sender {
    // Highlight NoLike button
    self.Button_Like.highlighted = NO;
    self.Button_NoLike.highlighted = YES;
    // Set flag
    self.rcLikeStatus = @NO;
}
@end
