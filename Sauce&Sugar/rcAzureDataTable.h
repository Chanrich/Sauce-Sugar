//
//  rcAzureDataTable.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/21/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
@interface rcAzureDataTable : NSObject

// Declare data object that will be stored into the table
@property (strong, nonatomic) MSTable *rcMSTable;
@property (strong, nonatomic) NSDictionary *rcDataDictionary;
// Add Microsoft client to connect to Azure
@property (strong, nonatomic) MSClient *client;

// Define custom functions
// Add a new entry into table
- (void) InsertDataIntoTable:(NSString*)tableName;

// Store data into the class
- (void) prepareFoodData:(NSString*)foodname resName:(NSString*)resName comment:(NSString*)rcComment username:(NSString*)username sequenceNumber:(NSNumber*)sequenceNumber;

// Prepare userdata
- (void) prepareUserData:(NSString*)username;

// Update an entry into the table, retrieve the information first and then update that entry//
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict;

// getUniqueID_WithCallback will make the request and return the unique serial number in a NSArray* to the callback function. Caller will have to create a block to catch the return value
- (void) getUniqueNumber_WithUsername:(NSString*)rcUsername  Callback:(void(^)(NSDictionary *callbackItem)) returnCallback;
// Override init to initialize client
- (id) init;

+ (instancetype) sharedDataTable;


@end
