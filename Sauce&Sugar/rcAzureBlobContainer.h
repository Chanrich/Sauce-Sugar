//
//  rcAzureBlobContainer.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDelegate.h"
@interface rcAzureBlobContainer : NSObject

// Pointer to blob storage account variables
@property (strong, nonatomic) AZSCloudStorageAccount *account;
@property AZSCloudBlobClient *rcBlobClient;
@property AZSCloudBlobContainer *rcBlobContainer;

// Success flag
@property NSNumber *connectionEstablishedFlag;

// Storage for unique sequence number
@property (nonatomic) NSString *uniqueSequenceNumber;
// Storage to hold image data
@property (strong, nonatomic) UIImage *rcImageHolder;

// =============== Insert data ====================
// Store the unique sequence number to property NSString *uniqueSequenceNumber
- (void) insertUniqueSequenceNumber:(NSString*)seqnum;
// Store Image to property UIImage *rcImageHolder
- (void) insertImage:(UIImage*)img;
// =================================================


// ================== Upload ==================
// Create a container with containerName
- (void) createImageWithBlobContainer:(NSString*)username SetCallback:(void(^)(NSNumber *rcCompleteFlag))rcCallback;
// ======================================================

// ================== Download ==================
// Download single image with name sequenceNumber from a User and return the image in the callback function as a UIImage
- (void)getImagefromBlobFromUser:(NSString*)username sequenceNumber:(NSString*)sequenceNumber rcCallback:(void(^)(UIImage *rcReturnedImage))rcCallback;
// ======================================================

// Override init to initialize client
- (id) init;

+ (instancetype) sharedStorageContainer;

@end
