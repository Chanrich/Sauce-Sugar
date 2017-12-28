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
    // Store references to table datas
    MSTable *MainData_MSTable;
    MSTable *UserData_MSTable;
    // Mutable array to store food data including:
    // 1. Icon Name
    // 2. Food type
    // 3. Food Enum
    NSMutableDictionary *foodData;
    // An Array to translate from 0 index to food Enum index
    NSMutableArray *foodIndexToEnum;
    // Store pre-loaded user data table returned dictionary
    NSMutableDictionary *preloadedUserDataTable;
    // Store inserted food type
    NSNumber *currentSelectedFoodType;
    // Store inserted restaurant name
    NSString *currentRestaurantName;
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
        // Initialize food data array
        foodData = [[NSMutableDictionary alloc] init];
        foodIndexToEnum = [[NSMutableArray alloc] init];
        // ====== GPS ======
        // GPS Location mangager
        self.rcLocationManager = [[CLLocationManager alloc] init];
        // Set initial location to nil
        self.currentGPSLocation = nil;
        // =================
        // Initialize all data table
        MainData_MSTable = [self.client tableWithName:AZURE_MAIN_DATA_TABLE_NAME];
        UserData_MSTable = [self.client tableWithName:AZURE_USER_DATA_TABLE_NAME];
        // Initialize food data array with icon names and enum number
        [self insertNewFoodTypeWithIcon:@"info" atKey:FOODTYPE_ALL TypeName:@"All"];
        [self insertNewFoodTypeWithIcon:@"rice" atKey:RICE TypeName:@"Rice"];
        [self insertNewFoodTypeWithIcon:@"noodles" atKey:NOODLES TypeName:@"Noodles"];
        [self insertNewFoodTypeWithIcon:@"ice-cream" atKey:ICECREAM TypeName:@"Ice Creams"];
        [self insertNewFoodTypeWithIcon:@"doughnut" atKey:DESSERT TypeName:@"Doughnut"];
        [self insertNewFoodTypeWithIcon:@"water" atKey:DRINK TypeName:@"Drinks"];
        [self insertNewFoodTypeWithIcon:@"soup" atKey:SOUP TypeName:@"Soup"];
        [self insertNewFoodTypeWithIcon:@"steak" atKey:STEAK TypeName:@"Streak"];
        [self insertNewFoodTypeWithIcon:@"waffle" atKey:WAFFLE TypeName:@"Waffle"];
        [self insertNewFoodTypeWithIcon:@"fried-egg" atKey:FRIED_EGG TypeName:@"Eggs"];
        [self insertNewFoodTypeWithIcon:@"salad" atKey:SALAD TypeName:@"Salad"];
        [self insertNewFoodTypeWithIcon:@"taco" atKey:TACO TypeName:@"Taco"];
        [self insertNewFoodTypeWithIcon:@"burger" atKey:BURGER TypeName:@"Burger"];
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
- (void) InsertIntoUserTableWithUsername:(NSString*)username Password:(NSString*)password Callback:(void(^)(NSDictionary* returnedDictionary))returnCallback{
    // Prepare object for integer since NSDictioanry only accepts object
    NSNumber *seqNum = [NSNumber numberWithInt:1];
    
    // Clean dictionary
    [self.rcDataDictionaryForUserTable removeAllObjects];
    
    // Insert data to dictionary object
    [self.rcDataDictionaryForUserTable setObject:username forKey:AZURE_USER_TABLE_USERNAME];
    [self.rcDataDictionaryForUserTable setObject:seqNum forKey:AZURE_USER_TABLE_SEQUENCE];
    [self.rcDataDictionaryForUserTable setObject:password forKey:AZURE_USER_TABLE_PASSWORD];
    
    // Insert data into table
    [UserData_MSTable insert:self.rcDataDictionaryForUserTable completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
            returnCallback(nil);
        } else {
            NSLog(@"User %@ added", username);
            returnCallback(InsertedItem);
        }
    }];
}

