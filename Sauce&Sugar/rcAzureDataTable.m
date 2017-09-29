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

- (void) InsertDataIntoTable:(NSString*)tableName rcCallback:(void(^)(NSNumber *rcCompleteFlag))rcCallback{
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:tableName];

    // Insert data into table
    [itemTable insert:self.rcDataDictionary completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
            // Callback function should check the flag and issue a warning
            rcCallback([NSNumber numberWithBool:NO]);
        } else {
            NSLog(@"Item inserted: id:%@", [InsertedItem objectForKey:@"id"]);
            // Callback function should check for flag before dismissing the view
            rcCallback([NSNumber numberWithBool:YES]);
        }
    }];
}

// Store data into the class
- (void) prepareFoodData:(NSString*)foodname resName:(NSString*)resName comment:(NSString*)rcComment username:(NSString*)username sequenceNumber:(NSNumber*)sequenceNumber{
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
                               @"userName" : username,
                               @"sequence" : sequenceNumber
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
- (void) getUniqueNumber_WithUsername:(NSString*)rcUsername  Callback:(void(^)(NSDictionary *callbackItem)) returnCallback {
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:@"rcUserDataInfo"];
    
    // Create a predicate to select the user
    NSString *rcSelectUser = [NSString stringWithFormat:@"USERNAME=%@", rcUsername];
    
    // Read using query
    [itemTable readWithQueryString:rcSelectUser completion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Unique number read error!");
            // Pass a null back to callback, callback should check this for error
            returnCallback(nil);
        } else {

            // Debug
            NSLog(@"Count of result.item array: %lu", [result.items count]);
            
            if ([result.items count] == 1){
                // Pass the NSDictionary* back to callback function
                returnCallback([result.items objectAtIndex:0]);
                
                // Delete after test
//                for (NSDictionary *item in result.items){ //items are NSArray item
//                    // Increment the retrieved sequence number by 1
//                    NSNumber *newValue = [NSNumber numberWithInt:[[item objectForKey:@"SequenceNumber"] intValue] + 1];
//
//                    // Update the newly incremented number into the key
//                    [item setValue:newValue forKey:@"SequenceNumber"];
//
//                    // Push it to Azure table
//                    [itemTable update:item completion:^(NSDictionary * _Nullable item, NSError * _Nullable error) {
//                        if (error){
//                            NSLog(@"Error when updating dictionary");
//                        } else {
//                            NSLog(@"Successfully updated dictionary");
//                        }
//                    }];
//                }
            } else if ([result.items count] > 1){
                // More than one entry is downloaded, something must be wrong as there shouldn't have two exact same user
                NSLog(@"More than one user is selected, task aborting");
            } else {
                // Error
                NSLog(@"No user is selected, task aborting");
            }
        }
    }];
    

}

// Update an entry into the table, retrieve the information first and then update that entry
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict{
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:@"rcUserDataInfo"];
    
    // Increment the retrieved sequence number by 1
    NSNumber *newValue = [NSNumber numberWithInt:[[myDict objectForKey:@"SequenceNumber"] intValue] + 1];
    
    // Update the newly incremented number into the key
    [myDict setValue:newValue forKey:@"SequenceNumber"];
    
    // Push it to Azure table
    [itemTable update:myDict completion:^(NSDictionary * _Nullable item, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error when updating dictionary");
        } else {
            NSLog(@"Successfully updated dictionary");
        }
    }];
}
@end
