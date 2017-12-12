//
//  rcAzureDataTable.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/21/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "rcAzureDataTable.h"
#import "GlobalNames.h"
#define MAX_REQUIREMENT 4
#define AZURE_USER_DATA_TABLE_NAME @"rcUserDataInfo"
#define AZURE_MAIN_DATA_TABLE_NAME @"rcMainDataTable"
@implementation rcAzureDataTable {
    // Private variables
    NSNumber *rcCurrentSequenceNumber;
    // Store references to table datas
    MSTable *MainData_MSTable;
    MSTable *UserData_MSTable;
}

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
        // Initialize mutable dictionary to store data entries
        self.rcDataDictionary = [[NSMutableDictionary alloc] init];
        self.rcDataDictionaryForUserTable = [[NSMutableDictionary alloc] init];
        // GPS Location mangager
        self.rcLocationManager = [[CLLocationManager alloc] init];
        // Initialized sequence number to invalid
        rcCurrentSequenceNumber = @(-1);
        // Initialize all data table
        MainData_MSTable = [self.client tableWithName:AZURE_MAIN_DATA_TABLE_NAME];;
        UserData_MSTable = [self.client tableWithName:AZURE_USER_DATA_TABLE_NAME];
    }
    return self;
}

#pragma mark - Upload to Azure Server

- (void) InsertDataIntoMainDataTable:(void(^)(NSNumber *rcCompleteFlag))rcCallback{
    // Insert data into table
    [MainData_MSTable insert:self.rcDataDictionary completion:^(NSDictionary *InsertedItem, NSError *error) {
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

#pragma mark User Table

// Create a new user and set its seqNum to 1
- (void) InsertIntoUserTableWithUsername:(NSString*)username Password:(NSString*)password Callback:(void(^)(NSNumber* completeFlag))returnCallback{
    // Prepare object for integer since NSDictioanry only accepts object
    NSNumber *seqNum = [NSNumber numberWithInt:1];
    
    // Insert data to dictionary object
    [self.rcDataDictionaryForUserTable setObject:username forKey:AZURE_USER_TABLE_USERNAME];
    [self.rcDataDictionaryForUserTable setObject:seqNum forKey:AZURE_USER_TABLE_SEQUENCE];
    [self.rcDataDictionaryForUserTable setObject:password forKey:AZURE_USER_TABLE_PASSWORD];
    
    // Insert data into table
    [UserData_MSTable insert:self.rcDataDictionaryForUserTable completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
            returnCallback(@NO);
        } else {
            NSLog(@"User %@ added", username);
            returnCallback(@YES);
        }
    }];
}

#pragma mark Update
// Update an entry into the table, retrieve the information first and then update that entry
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict Callback:(void(^)(NSNumber* completeFlag)) returnCallback{
    // Increment the retrieved sequence number by 1
    NSNumber *newValue = [NSNumber numberWithInt:[[myDict objectForKey:AZURE_USER_TABLE_SEQUENCE] intValue] + 1];
    
    // Update the newly incremented number into the key
    [myDict setValue:newValue forKey:AZURE_USER_TABLE_SEQUENCE];
    
    // Push it to Azure table
    [UserData_MSTable update:myDict completion:^(NSDictionary * _Nullable item, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error when updating dictionary");
            returnCallback(@NO);
        } else {
            NSLog(@"Successfully updated dictionary");
            returnCallback(@YES);
            
            // Save the new value to local copy
            rcCurrentSequenceNumber = newValue;
            NSLog(@"Local copy of sequence number update to: %d", [newValue intValue]);
        }
    }];
}

#pragma mark Delete Data

- (void) deleteEntry:(NSDictionary*)deleteEntry{
    // Call the delete on main data table
    [MainData_MSTable delete:deleteEntry completion:^(id  _Nullable itemId, NSError * _Nullable error) {
        // Do nothing if the delete failed or succeed. Program should handle the failed case.
        NSLog(@"Delete completed");
    }];
}

#pragma mark - Download data from server

