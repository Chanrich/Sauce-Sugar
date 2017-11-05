//
//  LoadingScreenViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "rcAzureBlobContainer.h"
@interface LoadingScreenViewController : UIViewController

// ============ Custom Properties ==============
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;
// Singleton instance of image blob database
@property (strong, nonatomic) rcAzureBlobContainer* rcBlobstorage;
// current user
@property NSString* currentUsername;
// Store returned dictionary
@property NSDictionary *rcDownloadedDictionary;
// Image upload complete flag
@property NSNumber* rcImageUploadComplete;
// UI elements
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *statusIndicator;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@end
