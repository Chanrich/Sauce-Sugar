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
    
    // Set current user
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setCurrentUsername:@"rchan"];
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Request a unique serial number
    [self.rcDataConnection getUniqueNumber_WithUsername:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername] Callback:^(NSDictionary *callbackItem) {
        // Get data by its key
        NSLog(@"Type of data returned:%@", [[callbackItem objectForKey:@"SequenceNumber"] class]);
        NSLog(@"Retrieved unique number: %@", [callbackItem objectForKey:@"SequenceNumber"]);
        // Copy the unique number
        self.rcUniqueNumber = [NSNumber numberWithInt:[[callbackItem objectForKey:@"SequenceNumber"] intValue]] ;
        
        // Increment the sequence number
        [self.rcDataConnection incrementSequenceNumberWithDictionary:callbackItem];
        
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
    // Grab username from singleton
    NSString *myUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    
    // Initialize BlobStorage instance
    rcAzureBlobContainer* rcBlobstorage = [[rcAzureBlobContainer alloc] init];
    
    // Upload the image into blob storage
    NSLog(@"Uploading Image...");
    [rcBlobstorage createImageWithBlobContainer:myUsername BlobName:[self.rcUniqueNumber stringValue] ImageData:self.rcImageHolder rcCallback:^(NSNumber *rcCompleteFlag) {
        if ([rcCompleteFlag isEqualToNumber:[NSNumber numberWithBool:YES]]){
            // Upload complete
            NSLog(@"Insert image into blob storage successful");
            self.rcImageUploadCompleted = [NSNumber numberWithBool:YES];
            if ([self.rcDataUploadCompleted isEqualToNumber:@YES]){
                NSLog(@"Upload is completed, dismissing add view");
                // Return to main menu, pop view controller in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                NSLog(@"Data table upload is not completed, waiting...");
            }
        } else {
            // Upload failed
            NSLog(@"Insert image into blob storage failed");
            self.rcImageUploadCompleted = [NSNumber numberWithBool:NO];
        }
    }];
    NSLog(@"Image uploaded");
    
    // Insert data into DataTable Class
    [self.rcDataConnection prepareFoodData:self.TextField_Name.text resName:self.TextField_RestaurantName.text comment:self.TextView_Comment.text username:myUsername sequenceNumber:self.rcUniqueNumber];
    
    // Insert Data collection into table name:rcMainDataTable
    [self.rcDataConnection InsertDataIntoTable:@"rcMainDataTable" rcCallback:^(NSNumber *rcCompleteFlag) {
        if ([rcCompleteFlag isEqualToNumber:[NSNumber numberWithBool:YES]]){
            // Upload complete
            NSLog(@"Insert data into table successful");
            self.rcDataUploadCompleted = [NSNumber numberWithBool:YES];
            if ([self.rcImageUploadCompleted isEqualToNumber:@YES]){
                NSLog(@"Upload is completed, dismissing add view");
                // Return to main menu, pop view controller in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            } else {
                NSLog(@"Image upload is not completed, waiting...");
            }
        } else {
            // Upload failed, issue a warnning
            NSLog(@"Insert data into table failed");
            self.rcDataUploadCompleted = [NSNumber numberWithBool:NO];
        }
        
    }];
    
    //NSLog(@"Creating Container");
    // Create a blob container with the current username from the shared app delegate object
    //[self createBlobContainer:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername]];
}

// Grab image from blobName inside blobCotainer and a UIImageView to this image
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

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void) dismissKeybaord{
    [self.TextView_Comment resignFirstResponder];
}

@end

// BlobName has to be all lowercase, letters or numbers
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer){
    UIImage *myimage1 = [UIImage imageNamed:imageName];
    NSData *imgdata = UIImagePNGRepresentation(myimage1);
    AZSCloudBlockBlob *imageblockblob = [blobContainer blockBlobReferenceFromName:blobName];
    [imageblockblob uploadFromData:imgdata completionHandler:^(NSError *error) {
        if (error){
            NSLog(@"Error when uploading blob\n %@", error);
        } else {
            NSLog(@"Successfully uploaded %@", imageName);
        }
    }];
}

// Add a text string to a blob
void AddTextBlob(NSString *text, NSString *blobName, AZSCloudBlobContainer *blobContainer){
    // Create the blob
    AZSCloudBlockBlob *blockblob = [blobContainer blockBlobReferenceFromName:blobName];
    
    //Upload blob
    [blockblob uploadFromText:text completionHandler:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Error when uploading blob\n %@", error);
        } else {
            NSLog(@"Successfully uploaded: %@", text);
        }
    }];
}