// getUniqueID_WithCallback will make the request and return the unique serial number in a NSArray* to the callback function. Caller will have to create a block to catch the return value
- (void) getUniqueNumber_WithUsername:(NSString*)rcUsername  Callback:(void(^)(NSDictionary *callbackItem)) returnCallback {
    // Download sequence number from server only if sequence number is invalid, meaning never been downloaded before.
    if (![rcCurrentSequenceNumber isEqualToNumber:@(-1)]){
        // If sequence number is valid, get it from local copy
        NSLog(@"Returning sequence number from local copy");
        // Copy the style that data were returned from server, the returning NSNumber should be send to the callback function in a dictionary at key defined at @AZURE_USER_TABLE_SEQUENCE
        NSDictionary *tempStorage = @{AZURE_USER_TABLE_SEQUENCE:rcCurrentSequenceNumber};
        returnCallback(tempStorage);
    } else {
        NSLog(@"Requesting sequence number from server");
        
        // Data filter
        NSPredicate *dataFilter;
        
        // Filter for username
        dataFilter = [NSPredicate predicateWithFormat:@"USERNAME == %@", rcUsername];
        
        // Prepare a MSQuery object with filter dataFilter
        NSLog(@"Query filter: %@", [dataFilter predicateFormat]);
        MSQuery *rcQuery = [UserData_MSTable queryWithPredicate:dataFilter];
        
        // Query database with dataFilter
        [rcQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
            if (error){
                NSLog(@"Cannot get unique sequence number from server... Abort!");
                returnCallback(nil);
            } else {
                NSNumber *itemCount = [NSNumber numberWithUnsignedLong:[result.items count]];
                NSLog(@"Entries returned from rcQuery readWithCompletion:%@", itemCount);
                if ([result.items count] == 1){
                    // Store the sequence number into local copy
                    NSDictionary *returnedData = [result.items objectAtIndex:0];
                    rcCurrentSequenceNumber = [returnedData objectForKey:AZURE_USER_TABLE_SEQUENCE];
                    
                    // Pass the NSDictionary* stored in NSArray back to callback function
                    returnCallback([result.items objectAtIndex:0]);
                } else if ([result.items count] > 1){
                    // More than one entry is downloaded, something must be wrong as there shouldn't have two exact same user
                    NSLog(@"More than one user is selected, task aborting");
                } else if ([result.items count] == 0){
                    // No user is found
                    // If current user is guest, create a guest account and re-run
                    if ([rcUsername isEqualToString:AZURE_USER_GUEST]){
                        // Create a guest user account with sequence number 1 and return a pre-built dictionary containing sequence number 1
                        [self InsertIntoUserTableWithUsername:AZURE_USER_GUEST Password:AZURE_USER_GUEST_PASSWORD Callback:^(NSNumber *completeFlag) {
                            if ([completeFlag isEqual:@YES]){
                                NSLog(@"Guest account is created");
                                // Return sequence number 1 in a dictionary
                                NSNumber *numberWithOne = [NSNumber numberWithInt:1];
                                NSDictionary *tempReturnDic = @{AZURE_USER_TABLE_SEQUENCE : numberWithOne};
                                returnCallback(tempReturnDic);
                            } else {
                                // Return nil if error occured
                                NSLog(@"Creating guest account failed");
                                returnCallback(nil);
                            }
                        
                        }];
                    } else {
                        // If username is not guest, then it doesn't exist
                        NSLog(@"No user is selected, task aborting");
                        returnCallback(nil);
                    }
                } else {
                    // Error
                    NSLog(@"No user is selected, task aborting");
                    returnCallback(nil);
                }
            }
        }]; // End of query read
    } // End of if sequence number is invalid
    
}

