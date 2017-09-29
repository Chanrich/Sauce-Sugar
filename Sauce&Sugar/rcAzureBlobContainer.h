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


// Custom function
- (void) createImageWithBlobContainer:(NSString*)containerName BlobName:(NSString*)BlobName ImageData:(UIImage*)ImageData rcCallback:(void(^)(NSNumber *rcCompleteFlag))rcCallback;
@end
