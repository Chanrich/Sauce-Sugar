//
//  YelpAPIConnection.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 1/8/18.
//  Copyright © 2018 Sauce&Sugar. All rights reserved.
//

#import "YelpAPIConnection.h"

@implementation YelpAPIConnection


- (void) requestForBusinessNamesNearLatitude:(double)latitude Longitude:(double)longitude {
    
    NSString *params = [NSString stringWithFormat:@"latitude=%f&longitude=%f&radius=1500&limit=20&term=restaurants&sort_by=distance", latitude, longitude];
    
    NSString *urlWithParams = [NSString stringWithFormat:@"https://api.yelp.com/v3/businesses/search?%@", params];
    NSLog(@"Full URL: %@", urlWithParams);
    
    NSMutableURLRequest *yRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlWithParams]];
    
    [yRequest setHTTPMethod:@"GET"];
    
    // Set authorization API key
    [yRequest setValue:@"Bearer tFSoDx0pVk3wiBu-6WFAFA67Hacb4kdC3sGtmx0BdgSCjZs5fRvyoKmN1_Gx2ZiFxFv9xH4OK1F4NjmS70k56bnp4l1Gg8PVnFRX2IqDfvTPhxg0zetbT3qKJiZTWnYx" forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:yRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Get data
        
        // convert it to dictionary
        NSError *errorJson;
        id rData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJson];
        if (errorJson){
            // Something bad
            NSLog(@"Json parsing error");
        }
        
        if ([rData isKindOfClass:[NSDictionary class]]){
            // Returned data is the desired dictionary
            NSDictionary *rDataDictionary = rData;
            NSLog(@"Replied Dictionary: %@",rDataDictionary);
            NSLog(@"Total found businesses: %@", [rDataDictionary objectForKey:@"total"]);
            
            // Extract business objects
            NSArray *businessesArray = [rDataDictionary objectForKey:@"businesses"];
            
            // Send data array back to delegate object
            [self.delegate didReceivedBusinessData:businessesArray];

        } else {
            // Returned data is not desired
            NSLog(@"Returned data not dictionary");
        }
        
    }] resume];
    
}


@end