// Make a query request for a single user, returns a NSArray of dictionaries in callback
- (void) getDatafromUser:(NSString*)rcUsername FoodType:(FoodTypes)foodType Callback:(void(^)(NSArray *callbackItem)) returnCallback{
    // Create a filter for
    // 1. Username
    // 2. Foodtype
    NSPredicate *dataFilter;
    NSPredicate *dataFilter2;
    NSPredicate *dataFilter_latitude;
    NSPredicate *dataFilter_longitude;
    NSPredicate *finalAndPredicate;
    
    // Filter for username
    if (rcUsername == nil){
        // Return all user data
        dataFilter = [NSPredicate predicateWithFormat:@"USERNAME != NULL"];
    } else {
        // Return individual user data
        dataFilter = [NSPredicate predicateWithFormat:@"USERNAME == %@", rcUsername];
    }
    
    // Filter for food type
    if (foodType == -1){
        // Return all types of food
        dataFilter2 = [NSPredicate predicateWithFormat:@"foodType != NULL"];
    } else {
        // Select one foodType
        dataFilter2 = [NSPredicate predicateWithFormat:@"foodType == %d", foodType];
    }

    // The filter should use longitude and latitude
    // Each degree of latitude is approximately 69 miles
    // A degree of longitude is widest at the equator at 69.172 miles (111.321) and gradually shrinks to zero at the poles.
    // Latitude:
    // ABS(y) < 0.8 (approx.55 miles)
    // Longitudes:
    // ABS(x) < 0.8 (approx.55 miles at equator and gradually to 0 at poles)
    if (self.currentGPSLocation != nil){
        // Need a function to return lower and upper bounds in a array for long/lat, param: current position object
        NSArray *latitudeBounds = [self returnLatitudeBoundsWithCenterLocation:self.currentGPSLocation searchDegree:0.8];
        NSArray *longitudeBounds = [self returnLongitudeBoundsWithCenterLocation:self.currentGPSLocation searchDegree:0.8];
        dataFilter_latitude = [NSPredicate predicateWithFormat:@"latitude BETWEEN %@", latitudeBounds];
        dataFilter_longitude = [NSPredicate predicateWithFormat:@"longitude BETWEEN %@", longitudeBounds];
    }
    
    // AND all data filters together
    finalAndPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[dataFilter, dataFilter2, dataFilter_latitude, dataFilter_longitude]];
    
    NSLog(@"finalAndPredicate:%@\n", [finalAndPredicate predicateFormat]);
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcQuery = [MainData_MSTable queryWithPredicate:finalAndPredicate];
    
    // Perform a read on the MSquery object, the read will return maximum 50 entries
    [rcQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Data download error!");
            // Pass a null back to callback, callback should check this for error
            returnCallback(nil);
        } else {
            // Debug
            NSNumber *temp = [NSNumber numberWithUnsignedLong:[result.items count]];
            NSLog(@"Count of result.item array: %@", temp);
            
            if ([result.items count] > 0){
                NSLog(@"Returning data to callback function");
                // Pass the NSDictionary* back to callback function
                returnCallback(result.items);
            } else {
                // Error
                NSLog(@"No user is selected, task aborting");
                returnCallback(nil);
            }
        }
    }];

}

#pragma mark Verify Data
// If username is already existing found in the database, raise a flag to the callback method.
// This method is used to check username before creating a new user
- (void)verifyUsername:(NSString *)rcUsername Callback:(void(^)(BOOL callbackItem))returnCallback{
    // Create a filter for
    // 1. Username
    NSPredicate *dataFilter = [NSPredicate predicateWithFormat:
                               @"USERNAME=%@", rcUsername];
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcQuery = [UserData_MSTable queryWithPredicate:dataFilter];
    
    // Perform a read on the MSquery object, the read will return maximum 50 entries
    [rcQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Data download error!");
            // return a NO
            returnCallback(FALSE);
        } else {
            // Debug
            NSNumber *temp = [NSNumber numberWithUnsignedLong:[result.items count]];
            NSLog(@"Count of result.item array: %@", temp);
            
            if ([result.items count] == 0){
                NSLog(@"No repeated user is found. Username valid!");
                returnCallback(TRUE);
            } else {
                NSLog(@"Multiple user with same name is found. Username invalid");
                returnCallback(FALSE);
            }
        }
    }];;
}

