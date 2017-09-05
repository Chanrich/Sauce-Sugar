//
//  Location.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/27/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *photofilename;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@end
