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
#import <GoogleMaps/GoogleMaps.h>

static NSString *const HIDE_GMAP_POI_JSON = @"["
@"  {"
@"    \"featureType\": \"poi.business\","
@"    \"elementType\": \"all\","
@"    \"stylers\": ["
@"      {"
@"        \"visibility\": \"off\""
@"      }"
@"    ]"
@"  },"
@"  {"
@"    \"featureType\": \"transit\","
@"    \"elementType\": \"labels.icon\","
@"    \"stylers\": ["
@"      {"
@"        \"visibility\": \"off\""
@"      }"
@"    ]"
@"  }"
@"]";

@interface LoadingScreenViewController (){

}

@end

@implementation LoadingScreenViewController {
    // current coordinates
    double current_latitude;
    double current_longitude;
    
    // Map object
    GMSMapView *subMapView;
    
    // UI Outlets
    IBOutlet UIProgressView *progressBar;
    IBOutlet UIActivityIndicatorView *statusIndicator;
    // UI Outlet - image
    IBOutlet UIImageView *checkedImage;
    // UI Outlets - Labels
    IBOutlet UILabel *statusLabel;
    IBOutlet UILabel *rcIDLabel;
    IBOutlet UILabel *rcTypeLabel;
    IBOutlet UILabel *rcRestaurantLabel;
    // UI Outlets - Views
    IBOutlet UIView *rcStatusView;
    IBOutlet UIView *rcMapView;
    IBOutlet UIView *rcUploadInfo;

    // Store centerpositions initialized in storyboard
    CGPoint statusLabelPos;
    CGPoint statusViewPos;
    
    // Auto layout object to animate move
    IBOutlet NSLayoutConstraint *tcInfoTopConstraint;
    float initCons;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide finished status view
    [rcStatusView setAlpha:0];
    // Hide green check image
    [checkedImage setAlpha:0];
    // Hide navigation controller's back button
    self.navigationItem.hidesBackButton = YES;
    
    // Store initial auto Layout constant
    initCons = tcInfoTopConstraint.constant;

    // Move processing view down to center and ask autolayout to update
    tcInfoTopConstraint.constant = (self.view.bounds.size.height/2) - (rcUploadInfo.bounds.size.height);
    [self.view layoutIfNeeded];
    
    // get current username
    self.currentUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    
    // Initialize a singleton instance
    self.rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Retreive current GPS location
    current_latitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.latitude;
    current_longitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.longitude;
    NSLog(@"<In Load> Lat:%f Long:%f", current_latitude, current_longitude);
    
    // Setup map
    [self setupGoogleMap];
    
    // Reset UI
    statusLabel.text = @"Downloading Sequence Number";
    progressBar.progress = 0;
    [statusIndicator startAnimating]; // Start indicator animation
    
    // Request a unique serial number from User Data Table
    [self.rcDataConnection getUniqueNumber_WithUsername:self.currentUsername Callback:^(NSDictionary *callbackItem) {
        // Perform error handling
        if (callbackItem == nil){
            // Execute in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // Set failed message
                [self setFailedMessageAndReturn:@"Cannot retrieve an index number from server"];
            });
        } else {
            // Set UI Animation in main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressBar setProgress:0.2 animated:YES];
                statusLabel.text = @"Uploading to Data Table";
            });
            
            // Store a copy of the dictioanry entry returned from the callback in order to increment the number by 1
            self.rcDownloadedDictionary = callbackItem;
            
            NSLog(@"Retrieved unique sequence number: %@", [callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE]);
            
            // Store sequence number to Azure Blob Storage object (Only stores local copy, no connection to server is made)
            [self.rcBlobstorage insertUniqueSequenceNumber:[(NSNumber*)[callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE] stringValue]];
            
            // Insert sequence number and username to Azure data table (Only stores local copy, no connection to server is made)
            [self.rcDataConnection insertSequenceNumber:[(NSNumber*)[callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE] stringValue] username:self.currentUsername];
            
            // Populate status information
            NSString *IDtext = [NSString stringWithFormat:@"ID: %@", [(NSNumber*)[callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE] stringValue]];
            NSString *Typetext = [NSString stringWithFormat:@"Type: %@", [self.rcDataConnection getCurrentSelectedFoodTypeName]];
            NSString *Restext = [NSString stringWithFormat:@"Restaurant: %@", [self.rcDataConnection getCurrentRestaurantName]];
            rcIDLabel.text = IDtext;
            rcTypeLabel.text = Typetext;
            rcRestaurantLabel.text = Restext;
            
            // Upload all data into rcMainDataTable in server
            [self.rcDataConnection InsertDataIntoMainDataTable:^(NSNumber *rcCompleteFlag) {
                // Set UI Animation in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressBar setProgress:0.5 animated:YES];
                    statusLabel.text = @"Uploading image";
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
                                [progressBar setProgress:0.9 animated:YES];
                                statusLabel.text = @"Incrementing sequence ID in user table";
                            });
                            
                            // Increment the sequence number in rcUserDataInfo
                            [self.rcDataConnection incrementSequenceNumberWithDictionary:self.rcDownloadedDictionary Callback:^(NSNumber *completeFlag) {
                                // Check status of sequence number update
                                if ([completeFlag  isEqual: @YES]){
                                    // Sequence number update completed, push updates to UI view elements
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        // Fade in green check image
                                        checkedImage.image = [UIImage imageNamed:@"checked"];
                                        [checkedImage viewFadeInWithCompletion:nil];
                                        
                                        // Update UI elements, fade out progress bar and indicator
                                        [progressBar viewFadeOutWithCompletion:nil];
                                        [statusIndicator stopAnimating];
                                        statusLabel.text = @"Done";
                                        
                                        // Move its location
                                        tcInfoTopConstraint.constant = initCons;
                                        
                                        [UIView animateWithDuration:fadeDuration animations:^{
                                            // Show it on screen
                                            rcStatusView.alpha = 1;
                                            rcMapView.alpha = 1;

                                            [self.view layoutIfNeeded];
                                        } completion:^(BOOL finished) {
                                            // Set google map at new location
                                            //
                                        }];
                                    });
                                } else {
                                    // Sequence number update failed
                                    NSLog(@"Sequence number update failed");
                                    // Delete the entry just added in main data table
                                    [self.rcDataConnection deleteEntry:[self.rcDataConnection getCurrentDictionaryData]];
                                    // Update UI in main thread and return to main menu
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self setFailedMessageAndReturn:@"Sequence number update failed"];
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
                                // Set failed message
                                [self setFailedMessageAndReturn:@"Upload image failed"];
                            });
                            
                        }
                    }]; // End of createImageWithBlobContainer
                } else {
                    // If data not uploaded into Azure Data Table
                    NSLog(@"Cannot upload data to Azure Data Table, Abort!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Set failed message
                        [self setFailedMessageAndReturn:@"Upload to Azure Data Table failed"];
                    }); // End of dispatch
                } // End of self.rcDataConnection InsertDataIntoMainDataTable Completeflag failed
                
            }]; // End of self.rcDataConnection InsertDataIntoMainDataTable call
        }
        
    }]; // End of self.rcDataConnection getUniqueNumber_WithUsername call
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

