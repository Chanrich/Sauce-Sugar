//
//  UserProfileViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 12/1/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "UserProfileViewController.h"
#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "GlobalNames.h"
#import "rcAzureBlobContainer.h"
#define IMAGEDICTIONARY_IMAGE @"image"
#define IMAGEDICTIONARY_SEQUENCE @"sequence"

@interface UserProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) IBOutlet UILabel *rcUsernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rcUploadCount;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *rcCollectionViewLayout;

// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;
// Singleton instance of Blob Container
@property (strong, nonatomic) rcAzureBlobContainer *rcBlobContainer;

@end

@implementation UserProfileViewController {
    // Name of current user
    NSString *currentUser;
    // All downloaded image data
    NSMutableArray <NSMutableDictionary*> *userPhotosMutableArray;
    // Sorted image data
    NSArray *userPhotoSortedArray;
    // Number of images downloaded (includes failed image)
    unsigned long downloadedImageCount;
    // Failed image queue
    NSMutableArray <NSNumber*> *failedImageIndexQueue;
    // Total number of data entries returned from selected user
    NSUInteger userTotalDataCount;
    // A UIView to cover up collection view during data loading
    UIView *collectionOverlay;
    
    // Setting image
    IBOutlet UIImageView *rcSettingsImage;
    
    // Refresh control to re-download failed data
    UIRefreshControl *refreshControl;
    
    // Connected with server
    BOOL connectedFlag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize singleton instances
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    self.rcBlobContainer = [rcAzureBlobContainer sharedStorageContainer];
    
    // Add click event to setting image
    UITapGestureRecognizer *imageSingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(settingsClicked)];
    imageSingleTap.numberOfTapsRequired = 1;
    [rcSettingsImage setUserInteractionEnabled:YES];
    [rcSettingsImage addGestureRecognizer:imageSingleTap];
        
    // Initialize
    userPhotosMutableArray = [[NSMutableArray alloc] init];
    failedImageIndexQueue = [[NSMutableArray alloc] init];
    downloadedImageCount = 0;
    userTotalDataCount = 0;
    currentUser = @"";
    connectedFlag = FALSE;
    
    // Register refresh control to refresh failed data
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor grayColor];
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refreshFailedData) forControlEvents:UIControlEventValueChanged];
    [self.rcCollectionView addSubview:refreshControl];
    self.rcCollectionView.alwaysBounceVertical = YES;
}

