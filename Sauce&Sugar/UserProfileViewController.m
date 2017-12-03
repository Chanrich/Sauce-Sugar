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
    // Store all downloaded image data
    NSMutableArray <NSMutableDictionary*> *userPhotosMutableArray;
    unsigned long downloadedImageCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set username
    NSString *currentUser = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    [self.rcUsernameLabel setText:currentUser];
    
    // Initialize singleton instances
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    self.rcBlobContainer = [rcAzureBlobContainer sharedStorageContainer];
        
    // Initialize mutable array
    userPhotosMutableArray = [[NSMutableArray alloc] init];
    
    // Initialize variables
    downloadedImageCount = 0;
    
    // Get sequence number
    [self.rcDataConnection getUniqueNumber_WithUsername:currentUser Callback:^(NSDictionary *callbackItem) {
        // Deduct 1 from sequence number to get total counts of entries
        NSNumber *tempSequence = [callbackItem objectForKey:AZURE_USER_TABLE_SEQUENCE];
        NSNumber *totalCount = [NSNumber numberWithInt:(tempSequence.intValue - 1)];
        // Update Sequence label UI in main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rcUploadCount setText:[NSString stringWithFormat:@"User upload count: %@", totalCount]];
        }); // End of dispatch to main thread
    }];
    
    // Request all photos that current user had uploaded
    // Get current user's data from the cloub
    [self.rcDataConnection getDatafromUser:currentUser FoodType:FOODTYPE_ALL Callback:^(NSArray *callbackItem) {
        // In Callback function
        if (callbackItem == nil){
            // Handle errors, either no data available or download error
            NSLog(@"Error occured during loading");
            // ========= Create Alert =========
            // Create a UI AlertController to show warning message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Data Download Error" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:NULL];
            // ================================
        } else {
            // Successful download
            NSLog(@"Array Data received");
            
            NSLog(@"Data received from callbackItem %lu", [callbackItem count]);
            // Store result items into cell array.
            for (NSDictionary* returnDict in callbackItem){
                // Get sequence number and minus the value by 1 to get total count of entries
                NSNumber *sequenceTemp = [returnDict objectForKey:@"sequence"];
                // Get sequence number
                NSString *sequenceNum = [sequenceTemp stringValue];
                NSLog(@"Requesting image at sequence number %@", sequenceNum);
                // Request one image with name stored inside dictionary key "sequence"
                [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:sequenceNum rcCallback:^(UIImage *rcReturnedImage) {
                    // Allocate a mutable dictionary to store image along with its sequence number
                    NSMutableDictionary *imageDictionary = [[NSMutableDictionary alloc] init];
                    
                    // Store data into dictionary
                    [imageDictionary setObject:rcReturnedImage forKey:IMAGEDICTIONARY_IMAGE];
                    [imageDictionary setObject:sequenceNum forKey:IMAGEDICTIONARY_SEQUENCE];
                    // Store the dictionary containing following data into array:
                    // - Key -  : - Value -
                    // "image"  : user photo
                    // "seq"    : sequence number for the photo
                    [userPhotosMutableArray addObject:imageDictionary];

                    NSLog(@"User photo array size: %lu/%lu", (unsigned long)[userPhotosMutableArray count], [callbackItem count]);
                
                    // Increment image count
                    downloadedImageCount++;
                    // When all images are downloaded, reload collection view
                    if (downloadedImageCount == [callbackItem count]){
                        NSLog(@"reloading collection view, download count: %lu", downloadedImageCount);
                        // Reload collection view in main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.rcCollectionView reloadData];
                        });
                    }
                    
                }]; // End of download image method
                
            } // End of for loop, end of processing of one entry
            
        }
        
    }]; // End of getDatafromUser
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
    NSLog(@"Setting up cell at indexPath.item: %ld", (long)indexPath.item);
    return cell;
}

#pragma mark - Layout

// Detect screen size and adjust each row to fit 3 cells
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float singleCellWidth = UIScreen.mainScreen.bounds.size.width / 3;
    NSLog(@"Setting cell width to %f", singleCellWidth);
    
    return CGSizeMake(singleCellWidth, singleCellWidth);
}


@end
