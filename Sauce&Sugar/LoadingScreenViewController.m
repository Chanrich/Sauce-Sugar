//
//  LoadingScreenViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//
/*
 The purpose of this view is to
     1. Request for a unique sequence number
     2. Upload image data to Azure Blob Storage
     3. After image upload successful, load data into Azure Data Table
 
 */
#import "LoadingScreenViewController.h"

@interface LoadingScreenViewController ()

@end

@implementation LoadingScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get current username
    self.currentUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    
    // Get singleton files
    // Initialize a singleton instance for Azure Blob
    self.rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
    
    // Initialize a singleton instance for Azure Data
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Reset UI
    self.statusLabel.text = @"Downloading Sequence Number";
    self.progressBar.progress = 0;
    // Start indicator animation
    [self.statusIndicator startAnimating];
    
    // Request a unique serial number from Azure Data Table
    [self.rcDataConnection getUniqueNumber_WithUsername:self.currentUsername Callback:^(NSDictionary *callbackItem) {
        // Set UI Animation in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setProgress:0.2 animated:YES];
            self.statusLabel.text = @"Uploading to Data Table";
        });

        // Store a copy of the dictioanry entry returned from the callback in order to increment the number by 1
        self.rcDownloadedDictionary = callbackItem;
        
        NSLog(@"Retrieved unique sequence number: %@", [callbackItem objectForKey:@"SequenceNumber"]);
        
        // Store sequence number to Azure Blob Storage object
        [self.rcBlobstorage insertUniqueSequenceNumber:[(NSNumber*)[callbackItem objectForKey:@"SequenceNumber"] stringValue]];
        
        // Insert sequence number and username to Azure data table
        [self.rcDataConnection insertSequenceNumber:[(NSNumber*)[callbackItem objectForKey:@"SequenceNumber"] stringValue] username:self.currentUsername];
        
        // Upload all data into rcMainDataTable
        [self.rcDataConnection InsertDataIntoTable:@"rcMainDataTable" rcCallback:^(NSNumber *rcCompleteFlag) {
            // Set UI Animation in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressBar setProgress:0.5 animated:YES];
                self.statusLabel.text = @"Uploading image";
            });
            // Proceed when uplaod is successful
            if ([rcCompleteFlag isEqualToNumber:@YES]){
                // Data is uploaded to Data Table, then upload the image into blob storage
                NSLog(@"Uploading Image...");
                // Connect to container for current user. Current username will be the container's name
                [self.rcBlobstorage connectToContainerWithName:self.currentUsername];
                
                // Use unique sequence number as blob's name
                [self.rcBlobstorage createImageWithBlobContainerSetCallback:^(NSNumber *rcCompleteFlag) {
                    // All uploads completed
                    NSLog(@"Setting UI to complete");
                    
                    // Check whether image is successfully uploaded to blob
                    if ([rcCompleteFlag isEqualToNumber:@YES]){
                        // Upload complete
                        NSLog(@"Insert image into blob storage successful");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.progressBar setProgress:0.9 animated:YES];
                            self.statusLabel.text = @"Incrementing sequence ID in user table";
                        });

                        // Increment the sequence number in rcUserDataInfo
                        NSLog(@"Incrementing sequence number");
                        [self.rcDataConnection incrementSequenceNumberWithDictionary:self.rcDownloadedDictionary Callback:^(NSNumber *completeFlag) {
                            // Check status of sequence number update
                            if ([completeFlag  isEqual: @YES]){
                                // Sequence number update completed, push updates to UI view elements and then call uploadCompleted function
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    // Fade out status indicator
                                    [UIView animateWithDuration:0.4 animations:^{
                                        self.statusIndicator.alpha = 0;
                                    }];
                                    // Update UI elements
                                    [self.progressBar setProgress:1.0 animated:YES];
                                    self.statusLabel.text = @"Done";
                                    [self.statusIndicator stopAnimating];
                                });
                            } else {
                                // Sequence number update failed
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.progressBar setProgress:0 animated:YES];
                                    self.statusLabel.text = @"Sequence number update failed";
                                });
                            }
                        }];
                        
                    } else {
                        // Upload image failed
                        NSLog(@"Insert image into blob storage failed");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.progressBar setProgress:0 animated:YES];
                            self.statusLabel.text = @"Upload image failed";
                        });
                    }
                }];
            } else {
                // If data not uploaded into Azure Data Table
                NSLog(@"Cannot upload data to Azure Data Table, Abort!");
            }

        }];
        
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method will be called when all upload actions are completed
- (void) uploadCompleted{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