- (void) viewWillAppear:(BOOL)animated{
    // Reload user data if current username changed
    NSString *newUserTemp = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    if ([newUserTemp isEqualToString:currentUser]){
        // Same user. Nothing to be done
    } else {
        // User changed, reload new user data
        currentUser = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
        [self.rcUsernameLabel setText:currentUser];
        
        // Remove all old user data
        [userPhotosMutableArray removeAllObjects];
        downloadedImageCount = 0;
        [self.rcCollectionView reloadData];
        
        // =========== Overlay ============
        // Create a overlay view to cover up UI collection view during loading
        collectionOverlay = [[UIView alloc] initWithFrame:self.tabBarController.view.bounds];
        collectionOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        // Display an activity indicator to alert user that download is in progress
        UIActivityIndicatorView *rcSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleWhiteLarge];
        // Setup spinner
        [rcSpinner setFrame:self.tabBarController.view.bounds];
        [rcSpinner.layer setBackgroundColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
        rcSpinner.center = collectionOverlay.center;
        rcSpinner.hidesWhenStopped = YES;
        // Add subview
        [collectionOverlay addSubview:rcSpinner];
        // Add spinner subview and start spinner
        [rcSpinner startAnimating];
        [self.tabBarController.view addSubview:collectionOverlay];
        // ===============================
        
        // Download total number of images for current user
        [self.rcDataConnection getUniqueNumber_WithUsername:currentUser Callback:^(NSDictionary *callbackItem) {
            // When error occured (nil), show it in text label. Otherwise, show total count.
            if (callbackItem == nil){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.rcUploadCount setText:[NSString stringWithFormat:@"User upload count: Error"]];
                }); // End of dispatch to main thread
            } else {
                // Retreive sequence number
                NSNumber *tempSequence = [callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE];
                // Deduct 1 from sequence number to get total counts of entries
                NSNumber *totalCount = [NSNumber numberWithInt:(tempSequence.intValue) - 1];
                // Update Sequence label UI in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.rcUploadCount setText:[NSString stringWithFormat:@"User upload count: %@", totalCount]];
                }); // End of dispatch to main thread
            }
            
        }]; // End of getUniqueNumber_WithUsername
        
        // Request all photos that current user had uploaded
        [self.rcDataConnection getDatafromUser:currentUser FoodType:FOODTYPE_ALL RangeOfSearch_Lat:(int)0 RangeOfSearch_Long:(int)0 Callback:^(NSArray *callbackItem) {
            // Remove loading screen overlay after a delay
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [collectionOverlay removeFromSuperview];
            });
            
            // Connection established
            connectedFlag = YES;
            
            // In Callback function
            if (callbackItem == nil){
                // No data available
                userTotalDataCount = 0;
                // Handle errors, either no data available or download error
                NSLog(@"Error occured during loading");
                // ========= Create Alert =========
                // Create a UI AlertController to show warning message
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"No data is returned" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:NULL];
                // ================================
            } else {

                
                // Successful download
                userTotalDataCount = [callbackItem count];
                NSLog(@"Data received from callbackItem %lu", (unsigned long)[callbackItem count]);
                
                // Store result items into cell array.
                for (NSDictionary* returnDict in callbackItem){
                    // Get sequence number and minus the value by 1 to get total count of entries
                    NSNumber *sequenceNSNumber = [returnDict objectForKey:AZURE_DATA_TABLE_SEQUENCE];
                    // Get sequence number
                    NSString *sequenceNumString = [sequenceNSNumber stringValue];
                    NSLog(@"Requesting image at sequence number %@", sequenceNumString);
                    
                    // Request one image with name stored inside dictionary key "sequence"
                    [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:sequenceNumString rcCallback:^(UIImage *rcReturnedImage) {
                        
                        // Allocate a mutable dictionary to store image along with its sequence number
                        // The dictionary should contain following data structure:
                        // - Key -      : - Value -
                        // "image"      : user photo
                        // "sequence"   : sequence number for the photo
                        NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
                        
                        // If error occured
                        if (rcReturnedImage == nil){ // Image download error
                            // Retry download
                            [self retryImageDownloadFor:sequenceNumString];
                            // TODO: 1. capture a list of all incomplete objects
                            //  2. create a button to allow user to refresh download of incomplete objects
                            
                        } else { // When a valid image is downloaded
                            // Pack data into dictionary
                            [imageDictionary setObject:rcReturnedImage forKey:IMAGEDICTIONARY_IMAGE];
                            [imageDictionary setObject:sequenceNSNumber forKey:IMAGEDICTIONARY_SEQUENCE];
                            
                            // Increment image count
                            downloadedImageCount++;
                            NSLog(@"reloading collection view, download count: %lu", downloadedImageCount);
                            // Add new entry into the array for collection view
                            [userPhotosMutableArray addObject:imageDictionary];
                            
                            NSLog(@"User photo array size: %lu/%lu", (unsigned long)[userPhotosMutableArray count], (unsigned long)[callbackItem count]);
                            
                            // Sort array according to sequence number
                            NSSortDescriptor *sequenceSort = [NSSortDescriptor sortDescriptorWithKey:IMAGEDICTIONARY_SEQUENCE ascending:YES];
                            // Descriptor array has only 1 descriptor
                            NSArray *aSortDescriptors = [NSArray arrayWithObject:sequenceSort];
                            userPhotoSortedArray = [userPhotosMutableArray sortedArrayUsingDescriptors:aSortDescriptors];
                            
                            // Reload collection view in main thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.rcCollectionView reloadData];
                            });
                        } // End of when a valid image is downloaded
                        


                    }]; // End of download image method
                } // End of for loop, end of processing of one entry
            } // End of callbackItem not nil
        }]; // End of getDatafromUser
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Download
// This method should be called to retry an image's download faliure
-(void) retryImageDownloadFor:(NSString*)seq{
    // Request one image with name stored inside dictionary key "sequence"
    [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:seq rcCallback:^(UIImage *rcReturnedImage) {
        // Allocate a mutable dictionary to store image along with its sequence number
        NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
        
        // Create a NSNumber copy of sequence number
        NSNumber *sequenceNSNum = [NSNumber numberWithInt:[seq intValue]];
        // If error occured, create a warning dummy object
        if (rcReturnedImage == nil){ // Image download error
            // Get warning image from file
            UIImage *warningImage = [UIImage imageNamed:@"warning"];
            // Create a dummy entry to show download incomplete
            [imageDictionary setObject:warningImage forKey:IMAGEDICTIONARY_IMAGE];
            [imageDictionary setObject:sequenceNSNum forKey:IMAGEDICTIONARY_SEQUENCE];
            
            // Add new entry into the array for collection view
            [userPhotosMutableArray addObject:imageDictionary];
            
            // Get the index of the failed object
            NSNumber *fIndex = [NSNumber numberWithUnsignedInteger:[userPhotosMutableArray indexOfObject:imageDictionary]];
            
            // Insert current object into failed image index queue if it is not already in the queue
            if (![failedImageIndexQueue containsObject:fIndex]){
                [failedImageIndexQueue addObject:fIndex];
            }
            
        } else {
            // Create object with downloaded image and sequence number
            [imageDictionary setObject:rcReturnedImage forKey:IMAGEDICTIONARY_IMAGE];
            [imageDictionary setObject:sequenceNSNum forKey:IMAGEDICTIONARY_SEQUENCE];
            
            // Add new entry into the array for collection view
            [userPhotosMutableArray addObject:imageDictionary];
            
        } // End of when a valid image is downloaded

        NSLog(@"<retryImageDownloadFor> User photo array size: %lu", (unsigned long)[userPhotosMutableArray count]);
        
        // Increment image count
        downloadedImageCount++;
        NSLog(@"<retryImageDownloadFor> reloading collection view, download count: %lu", downloadedImageCount);
        
        // Sort array according to sequence number
        NSSortDescriptor *sequenceSort = [NSSortDescriptor sortDescriptorWithKey:IMAGEDICTIONARY_SEQUENCE ascending:YES];
        // Descriptor array has only 1 descriptor
        NSArray *aSortDescriptors = [NSArray arrayWithObject:sequenceSort];
        userPhotoSortedArray = [userPhotosMutableArray sortedArrayUsingDescriptors:aSortDescriptors];
        
        // Reload collection view in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rcCollectionView reloadData];
        });
        
    }]; // End of download image method
}

