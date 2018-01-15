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
#import "LoadingScreenViewController.h"
#import "YelpAPIConnection.h"
#import "UIView+UIView_ViewAnimations.h"

@interface AddToDatabase_ViewController : UIViewController <UITextFieldDelegate, YelpAPIDataDelegate>


// ============== UI Outlets  ===============

@property (strong, nonatomic) IBOutlet UILabel *rcUsernameLabel;
@property (strong, nonatomic) IBOutlet UITextField *TextField_RestaurantName;
@property (strong, nonatomic) IBOutlet UIImageView *MainImageView;
// ==========================================

// ============ Custom Properties ==============
// A property to hold image being passed in from presenting view controller
@property (strong, nonatomic) UIImage *rcImageHolder;
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;
// Singleton instance of image blob database
@property (strong, nonatomic) rcAzureBlobContainer* rcBlobstorage;
// Image sizes;
@property (strong, nonatomic) NSNumber *originalRcImageSize;
@property (strong, nonatomic) NSNumber *nRcImageSize;

// Store returned dictionary
@property NSDictionary *rcDownloadedDictionary;

@end
