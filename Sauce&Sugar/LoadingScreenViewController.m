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
#import "GlobalNames.h"
@interface LoadingScreenViewController ()

@end

@implementation LoadingScreenViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // get current username
    self.currentUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    // Hide navigation controller's back button
    self.navigationItem.hidesBackButton = YES;
    // Hide green check image
    [self.checkedImage setAlpha:0];
    
    // Get singleton files
    // Initialize a singleton instance for Azure Blob
    self.rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
    
    // Initialize a singleton instance for Azure Data
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Request for location data
    [self.rcDataConnection requestLocationData];
    
    // Reset UI
    self.statusLabel.text = @"Downloading Sequence Number";
    self.progressBar.progress = 0;
    // Start indicator animation
    [self.statusIndicator startAnimating];
    
    // Request a unique serial number from User Data Table
    [self.rcDataConnection getUniqueNumber_WithUsername:self.currentUsername Callback:^(NSDictionary *callbackItem) {
        
        // TODO: handle error. when callbackItem == nil
        
        // Set UI Animation in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressBar setProgress:0.2 animated:YES];
            self.statusLabel.text = @"Uploading to Data Table";
        });

        // Store a copy of the dictioanry entry returned from the callback in order to increment the number by 1
        self.rcDownloadedDictionary = callbackItem;
        
        NSLog(@"Retrieved unique sequence number: %@", [callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE]);
        
        // Store sequence number to Azure Blob Storage object (No connection to server is made)
        [self.rcBlobstorage insertUniqueSequenceNumber:[(NSNumber*)[callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE] stringValue]];
        
        // Insert sequence number and username to Azure data table (No connection to server is made)
        [self.rcDataConnection insertSequenceNumber:[(NSNumber*)[callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE] stringValue] username:self.currentUsername];
        
        // Upload all data into rcMainDataTable
        [self.rcDataConnection InsertDataIntoMainDataTable:^(NSNumber *rcCompleteFlag) {
            // Set UI Animation in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressBar setProgress:0.5 animated:YES];
                self.statusLabel.text = @"Uploading image";
            });
            // Proceed when uplaod is successful
            if ([rcCompleteFlag isEqualToNumber:@YES]){
                // Data is uploaded to Data Table, then upload the image into blob storage
                NSLog(@"Uploading Image...");
                
                // Use unique sequence number as blob's name
                [self.rcBlobstorage createImageWithBlobContainer:self.currentUsername SetCallback:^(NSNumber *rcCompleteFlag) {
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
                                    [self.statusIndicator viewFadeOutWithCompletion:nil];
                                    
                                    // Fade in green check image
                                    [self.checkedImage viewFadeInWithCompletion:nil];
                                    // Update UI elements
                                    [self.progressBar setProgress:1.0 animated:YES];
                                    self.statusLabel.text = @"Done";
                                    [self.statusIndicator stopAnimating];
                                    
                                    // Wait for few seconds and then return to main menu
                                    [self performSelector:@selector(returnToMainMenu) withObject:nil afterDelay:2];
                                });
                            } else {
                                // Sequence number update failed
                                NSLog(@"Sequence number update failed");
                                // Delete the entry just added in main data table
                                [self.rcDataConnection deleteEntry:[self.rcDataConnection getCurrentDictionaryData]];
                                // Update UI in main thread and return to main menu
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.progressBar setProgress:0 animated:YES];
                                    self.statusLabel.text = @"Sequence number update failed";
                                    
                                    // Wait for few seconds and then return to main menu
                                    [self performSelector:@selector(returnToMainMenu) withObject:nil afterDelay:2];
                                });
                                
                            }
                        }];
                        
                    } else {
                        // Upload image failed
                        NSLog(@"Insert image into blob storage failed");
                        // Delete the entry just added in main data table
                        [self.rcDataConnection deleteEntry:[self.rcDataConnection getCurrentDictionaryData]];
                        // Update UI in main thread and return to main menu
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.progressBar setProgress:0 animated:YES];
                            self.statusLabel.text = @"Upload image failed";
                            
                            // Wait for few seconds and then return to main menu
                            [self performSelector:@selector(returnToMainMenu) withObject:nil afterDelay:2];
                        });
                        
                    }
                }]; // End of createImageWithBlobContainer
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

// This function will be called when everything completes to return to main menu
- (void) returnToMainMenu{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