// Download the images that failed to load, this refresh should replace the warning object that is already in the data array
- (void) refreshFailedData{
    NSLog(@"Refresh failed Data");
    
    // Iterate through failed image queue array
    for (NSNumber* imageArrayIndex  in failedImageIndexQueue){
        NSLog(@"Refreshing data at image array index %@", imageArrayIndex);
        
        // Get the copy of the failed object
        NSMutableDictionary *targetObject = [userPhotosMutableArray objectAtIndex:[imageArrayIndex unsignedIntegerValue]];
        
        NSNumber *seqNSNumber = [targetObject objectForKey:IMAGEDICTIONARY_SEQUENCE];
        
        // Try to download each failed object
        [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:[seqNSNumber stringValue] rcCallback:^(UIImage *rcReturnedImage) {
            // Callback
            // Allocate a mutable dictionary to store image along with its sequence number
            NSMutableDictionary *reloadDictionary = [[NSMutableDictionary alloc] init];
            
            // Replace the image object in data array if this download is valid
            if (rcReturnedImage != nil){ // Image download error
                // Create object with downloaded image and sequence number
                [reloadDictionary setObject:rcReturnedImage forKey:IMAGEDICTIONARY_IMAGE];
                [reloadDictionary setObject:seqNSNumber forKey:IMAGEDICTIONARY_SEQUENCE];
                
                // Replace the failed dummy object in the data array
                [userPhotosMutableArray replaceObjectAtIndex:[imageArrayIndex unsignedIntegerValue] withObject:reloadDictionary];
                
                // Renew failed data queue
                [failedImageIndexQueue removeObject:imageArrayIndex];
                
                // Sort array according to sequence number
                NSSortDescriptor *sequenceSort = [NSSortDescriptor sortDescriptorWithKey:IMAGEDICTIONARY_SEQUENCE ascending:YES];
                // Descriptor array has only 1 descriptor
                NSArray *aSortDescriptors = [NSArray arrayWithObject:sequenceSort];
                userPhotoSortedArray = [userPhotosMutableArray sortedArrayUsingDescriptors:aSortDescriptors];
                
                // Reload collection view in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.rcCollectionView reloadData];
                });
                
            }
            

            
        }];
    }
    
    // End refresh
    if (refreshControl){
        [refreshControl endRefreshing];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Collection View

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *returnTempDict = [userPhotoSortedArray objectAtIndex:indexPath.item];
    NSLog(@"Item in collection view clicked: Seq: %@", [returnTempDict objectForKey:IMAGEDICTIONARY_SEQUENCE]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (downloadedImageCount == 0 && connectedFlag){
        // No data, print a message
        UILabel *noDataMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        noDataMsg.text = @"No image is available, Please upload some images";
        noDataMsg.textColor = [UIColor blackColor];
        noDataMsg.numberOfLines = 0;
        noDataMsg.textAlignment = NSTextAlignmentCenter;
        noDataMsg.font = [UIFont fontWithName:@"Helvetica Neue" size:17];
        [noDataMsg sizeToFit];
        
        collectionView.backgroundView = noDataMsg;
    } else {
        // Remove No data message message
        collectionView.backgroundView = nil;
    }
    return downloadedImageCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // Re-use the cell designed in storyboard
    static NSString *cellID = @"userPhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    // Grab the image data using its tag value
    UIImageView *photoImage = (UIImageView*) [cell viewWithTag:5];
    UILabel *sequenceLabelStorage = (UILabel*) [cell viewWithTag:6];
    
    // All image data should already be stored in dictionary, each entry can be retrieved using current index in collection view
    NSMutableDictionary *returnTempDict = [userPhotoSortedArray objectAtIndex:indexPath.item];
    
    // Set UI elements (Label is set to be hidden from view)
    photoImage.image = [returnTempDict objectForKey:IMAGEDICTIONARY_IMAGE];
    sequenceLabelStorage.text = [(NSNumber*)[returnTempDict objectForKey:IMAGEDICTIONARY_SEQUENCE] stringValue];
    
    return cell;
}

// Detect screen size and adjust each row to fit 3 cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float singleCellWidth = UIScreen.mainScreen.bounds.size.width / 3;
    // NSLog(@"Setting cell width to %f", singleCellWidth);
    
    return CGSizeMake(singleCellWidth, singleCellWidth);
}