#pragma mark Update
// Update an entry into the table, retrieve the information first and then update that entry
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict Callback:(void(^)(NSNumber* completeFlag)) returnCallback{
    // Increment the retrieved sequence number by 1
    NSNumber *newValue = [NSNumber numberWithInt:(int)[[myDict objectForKey:AZURE_USER_TABLE_SEQUENCE] intValue] + 1];
    NSLog(@"Incrementing Sequence number to %@", newValue);
    // Update the newly incremented number into the key
    [myDict setValue:newValue forKey:AZURE_USER_TABLE_SEQUENCE];
    
    // Grab sequence from dictionary
    NSNumber *nsNumSeq = [myDict objectForKey:AZURE_USER_TABLE_SEQUENCE];
    NSLog(@"New value extracted from myDict :%@", nsNumSeq);
    // Push it to Azure table
    [UserData_MSTable update:myDict completion:^(NSDictionary * _Nullable item, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error when updating dictionary");
            NSLog(@"%@", [error localizedDescription]);
            returnCallback(@NO);
        } else {
            NSLog(@"Successfully updated dictionary");
            returnCallback(@YES);
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
    NSLog(@"<getUniqueNumber_WithUsername>: Requesting sequence number from server");
    
    // Data filter
    NSPredicate *dataFilter;
    
    // Filter for username
    dataFilter = [NSPredicate predicateWithFormat:@"USERNAME == %@", rcUsername];
    
    // Prepare a MSQuery object on the main user data table
    NSLog(@"Query filter: %@", [dataFilter predicateFormat]);
    MSQuery *rcQuery = [UserData_MSTable queryWithPredicate:dataFilter];
    
    // Query database with dataFilter
    [rcQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"Cannot get unique sequence number from server... Abort!");
            returnCallback(nil);
        } else { // No error is returned from readWithCompletion
            NSLog(@"Number of results returned from rcQuery readWithCompletion:%lu", (unsigned long)[result.items count]);
            
            // Only return valid data back when just 1 entry is found.
            if ([result.items count] == 1){
                // Store the sequence number into local copy
                NSDictionary *returnedData = [result.items objectAtIndex:0];
                // Store the returned dictionary to a local copy
                preloadedUserDataTable = [[NSMutableDictionary alloc] initWithDictionary:returnedData];
                
                // Print received dictionary out
                NSLog(@"Print out selected user info:\n%@", preloadedUserDataTable);
                
                // Pass dictionary data back to caller function
                returnCallback(preloadedUserDataTable);
            } else if ([result.items count] > 1){
                // More than one entry is downloaded, something must be wrong as there shouldn't have two exact same user
                NSLog(@"More than one user info is received, returning nil to callback");
                returnCallback(nil);
            } else if ([result.items count] == 0){
                // No user is found
                // If current user is guest, create a guest account
                if ([rcUsername isEqualToString:AZURE_USER_GUEST]){
                    NSLog(@"Creating Guest account");
                    // Create a guest user account with sequence number 1
                    [self InsertIntoUserTableWithUsername:AZURE_USER_GUEST Password:AZURE_USER_GUEST_PASSWORD Callback:^(NSDictionary* returnedDictionary) {
                        if (returnedDictionary != nil){
                            NSLog(@"Guest account is created");
                            NSMutableDictionary *newMutableTempDictionary = [[NSMutableDictionary alloc] initWithDictionary:returnedDictionary];
                            preloadedUserDataTable = newMutableTempDictionary;
                            
                            // Print received dictionary
                            NSLog(@"Print out newly created guest info:\n%@", preloadedUserDataTable);
                            
                            // Return valid data dictionary back to caller
                            returnCallback(newMutableTempDictionary);
                        } else {
                            // returnedDictionary is nil then error occured
                            NSLog(@"Creating guest account failed");
                            returnCallback(nil);
                        }
                    
                    }];
                } else {
                    // If username is not guest, then it doesn't exist
                    NSLog(@"No data received and username is not guest, returning nil");
                    returnCallback(nil);
                }
            } else {
                // Error
                NSLog(@"No user is selected, task aborting");
                returnCallback(nil);
            }
        }
    }]; // End of query read
    
}

