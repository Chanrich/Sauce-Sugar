//
//  rcAzureDataTable.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/21/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "rcAzureDataTable.h"

@implementation rcAzureDataTable

// Create a singleton
+ (instancetype) sharedDataTable{
    static rcAzureDataTable *myDatatable = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myDatatable = [[self alloc] init];
    });
    return myDatatable;
}

// Override init
- (id) init{
    self = [super init];
    if (self){
        // Setup Microsoft Azure Connection
        NSLog(@"Init started: MSClient initialized");
        self.client = [MSClient clientWithApplicationURLString:@"https://saucensugarmobileapp.azurewebsites.net"];
    }
    return self;
}

- (void) InsertDataIntoTable:(NSString*)tableName{
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:tableName];
    

    // Insert data into table
    [itemTable insert:self.rcDataDictionary completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
            
        } else {
            NSLog(@"Item inserted: id:%@", [InsertedItem objectForKey:@"id"]);
            
        }
    }];
}

// Store data into the class
- (void) prepareFoodData:(NSString*)foodname resName:(NSString*)resName comment:(NSString*)rcComment username:(NSString*)username{
    // Collect data into NSDictionary object.
    // NSDictioanry format: NSDictionary *dict = @{ key : value, key2 : value2}
    //    Object descriptions:
    //    1.    Name of the food
    //    2.    Name of the restaurant (if not yet exist, option to add restaurant appears)
    //    3.    Photo
    //    4.    Rating (Binary option: Good or bad)
    //    5.    Comments
    //    6.    Price range
    self.rcDataDictionary = @{ @"fName" : foodname,
                               @"rName" : resName,
                               @"comments" : rcComment,
                               @"userName" : username
                               };
}

// Prepare userdata
- (void) prepareUserData:(NSString*)username{
    // Prepare object for integer since NSDictioanry only accepts object
    NSNumber *seqNum = [NSNumber numberWithInt:0];
    
    // For now, only prepare username
    self.rcDataDictionary = @{ @"Username" : username,
                               @"SEQUENCENUMBER" : seqNum
                               };
}

// getUniqueID_WithCallback will make the request and return the unique serial number in a NSArray* to the callback function. Caller will have to create a block to catch the return value
- (void) getUniqueNumber_WithUsername:(NSString*)rcUsername  Callback:(void(^)(NSArray *callbackItem)) returnCallback {
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:@"rcUserDataInfo"];
    
    // Create a predicate to select the user
    NSString *rcSelectUser = [NSString stringWithFormat:@"USERNAME == %@", rcUsername];
    NSPredicate *rcPredicate = [NSPredicate predicateWithFormat:rcSelectUser];
    
    // Read only the selected user
    [itemTable readWithPredicate:rcPredicate completion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Read error!");
            // Pass a null back to callback, callback should check this for error
            returnCallback(nil);
        } else {
            // Pass the NSArray back to callback function
            returnCallback(result.items);
            
            NSLog(@"Check for items");
            for (NSDictionary *item in result.items){ //items are NSArray item
                // Get data by its key
                NSLog(@"Not in return callback: \n\tRetrieved number: %@", [item objectForKey:@"SequenceNumber"]);
            }
        }
    }];
    
    // Update and increment the sequence number
    

}

@end