#pragma mark Collection Header
- (UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *rcell = nil;
    
    // Create header view from storyboard
    if (kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *hview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileHeaderView" forIndexPath:indexPath];
        
        // Label is set to tag 9 in storyboard
        UILabel *headerLabel = [hview viewWithTag:9];
        UIActivityIndicatorView *headerSpin = [hview viewWithTag:10];
        
        // Create a string to be used
        NSString *headerText = [NSString stringWithFormat:@"Total:%lu", downloadedImageCount];
        [headerLabel setText:headerText];
        
        // Spin indicator when download is still in process
        if (downloadedImageCount == userTotalDataCount){
            [headerSpin stopAnimating];
        } else {
            [headerSpin startAnimating];
        }
        
        rcell = hview;
    }
    
    return rcell;
}

#pragma mark - UI events
- (void) settingsClicked{
    // Settings for Guest account should be disabled.
    if ([currentUser isEqualToString:@"Guest"]){
        // Show a message to notify user that setting on guest account is not allowed
        UIAlertController *alert;
        UIAlertAction *okAction;
        alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Please login to perform setting on the account" preferredStyle:UIAlertControllerStyleAlert];
        okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
    } else {
        // OK: Non-guest user
        UIAlertController *userAction = [UIAlertController alertControllerWithTitle:@"Settings" message:@"Please select one of the following actions:" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actionChangeUserPassword = [UIAlertAction actionWithTitle:@"Change Password" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Create a new alert to ask user for a new password
            [self requestPasswordChange];
        }];
        UIAlertAction *actionDeleteUserAccount = [UIAlertAction actionWithTitle:@"Delete Account" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            // Delete user account
            [self verifyAccountDeletion];
        }];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // Do nothing here
        }];
        [userAction addAction:actionChangeUserPassword];
        [userAction addAction:actionDeleteUserAccount];
        [userAction addAction:actionCancel];
        [self presentViewController:userAction animated:YES completion:nil];
    }

}

