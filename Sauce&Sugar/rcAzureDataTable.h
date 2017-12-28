//
//  rcAzureDataTable.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/21/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface rcAzureDataTable : NSObject <CLLocationManagerDelegate>

// Declare data object that will be stored into the table
@property (strong, nonatomic) MSTable *rcMSTable;
@property (strong, nonatomic) NSMutableDictionary *rcDataDictionary;
@property (strong, nonatomic) NSMutableDictionary *rcDataDictionaryForUserTable;
// Add Microsoft client to connect to Azure
@property (strong, nonatomic) MSClient *client;
// Use GPS Location manager to get longtiude and latitude
@property (strong, nonatomic) CLLocationManager *rcLocationManager;
// Current location
@property CLLocation *currentGPSLocation;


typedef enum FoodTypesEnum {
    FOODTYPE_ALL = -1,
    RICE = 0,
    NOODLES = 1,
    ICECREAM = 2,
    DESSERT = 3,
    DRINK = 4,
    SOUP = 5,
    STEAK = 6,
    WAFFLE = 7,
    FRIED_EGG = 8,
    SALAD = 9,
    TACO = 10,
    BURGER = 11
} FoodTypes;



/* =========================== Usage Description ===========================
 This is a singleton module for connection to Azure mobile app services
 1. User should call getUniqueNumber_WithUsername to obtain a unique sequence number that will be used as image name for blob storage. The index will match up to an item in blob
 
 2. Call insert method to store data into internal dictionary first
      The table should store 4 kinds of data:
      a. restaurant name
      b. foodType
      c. sequenceNumber
      d. username
 3. Store data into rcMainDataTable, call function InsertDataIntoMainDataTable to upload stored dictionary data to Azure
 ============================================================    */


// ========= Data upload / download =========
// Two data tables:
// 1. rcMainDataTable : Contain all data related information
// 2. rcUserDataInfo : Contain all user related information
- (void) InsertDataIntoMainDataTable:(void(^)(NSNumber *rcCompleteFlag))rcCallback;
// Request data from table with , return a NSArray of dictionaries in callback
- (void) getDatafromUser:(NSString*)rcUsername FoodType:(FoodTypes)foodType Callback:(void(^)(NSArray *callbackItem)) returnCallback;
// Request data in rcUserDataInfo table
- (void) verifyUsername:(NSString*)rcUsername Callback:(void(^)(BOOL callbackItem))returnCallback;
- (void) verifyUserAccount:(NSString*)rcUsername Password:(NSString*)password Callback:(void(^)(BOOL callbackItem))returnCallback;
// =============================================

// ======= Insert Data Functions  ==========
- (void) insertSequenceNumber:(NSString*)sequenceNumber username:(NSString*)username;
- (void) insertTypeData:(FoodTypes)foodType;
- (void) insertResNameData:(NSString*)resName;
- (void) InsertIntoUserTableWithUsername:(NSString*)username Password:(NSString*)password Callback:(void(^)(NSDictionary* returnedDictionary))returnCallback;
// Request location data
- (void) requestLocationData;

// =============================================

// ======= Sequence Number Functions  ==========
// getUniqueID_WithCallback will make the request and return the unique serial number in a NSArray* to the callback function. Caller will have to create a block to catch the return value
- (void) getUniqueNumber_WithUsername:(NSString*)rcUsername  Callback:(void(^)(NSDictionary *callbackItem)) returnCallback;
// Update an entry into the table, retrieve the information first and then update that entry//
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict Callback:(void(^)(NSNumber* completeFlag)) returnCallback;
// ==============================================

// ======= Delete Functions  ==========
// Delete an entry from main data table. This function is created to revert the upload of a new entry due to failed sequence number update or failed image upload.
- (void) deleteEntry:(NSDictionary*)deleteEntry;
// ==============================================

// ======= Utility Functions =========
- (NSDictionary*) getCurrentDictionaryData;
- (NSString*) getCurrentRestaurantName;
- (NSString*) getCurrentSelectedFoodTypeName;

// ======= Food Type Data Processing ========
- (NSUInteger) getTotalNumberOfType;
- (NSString*) getFoodIconNameWithEnum:(int)enumFood;
- (NSString*) getFoodIconNameWithIndex:(NSInteger)index;
- (NSNumber*) getFoodTypeEnumWithIndex:(NSInteger)index;
- (NSString*) getFoodTypeNameWithIndex:(NSInteger)index;
- (NSString*) getFoodTypeNameWithEnum:(int)enumFood;


// ======================================
// Override init to initialize client
- (id) init;

+ (instancetype) sharedDataTable;
@end