// Create a filter for username and password from parameters. If any data is retrieved with filter, the user account is verified. Raise a flag to the callback method
- (void)verifyUserAccount:(NSString *)rcUsername Password:(NSString *)password Callback:(void (^)(BOOL))returnCallback {
    // Create a filter for
    // 1. Username
    // 2. Password
    NSPredicate *dataFilter = [NSPredicate predicateWithFormat:
                               @"USERNAME=%@", rcUsername];
    NSPredicate *dataFilter2 = [NSPredicate predicateWithFormat:
                               @"PASSWORD=%@", password];
    // Combine two predicate with and
    NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[dataFilter, dataFilter2]];
    
    NSLog(@"finalAndPredicate:%@\n", [finalPredicate predicateFormat]);
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcQuery = [UserData_MSTable queryWithPredicate:finalPredicate];
    
    // Perform a read on the MSquery object, the read will return maximum 50 entries
    [rcQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Data download error!");
            // return a NO
            returnCallback(FALSE);
        } else {
            // Debug
            NSNumber *temp = [NSNumber numberWithUnsignedLong:[result.items count]];
            NSLog(@"Number of entries found with this username and password: %@", temp);
            
            if ([result.items count] == 1){
                NSLog(@"Found a matching account!");
                returnCallback(TRUE);
            } else {
                NSLog(@"Multiple user with same name is found. Username invalid");
                returnCallback(FALSE);
            }
        }
    }];;
    
}

- (void) invalidateSequenceNumber{
    rcCurrentSequenceNumber = @(-1);
}


#pragma mark - Insert Data

// Collect data into NSDictionary object.
// NSDictioanry format: NSDictionary *dict = @{ key : value, key2 : value2}
//    Object descriptions:
//    1.    Name of the restaurant (if not yet exist, option to add restaurant appears)
//    2.    Username
//    3.    Photo

- (void)insertResNameData:(NSString *)resName {
    // Insert restaurant name into mutable dictionary
    [self.rcDataDictionary setObject:resName forKey:AZURE_DATA_TABLE_RESTAURANT_NAME];
}

- (void)insertTypeData:(FoodTypes)foodType {
    // Convert foodType to NSNumber with @() and store it into mutable dictionary
    [self.rcDataDictionary setObject:@(foodType) forKey:AZURE_DATA_TABLE_FOODTYPE];
}

- (void)insertSequenceNumber:(NSString *)sequenceNumber username:(NSString *)username { 
    // Insert username and sequence number (image reference) into mutable dictionary
    [self.rcDataDictionary setObject:username forKey:AZURE_DATA_TABLE_USERNAME];
    [self.rcDataDictionary setObject:sequenceNumber forKey:AZURE_DATA_TABLE_SEQUENCE];
}

#pragma mark - GPS Location Functions
// Send a request for location authorization and start updating location data
- (void)requestLocationData {
    self.rcLocationManager.delegate = self;
    self.rcLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // Initialize data entries in dictionary
    [self.rcDataDictionary setObject:@"na" forKey:GPS_LONGITUDE];
    [self.rcDataDictionary setObject:@"na" forKey:GPS_LATITUDE];
    // Start updating, it will call the delegate function when data is returned
    if ([CLLocationManager locationServicesEnabled] == YES){
        NSLog(@"Requesting location data");
        [self.rcLocationManager requestWhenInUseAuthorization];
        [self.rcLocationManager startUpdatingLocation];
    } else {
        NSLog(@"Location service is not available");
    }
}

