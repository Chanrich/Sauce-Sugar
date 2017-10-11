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
@property NSNumber *containerCreatedFlag;

// Connect to a container with username. This function will setup rcBlobClient and rcBlobContainer
- (void) connectToContainerWithName:(NSString*)username;

// Create a container with containerName
// Have to call connectToContainerWithName first to conntect container
- (void) createImageWithBlobContainer:(NSString*)containerName BlobName:(NSString*)BlobName ImageData:(UIImage*)ImageData rcCallback:(void(^)(NSNumber *rcCompleteFlag))rcCallback;


// Download single image with name sequenceNumber from a User and return the image in the callback function as a UIImage
// Have to call connectToContainerWithName first to conntect container
- (void)getImagefromBlobFromUser:(NSString*)username sequenceNumber:(NSString*)sequenceNumber rcCallback:(void(^)(UIImage *rcCompleteFlag))rcCallback;


// Override init to initialize client
- (id) init;

+ (instancetype) sharedStorageContainer;

@end
