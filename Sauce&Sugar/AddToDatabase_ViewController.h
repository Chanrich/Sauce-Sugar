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
- (IBAction)ButtonTouchedUpInside_Add:(id)sender;
- (void) createBlobContainer:(NSString*)containerName;
- (void) getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer;
@end