// If error occured, set failed message
- (void) setFailedMessageAndReturn:(NSString*)msg{
    // If the unique sequence number cannot be retrieved from server. Abort task
    // Set image to failed icon and fade it in
    checkedImage.image = [UIImage imageNamed:@"error"];
    [checkedImage viewFadeInWithCompletion:nil];
    
    // Stop indicator
    [statusIndicator stopAnimating];
    
    // Hide progress bar
    progressBar.alpha = 0;
    
    // Show error message
    statusLabel.text = msg;
    
    // Wait for few seconds and then return to main menu
    [self performSelector:@selector(returnToMainMenu) withObject:nil afterDelay:2];
}
// Dismiss viewcontroller when OK is pressed
- (IBAction)OKButtonPressed:(id)sender {
    [self returnToMainMenu];
}

- (void) setupGoogleMap{
    // Initialize a google map camera position object
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current_latitude
                                                            longitude:current_longitude
                                                                 zoom:10];
    
    // Build google map view objective with (0, 0, 0, 0) frame
    subMapView = [GMSMapView mapWithFrame:rcMapView.bounds camera:camera];
    subMapView.myLocationEnabled = YES;
    
    // ======== Hide all POI on map object ==========
    NSError *error;
    GMSMapStyle *style = [GMSMapStyle styleWithJSONString:HIDE_GMAP_POI_JSON error:&error];
    if (!style){
        NSLog(@"JSON to hide POI on google map is not initialized");
    }
    subMapView.mapStyle = style;
    // ================================================
    
    [rcMapView addSubview:subMapView];
    
    // Store location data into coordinate
    CLLocationCoordinate2D tempCoordinate = CLLocationCoordinate2DMake(current_latitude, current_longitude);
    
    subMapView.myLocationEnabled = NO;
    
    // Setup marker and show it in map
    GMSMarker *markerItem = [[GMSMarker alloc] init];
    markerItem.position = tempCoordinate;
    markerItem.title = @"New location";
    // markerItem.snippet = @"New";
    markerItem.map = subMapView;
}
@end