#pragma mark - Update password

// Create a alert to ask user for a password and update database
- (void) requestPasswordChange{
    // Create a alert to ask user for a password
    UIAlertController *getPasswordAlert = [UIAlertController alertControllerWithTitle:@"Password Update" message:@"Please enter a new password:" preferredStyle:UIAlertControllerStyleAlert];
    
    // Create done button that will process password update request
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"Update password" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Get password field
        NSString *sNewPasswordString = getPasswordAlert.textFields.firstObject.text;

        // Send request to database
        [self sendUpdatePasswordRequest:sNewPasswordString];
    }];
    
    // Create cancel button
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // Add actions to the alert
    [getPasswordAlert addAction:actionDone];
    [getPasswordAlert addAction:actionCancel];
    
    // Add textfield to the alert
    [getPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New password here..";
    }];
    
    // Display the controller with a textfield for password and it should handle completion task
    [self presentViewController:getPasswordAlert animated:YES completion:nil];
    
}

// Connect to Azure database and send user password update request.
- (void) sendUpdatePasswordRequest:(NSString*)sNewPassword{
    // Get username and password
    NSString *sUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    NSString *sPassword = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getPassword];
    
    // Call verify user account to make sure a copy of retrieve user info entry is available
    [self.rcDataConnection verifyUserAccount:sUsername Password:sPassword Callback:^(BOOL callbackItem) {
        // Verify user account is available
        if (callbackItem == YES){
            // Get user data into a mutable dicitonary
            NSMutableDictionary *userMutData = [[NSMutableDictionary alloc] initWithDictionary:[self.rcDataConnection getCurrentUserDataEntry]];
            
            // Update password field
            [userMutData setValue:sNewPassword forKey:AZURE_USER_TABLE_PASSWORD];
            
            // Send the update to azure database
            [self.rcDataConnection updateUserPasswordWithDictionary:userMutData Callback:^(NSNumber *completeFlag) {
                // Do something here
                if ([completeFlag  isEqual: @YES]){
                    NSLog(@"<sendUpdatePasswordRequest> Success");
                    // Update internal password storage
                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setPassword:sNewPassword];
                    
                    // Create a new user credential with the newly updated password
                    NSURLCredential *credential;
                    credential = [NSURLCredential credentialWithUser:sUsername password:sPassword persistence:NSURLCredentialPersistencePermanent];
                    // Call app delegate method to store this new credential
                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setUserCredential:credential];
                    
                    // Show success message
                    UIAlertController *alertOK = [UIAlertController alertControllerWithTitle:@"Password Updated" message:@"Your password is updated successfully" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertOK addAction:actionOK];
                    
                    // Display message
                    [self presentViewController:alertOK animated:YES completion:nil];
                } else {
                    // Failed
                    NSLog(@"<sendUpdatePasswordRequest> Failed");
                    
                    // Show failure message
                    UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Your password is not updated" message:@"Error: Password Update Failed" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionRetry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        // Retry password update
                        NSLog(@"Password update try");
                        [self sendUpdatePasswordRequest:sNewPassword];
                    }];
                    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    // Add actions
                    [alertFailed addAction:actionOK];
                    [alertFailed addAction:actionRetry];
                    
                    // Display message
                    [self presentViewController:alertFailed animated:YES completion:nil];
                }
            }];
        } else {
            // callbackItem error
            NSLog(@"<verifyUserAccount> Error, callbackItem return failure");
            // Show failure message
            UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Password not updated" message:@"Error: Cannot verify user account" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            // Add actions
            [alertFailed addAction:actionOK];
            
            // Display message
            [self presentViewController:alertFailed animated:YES completion:nil];
            
        } // End of callbackItem failure
        
    }];

}