// Make a query request for a single user, returns a NSArray of dictionaries in callback
- (void) getDatafromUser:(NSString*)rcUsername FoodType:(FoodTypes)foodType Callback:(void(^)(NSArray *callbackItem)) returnCallback{
    NSLog(@"<getDatafromUser>");
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
    NSLog(@"Creating food type filter");
    if (foodType == FOODTYPE_ALL){
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
    NSLog(@"Setting GPS Predicates");
    if (self.currentGPSLocation != nil){
        // Need a function to return lower and upper bounds in a array for long/lat, param: current position object
        NSArray *latitudeBounds = [self returnLatitudeBoundsWithCenterLocation:self.currentGPSLocation searchDegree:0.8];
        NSArray *longitudeBounds = [self returnLongitudeBoundsWithCenterLocation:self.currentGPSLocation searchDegree:0.8];
        dataFilter_latitude = [NSPredicate predicateWithFormat:@"latitude BETWEEN %@", latitudeBounds];
        dataFilter_longitude = [NSPredicate predicateWithFormat:@"longitude BETWEEN %@", longitudeBounds];
    }
    
    // AND all data filters together
    finalAndPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[dataFilter, dataFilter2, dataFilter_latitude, dataFilter_longitude]];
    //finalAndPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[dataFilter, dataFilter2]];
    NSLog(@"finalAndPredicate:%@\n", [finalAndPredicate predicateFormat]);
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcDataTableQuery = [MainData_MSTable queryWithPredicate:finalAndPredicate];
    
    // Perform a read on the MSquery object, the read will return maximum 50 entries
    [rcDataTableQuery readWithCompletion:^(MSQueryResult * _Nullable result, NSError * _Nullable error) {
        if (error){
            NSLog(@"<getDatafromUser> Data download error!");
            NSLog(@"%@", [error localizedDescription]);
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
                NSLog(@"<getDatafromUser> No Data is selected, task aborting");
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
            NSLog(@"<verifyUsername> Data download error!");
            // return a NO
            returnCallback(FALSE);
        } else {
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
            NSLog(@"<verifyUserAccount> Data download error!");
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
    // Store restaurant name
    currentRestaurantName = resName;
}

- (void)insertTypeData:(FoodTypes)foodType {
    // Convert foodType to NSNumber with @() and store it into mutable dictionary
    [self.rcDataDictionary setObject:@(foodType) forKey:AZURE_DATA_TABLE_FOODTYPE];
    // Store selected food type
    currentSelectedFoodType = @(foodType);
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
    
    // Location data should be stored as double to Azure server
    NSNumber *dLong = [NSNumber numberWithDouble:myLocation.coordinate.longitude];
    NSNumber *dLat = [NSNumber numberWithDouble:myLocation.coordinate.latitude];

    
    // Update data entries in dictionary
    [self.rcDataDictionary setObject:dLong forKey:GPS_LONGITUDE];
    [self.rcDataDictionary setObject:dLat forKey:GPS_LATITUDE];
    
    NSNumber *nsNumLong = [self.rcDataDictionary objectForKey:GPS_LONGITUDE];
    NSNumber *nsNumLat = [self.rcDataDictionary objectForKey:GPS_LATITUDE];
    // Debug
    NSLog(@"Set GPS Data to:\nLong:%@\tLat:%@", nsNumLong, nsNumLat);
    
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
- (NSArray*) returnLatitudeBoundsWithCenterLocation:(CLLocation*)center searchDegree:(double)degree{
    // The filter should use longitude and latitude
    // Each degree of latitude is approximately 69 miles
    // A degree of longitude is widest at the equator at 69.172 miles (111.321) and gradually shrinks to zero at the poles.
    // Latitude:
    // ABS(y) < 0.8 (approx.55 miles)
    // Longitudes:
    // ABS(x) < 0.8 (approx.55 miles at equator and gradually to 0 at poles)
    double currentLatitude = center.coordinate.latitude;
    NSNumber *lowerBound = [NSNumber numberWithDouble:(double)currentLatitude - (double)degree];
    NSNumber *upperBound = [NSNumber numberWithDouble:(double)currentLatitude + (double)degree];
    NSArray *bounds = @[lowerBound, upperBound];
    NSLog(@"Created: Latitude Bounds: %@", bounds);
    return bounds;
    
}

// Returns a NSArray with lower and upper bounds in longitude which will serve as longitude search area for items in database
- (NSArray*) returnLongitudeBoundsWithCenterLocation:(CLLocation*)center searchDegree:(double)degree{
    // The filter should use longitude and latitude
    // Each degree of latitude is approximately 69 miles
    // A degree of longitude is widest at the equator at 69.172 miles (111.321) and gradually shrinks to zero at the poles.
    // Latitude:
    // ABS(y) < 0.8 (approx.55 miles)
    // Longitudes:
    // ABS(x) < 0.8 (approx.55 miles at equator and gradually to 0 at poles)
    double currentLongitude = center.coordinate.longitude;
    NSNumber *lowerBound = [NSNumber numberWithDouble:(double)currentLongitude - (double)degree];
    NSNumber *upperBound = [NSNumber numberWithDouble:(double)currentLongitude + (double)degree];
    NSArray *bounds = @[lowerBound,upperBound];
    NSLog(@"Created: Latitude Bounds: %@", bounds);
    return bounds;
    
}

#pragma mark - Utility Functions

- (NSDictionary*) getCurrentDictionaryData{
    return self.rcDataDictionary;
}

#pragma mark - Food Type Data Processing
- (NSUInteger) getTotalNumberOfType{
    return [foodData count];
}

// This function should store data into a dictionary mapped by its Enum defined at 'FoodTypesEnum' and then insert it into foodData array that stores every food types information
- (void) insertNewFoodTypeWithIcon:(NSString*)icon atKey:(int)enumFood TypeName:(NSString*)typeName{
    static NSUInteger arrayIndex = 0;
    NSDictionary *tempStorage = @{FOOD_DATA_KEY_TYPE_NAME: typeName,
                                  FOOD_DATA_KEY_ICON: icon,
                                  FOOD_DATA_KEY_ENUM: [NSNumber numberWithInt:enumFood]
                                  };
    // Add object to the storage array
    [foodData setObject:tempStorage forKey:[NSNumber numberWithInt:enumFood]];
    
    // Create an index array to translate normal 0-index (starting from 0) to enum index
    [foodIndexToEnum insertObject:[NSNumber numberWithInt:enumFood] atIndex:arrayIndex];
    arrayIndex++;
}

// This function will return name of the icon file associated with the enum type
- (NSString*) getFoodIconNameWithEnum:(int)enumFood{
    NSDictionary *fData = [foodData objectForKey:[NSNumber numberWithInt:enumFood]];
    return [fData objectForKey:FOOD_DATA_KEY_ICON];
}

// This function will return the name of the food type from its enum as index
- (NSString*) getFoodTypeNameWithEnum:(int)enumFood{
    NSDictionary *fData = [foodData objectForKey:@(enumFood)];
    return [fData objectForKey:FOOD_DATA_KEY_TYPE_NAME];
}

// This function will return name of the icon file associated from 0-index
- (NSString*) getFoodIconNameWithIndex:(NSInteger)index{
    NSNumber* Enum = [foodIndexToEnum objectAtIndex:index];
    NSDictionary *fData = [foodData objectForKey:Enum];
    return [fData objectForKey:FOOD_DATA_KEY_ICON];
}

// This function will return the enum of food type from 0-index
- (NSNumber*) getFoodTypeEnumWithIndex:(NSInteger)index{
    NSNumber* Enum = [foodIndexToEnum objectAtIndex:index];
    return Enum;
}

// This function will return the enum of food type from 0-index
- (NSString*) getFoodTypeNameWithIndex:(NSInteger)index{
    NSNumber* Enum = [foodIndexToEnum objectAtIndex:index];
    NSDictionary *fData = [foodData objectForKey:Enum];
    return [fData objectForKey:FOOD_DATA_KEY_TYPE_NAME];
}

// This function will return name of the food type that is currently selected (being inserted into database)
- (NSString*) getCurrentSelectedFoodTypeName{
    return [self getFoodTypeNameWithEnum:[currentSelectedFoodType intValue]];
}

- (NSString*) getCurrentRestaurantName{
    return currentRestaurantName;
}


@end
