//
//  AddToDatabase_ViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "rcAzureBlobContainer.h"

@interface AddToDatabase_ViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate>

// Text collection
@property (strong, nonatomic) IBOutlet UITextField *TextField_Name;
@property (strong, nonatomic) IBOutlet UITextField *TextField_RestaurantName;
@property (strong, nonatomic) IBOutlet UITextView *TextView_Comment;

// UI elements
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *rcActivityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *Button_AddDatabase;
@property (strong, nonatomic) IBOutlet UIImageView *MainImageView;
@property (weak, nonatomic) IBOutlet UIButton *Button_Like;
@property (weak, nonatomic) IBOutlet UIButton *Button_NoLike;

// Action Add button pressed
- (IBAction)ButtonTouchedUpInside_Add:(id)sender;


// ============ Custom Properties ==============
// A property to hold image being passed in from presenting view controller
@property (strong, nonatomic) UIImage *rcImageHolder;
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;
// Store next unique sequence number
@property NSNumber* rcUniqueNumber;
// Store like status
@property NSNumber *rcLikeStatus;
// Store returned dictionary
@property NSDictionary *rcDownloadedDictionary;

// Rating Buttons events
- (IBAction)TouchUpInside_LikeButton:(id)sender;
- (IBAction)TouchUpInside_NoLikeButton:(id)sender;


// Task completion flags
@property NSNumber* rcImageUploadCompleted;
@property NSNumber* rcDataUploadCompleted;

// Custom Functions
- (void) getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer;
@end
