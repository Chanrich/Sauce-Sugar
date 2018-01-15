//
//  YelpAPIConnection.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 1/8/18.
//  Copyright © 2018 Sauce&Sugar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

// Define protocol methods as data will be returned to those methods
@protocol YelpAPIDataDelegate
// Return arrays of business names
- (void) didReceivedBusinessData:(NSArray*)businesssArray;

@end

@interface YelpAPIConnection : NSObject

- (void) requestForBusinessNamesNearLatitude:(double)latitude Longitude:(double)longitude;

@property (weak, nonatomic) id <YelpAPIDataDelegate> delegate;

@end
