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
    // Store all downloaded image data
    NSMutableArray <NSMutableDictionary*> *userPhotosMutableArray;
    unsigned long downloadedImageCount;
    // A UIView to cover up collection view during data loading
    UIView *collectionOverlay;
    
    // Setting image
    IBOutlet UIImageView *rcSettingsImage;
    
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
    downloadedImageCount = 0;
    currentUser = @"";
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
        
        // Get sequence number
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
            // Remove loading screen after a delay
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [collectionOverlay removeFromSuperview];
            });
            
            // In Callback function
            if (callbackItem == nil){
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
                NSLog(@"Data received from callbackItem %lu", (unsigned long)[callbackItem count]);
                // Store result items into cell array.
                for (NSDictionary* returnDict in callbackItem){
                    // Get sequence number and minus the value by 1 to get total count of entries
                    NSNumber *sequenceTemp = [returnDict objectForKey:AZURE_DATA_TABLE_SEQUENCE];
                    // Get sequence number
                    NSString *sequenceNum = [sequenceTemp stringValue];
                    NSLog(@"Requesting image at sequence number %@", sequenceNum);
                    // Request one image with name stored inside dictionary key "sequence"
                    [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:sequenceNum rcCallback:^(UIImage *rcReturnedImage) {
                        // Allocate a mutable dictionary to store image along with its sequence number
                        NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
                        
                        // Pack data into dictionary
                        [imageDictionary setObject:rcReturnedImage forKey:IMAGEDICTIONARY_IMAGE];
                        [imageDictionary setObject:sequenceNum forKey:IMAGEDICTIONARY_SEQUENCE];
                        // Store the dictionary containing following data into array:
                        // - Key -  : - Value -
                        // "image"  : user photo
                        // "seq"    : sequence number for the photo
                        [userPhotosMutableArray addObject:imageDictionary];
                        
                        NSLog(@"User photo array size: %lu/%lu", (unsigned long)[userPhotosMutableArray count], (unsigned long)[callbackItem count]);
                        
                        // Increment image count
                        downloadedImageCount++;
                        // When all images are downloaded, reload collection view
                        if (downloadedImageCount == [callbackItem count]){
                            NSLog(@"reloading collection view, download count: %lu", downloadedImageCount);
                            // Reload collection view in main thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.rcCollectionView reloadData];
                            });
                        } else {
                            // Reload even if not all images are downloaded
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.rcCollectionView reloadData];
                            });
                        }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Layout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return downloadedImageCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"userPhotoCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    // Grab the image using its tag value
    UIImageView *photoImage = (UIImageView*) [cell viewWithTag:5];
    // Grab label that is used to store sequence number
    UILabel *sequenceLabelStorage = (UILabel*) [cell viewWithTag:6];
    NSMutableDictionary *returnTempDict = [userPhotosMutableArray objectAtIndex:indexPath.item];
    
    photoImage.image = [returnTempDict objectForKey:IMAGEDICTIONARY_IMAGE];
    sequenceLabelStorage.text = [returnTempDict objectForKey:IMAGEDICTIONARY_SEQUENCE];
    // NSLog(@"Setting up cell at indexPath.item: %ld", (long)indexPath.item);
    return cell;
}

// Detect screen size and adjust each row to fit 3 cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float singleCellWidth = UIScreen.mainScreen.bounds.size.width / 3;
    // NSLog(@"Setting cell width to %f", singleCellWidth);
    
    return CGSizeMake(singleCellWidth, singleCellWidth);
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
