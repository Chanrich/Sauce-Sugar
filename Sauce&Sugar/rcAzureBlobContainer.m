//
//  rcAzureBlobContainer.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "rcAzureBlobContainer.h"

@implementation rcAzureBlobContainer

// Create a container with containerName
- (void) createImageWithBlobContainer:(NSString*)containerName BlobName:(NSString*)BlobName ImageData:(UIImage*)ImageData {
    NSError *AZSAccountError;
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:@"DefaultEndpointsProtocol=https;AccountName=imagestorageblobs;AccountKey=d8e1NrdP49wzHvxaPtLa41uO3mX/fXPWPMSBa4MPGSe4/+5E7zavNBsvMuqSoN1HynKuyYumoyNLkCpgaowJOQ==" error:&AZSAccountError];
    if (AZSAccountError){
        // Show error message then quit
        NSLog(@"Error when creating account");
    } else {
        // No Error
        
        // Create a blob client object
        AZSCloudBlobClient *blobClient = [account getBlobClient];
        
        // Create a container
        AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:containerName];
        
        [blobContainer createContainerIfNotExistsWithAccessType:AZSContainerPublicAccessTypeContainer requestOptions:[blobClient defaultRequestOptions] operationContext:nil completionHandler:^(NSError * _Nullable error, BOOL exist) {
            if (error){
                NSLog(@"Error when creating container:\n %@", error);
            } else {
                if (exist){
                    NSLog(@"Container existing");
                } else {
                    NSLog(@"Container created");
                }
                NSData *imgdata = UIImagePNGRepresentation(ImageData);
                AZSCloudBlockBlob *imageblockblob = [blobContainer blockBlobReferenceFromName:BlobName];
                [imageblockblob uploadFromData:imgdata completionHandler:^(NSError *error) {
                    if (error){
                        NSLog(@"Error when uploading blob\n %@", error);
                    } else {
                        NSLog(@"Successfully uploaded %@", BlobName);
                    }
                }];
                            }
        }];
    }
    
    
}

// Grab image from blobName inside blobCotainer and a UIImageView to this image
//- (void)getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer{
//    // Create a blob
//    AZSCloudBlockBlob *blockblob = [blobContainer blockBlobReferenceFromName:blobName];
//
//    // Perform blob download
//    [blockblob downloadToDataWithCompletionHandler:^(NSError * _Nullable error, NSData * _Nullable downloadedData) {
//        if (error){
//            NSLog(@"Error when downloading:\b %@", error);
//        } else {
//            NSLog(@"Download successful");
//            UIImage *imagefromdata = [UIImage imageWithData:downloadedData];
//            // Set UIImageView to downloaded image
//            [self.MainImageView setImage:imagefromdata];
//        }
//
//    }];
//}


@end
