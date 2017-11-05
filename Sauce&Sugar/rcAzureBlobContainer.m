//
//  rcAzureBlobContainer.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "rcAzureBlobContainer.h"

@implementation rcAzureBlobContainer

// Create a singleton
+ (instancetype) sharedStorageContainer{
    static rcAzureBlobContainer *myBlobContainer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myBlobContainer = [[self alloc] init];
    });
    return myBlobContainer;
}

// Override init
- (id) init{
    self = [super init];
    if (self){
        // Setup Microsoft Azure Connection
        NSLog(@"Init started: Azure Cloud Storage account initializing");
        // Error pointer
        NSError *AZSAccountError;
        self.account = [AZSCloudStorageAccount accountFromConnectionString:@"DefaultEndpointsProtocol=https;AccountName=imagestorageblobs;AccountKey=d8e1NrdP49wzHvxaPtLa41uO3mX/fXPWPMSBa4MPGSe4/+5E7zavNBsvMuqSoN1HynKuyYumoyNLkCpgaowJOQ==" error:&AZSAccountError];
        if (AZSAccountError){
            // Show error message
            NSLog(@"Error when creating account");
            // Set flag
            self.connectionEstablishedFlag = @NO;
        } else {
            // Show log message
            NSLog(@"Azure Cloud Storage account initialized");
            // Set flag
            self.connectionEstablishedFlag = @YES;
        }
        // Set container created flag to false
        self.containerCreatedFlag = @NO;
        
    }
    return self;
}

// Connect to a container with username. This function will setup rcBlobClient and rcBlobContainer
- (void) connectToContainerWithName:(NSString*)username{
    if (([self.connectionEstablishedFlag boolValue] == 1) &&
        ([self.containerCreatedFlag boolValue] == 0)){
        // Debug
        NSLog(@"Connecting to container: %@", username);
        
        // Create a blob client object
        self.rcBlobClient = [self.account getBlobClient];
        
        // Create a container, container name must be lower case
        self.rcBlobContainer = [self.rcBlobClient containerReferenceFromName:[username lowercaseString]];
        
        if (self.rcBlobClient != nil &&
            self.rcBlobContainer != nil){
            // Set flag
            self.containerCreatedFlag = @YES;
            NSLog(@"Connection to container established");
        } else {
            // Set flag
            self.containerCreatedFlag = @NO;
            NSLog(@"Error occured while connecting to container");
        }
    } else {
        NSLog(@"Container is already existing...");
        // Set flag
        self.containerCreatedFlag = @NO;
    }
}

// Create a container with callback
- (void) createImageWithBlobContainerSetCallback:(void(^)(NSNumber *rcCompleteFlag))rcCallback{
    // Make sure blob connection is established
    if ([self.connectionEstablishedFlag boolValue] == 0){
        // Show error message then quit
        NSLog(@"Error when establishing connection");
    } else {
        // No Error
        [self.rcBlobContainer createContainerIfNotExistsWithAccessType:AZSContainerPublicAccessTypeContainer requestOptions:[self.rcBlobClient defaultRequestOptions] operationContext:nil completionHandler:^(NSError * _Nullable error, BOOL exist) {
            if (error){
                NSLog(@"Error when creating container:\n %@", error);
            } else {
                if (exist){
                    NSLog(@"Container existing");
                } else {
                    NSLog(@"Container created");
                }
                //Convert UI image to NSData
                NSData *imgdata = UIImagePNGRepresentation(self.rcImageHolder);

                // Create a blob reference
                AZSCloudBlockBlob *imageblockblob = [self.rcBlobContainer          blockBlobReferenceFromName:self.uniqueSequenceNumber];
                
                // Upload data to Azure Blob Storage
                [imageblockblob uploadFromData:imgdata completionHandler:^(NSError *error) {
                    if (error){
                        NSLog(@"Error when uploading blob\n %@", error);
                        // View controller should check for NO and issue a warning
                        rcCallback([NSNumber numberWithBool:NO]);
                    } else {
                        NSLog(@"Successfully uploaded image");
                        // View controller should check for YES to dismiss itself
                        rcCallback([NSNumber numberWithBool:YES]);
                    }
                }];
            }
        }];
    }
}

// Download single image with name sequenceNumber from a User and return the image in the callback function as a UIImage
// Have to call connectToContainerWithName first to conntect container
- (void)getImagefromBlobFromUser:(NSString*)username sequenceNumber:(NSString*)sequenceNumber rcCallback:(void(^)(UIImage *rcCompleteFlag))rcCallback{
    
    // Create a blob
    AZSCloudBlockBlob *blockblob = [self.rcBlobContainer blockBlobReferenceFromName:sequenceNumber];

    // Perform blob download
    [blockblob downloadToDataWithCompletionHandler:^(NSError * _Nullable error, NSData * _Nullable downloadedData) {
        if (error){
            NSLog(@"Error when downloading image at sequence number : %@", sequenceNumber);
        } else {
            NSLog(@"Download successful, SN: %@", sequenceNumber);
            // Transform from NSData to UIImage type
            UIImage *imagefromdata = [UIImage imageWithData:downloadedData];
            
            // Return the UIImage to callback function
            rcCallback(imagefromdata);
        }

    }];
}


- (void)insertUniqueSequenceNumber:(NSString *)seqnum {
    self.uniqueSequenceNumber = [NSString stringWithString:seqnum];
}

- (void)insertImage:(UIImage *)img { 
    self.rcImageHolder = img;
}

@end
