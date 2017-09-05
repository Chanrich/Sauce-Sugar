//
//  LocationDataController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/27/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "LocationDataController.h"

@implementation LocationDataController
- (Location*)getPointOfInterest{
    Location *mylocation = [[Location alloc] init];
    mylocation.address = @"First location, xxx drive";
    mylocation.photofilename = @"abc.png";
    mylocation.latitude = 12.123;
    mylocation.longitude = 23.234;
    return mylocation;
}
@end