#pragma mark - Delete user account

// Show an alert to verify deletion of the account, provide user with an option to cancel
- (void) verifyAccountDeletion{
    // Show success message
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"Delete Account" message:@"Do you want to remove your account?" preferredStyle:UIAlertControllerStyleAlert];
    
    // Define delete action
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"Delete my account" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        // Send a request to remove user account
        [self requestDeleteUser];
    }];
    
    // Define cancel action
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    // Add actions
    [alertDelete addAction:actionDelete];
    [alertDelete addAction:actionCancel];
    
    // Display message
    [self presentViewController:alertDelete animated:YES completion:nil];
}

// Verify user identity then send a request to server to delete current user
- (void) requestDeleteUser{
    // Get username and password
    NSString *sUsername = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    NSString *sPassword = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getPassword];
    
    [self.rcDataConnection verifyUserAccount:sUsername Password:sPassword Callback:^(BOOL callbackItem) {
        // Proceed if callbackItem returned YES
        if (callbackItem == YES){
            // Get user data into a mutable dicitonary
            NSDictionary *currentUserInfo = [self.rcDataConnection getCurrentUserDataEntry];
            
            [self.rcDataConnection deleteUserAccount:currentUserInfo Callback:^(BOOL flag) {
                if (flag == TRUE){
                    // Log current user out
                    [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutUser];
                    
                    // Show success message
                    UIAlertController *alertOK = [UIAlertController alertControllerWithTitle:@"Account deleted" message:@"Your user account is deleted" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    // Add actions
                    [alertOK addAction:actionOK];
                    
                    // Display message
                    [self presentViewController:alertOK animated:YES completion:nil];
                } else {
                    NSLog(@"Account delete failed");
                    
                    // Show failure message
                    UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Account deleted failed" message:@"Error: An error occured while deleting account" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    
                    // Add actions
                    [alertFailed addAction:actionOK];
                    
                    // Display message
                    [self presentViewController:alertFailed animated:YES completion:nil];
                }
            }];
        } else { // VerifyUserAccount returned failure
            // Show failure message
            UIAlertController *alertFailed = [UIAlertController alertControllerWithTitle:@"Account deleted failed" message:@"Error: Cannot verify user identity" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            // Add actions
            [alertFailed addAction:actionOK];
            
            // Display message
            [self presentViewController:alertFailed animated:YES completion:nil];
        }
    }];
}


@end