// Save location data into dictionary and stop location data update
- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    // Get lastest object in locations array
    CLLocation *myLocation = [locations lastObject];
    
    // Save a copy of the current location for search function to locate nearest places
    self.currentGPSLocation = myLocation;
    
    // Convert location data from double to string
    NSString *longitudeToString = [NSString stringWithFormat:@"%f", myLocation.coordinate.longitude];
    NSString *latitudeToString = [NSString stringWithFormat:@"%f", myLocation.coordinate.latitude];
    // Debug
    NSLog(@"Long:%@\tLat:%@", longitudeToString, latitudeToString);
    
    // Update data entries in dictionary
    [self.rcDataDictionary setObject:longitudeToString forKey:GPS_LONGITUDE];
    [self.rcDataDictionary setObject:latitudeToString forKey:GPS_LATITUDE];
    
    // Stop location update servie to preserve battery
    [self.rcLocationManager stopUpdatingLocation];
}

// If error occured while requesting for location data, display error message
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location service failed with error:\n%@", [error localizedDescription] );
}

// Show location update authorizatino status in debug window
- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    NSString *statusTranslate;
    switch (status) {
        case 0:
            statusTranslate = @"kCLAuthorizationStatusNotDetermined";
            break;
        case 1:
            statusTranslate = @"kCLAuthorizationStatusRestricted";
            break;
        case 2:
            statusTranslate = @"kCLAuthorizationStatusDenied";
            break;
        case 3:
            statusTranslate = @"kCLAuthorizationStatusAuthorizedAlways";
            break;
        case 4:
            statusTranslate = @"kCLAuthorizationStatusAuthorizedWhenInUse";
            break;
        case 5:
            statusTranslate = @"kCLAuthorizationStatusAuthorized";
            break;
        default:
            break;
    }
    NSLog(@"Location authorization status updated to %@", statusTranslate);
}

#pragma mark Return Location
// Returns a NSArray with lower and upper bounds in latitude which will serve as latitude search area for items in database
- (NSArray*) returnLatitudeBoundsWithCenterLocation:(CLLocation*)center searchDegree:(float)degree{
    // The filter should use longitude and latitude
    // Each degree of latitude is approximately 69 miles
    // A degree of longitude is widest at the equator at 69.172 miles (111.321) and gradually shrinks to zero at the poles.
    // Latitude:
    // ABS(y) < 0.8 (approx.55 miles)
    // Longitudes:
    // ABS(x) < 0.8 (approx.55 miles at equator and gradually to 0 at poles)
    float currentLatitude = center.coordinate.latitude;
    NSArray *bounds = @[@(currentLatitude - degree), @(currentLatitude + degree)];
    NSLog(@"Created: Latitude Bounds: %@", bounds);
    return bounds;
    
}

// Returns a NSArray with lower and upper bounds in longitude which will serve as longitude search area for items in database
- (NSArray*) returnLongitudeBoundsWithCenterLocation:(CLLocation*)center searchDegree:(float)degree{
    // The filter should use longitude and latitude
    // Each degree of latitude is approximately 69 miles
    // A degree of longitude is widest at the equator at 69.172 miles (111.321) and gradually shrinks to zero at the poles.
    // Latitude:
    // ABS(y) < 0.8 (approx.55 miles)
    // Longitudes:
    // ABS(x) < 0.8 (approx.55 miles at equator and gradually to 0 at poles)
    float currentLongitude = center.coordinate.longitude;
    NSArray *bounds = @[@(currentLongitude - degree), @(currentLongitude + degree)];
    NSLog(@"Created: Latitude Bounds: %@", bounds);
    return bounds;
    
}

#pragma mark - Utility Functions

- (NSDictionary*) getCurrentDictionaryData{
    return self.rcDataDictionary;
}

// Parse the food type enum and return a string describing the type
- (NSString*) parseFoodType:(FoodTypes)enum_type{
    NSString *parsedText;
    switch (enum_type) {
        case FOODTYPE_ALL:
            parsedText = @"All";
            break;
        case RICE:
            parsedText = @"Rice";
            break;
        case NOODLES:
            parsedText = @"Noodles";
            break;
        case ICECREAM:
            parsedText = @"Ice Cream";
            break;
        case DESSERT:
            parsedText = @"Dessert";
            break;
        case DRINK:
            parsedText = @"Drink";
            break;
        default:
            parsedText = @"FoodType Invalid";
            break;
    }
    return parsedText;
}

@end
