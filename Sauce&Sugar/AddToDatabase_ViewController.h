//
//  AddToDatabase_ViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
@interface AddToDatabase_ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *TextField_Name;
@property (strong, nonatomic) IBOutlet UITextField *TextField_RestaurantName;
@property (strong, nonatomic) IBOutlet UITextField *TextField_Comment;
@property (strong, nonatomic) IBOutlet UIButton *Button_AddDatabase;
@property (strong, nonatomic) IBOutlet UIImageView *MainImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *DoneBarButton;

// A property to hold image being passed in from presenting view controller
@property (strong, nonatomic) UIImage *rcImageHolder;
- (IBAction)ButtonTouchedUpInside_Add:(id)sender;
- (void) createBlobContainer:(NSString*)containerName;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *UploadButtonNavibar;
- (void) getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer;
@end
