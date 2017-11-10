//
//  rcAzureDataTable.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 9/21/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "rcAzureDataTable.h"
#define MAX_REQUIREMENT 4
#define GPS_LONGITUDE @"longitude"
#define GPS_LATITUDE @"latitude"
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
        // Initialize mutable dictionary to store data entries
        self.rcDataDictionary = [[NSMutableDictionary alloc] init];
        self.rcDataDictionaryForUserTable = [[NSMutableDictionary alloc] init];
        // GPS Location mangager
        self.rcLocationManager = [[CLLocationManager alloc] init];
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

// Create a new user and set its seqNum
- (void) InsertIntoTableWithUsername:(NSString*)username{
    // Prepare object for integer since NSDictioanry only accepts object
    NSNumber *seqNum = [NSNumber numberWithInt:1];
    
    // Insert data
    [self.rcDataDictionaryForUserTable setObject:username forKey:@"USERNAME"];
    [self.rcDataDictionaryForUserTable setObject:seqNum forKey:@"SequenceNumber"];
    
    // Return a MSTable instance with rcUserDataInfo table
    MSTable *itemTable = [self.client tableWithName:@"rcUserDataInfo"];
    
    // Insert data into table
    [itemTable insert:self.rcDataDictionaryForUserTable completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
        } else {
            NSLog(@"User %@ added", username);
        }
    }];
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
            NSLog(@"Cannot get unique sequence number from server... Abort!");
        } else {
            if ([result.items count] == 1){
                // Pass the NSDictionary* stored in NSArray back to callback function
                returnCallback([result.items objectAtIndex:0]);
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

// Make a query request for a single user, returns a NSArray of dictionaries in callback
- (void) getDatafromUser:(NSString*)rcUsername Callback:(void(^)(NSArray *callbackItem)) returnCallback{
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:@"rcMainDataTable"];
    
    // Create a filter for
    // 1. Username
    // 2. Foodtype
    NSPredicate *dataFilter = [NSPredicate predicateWithFormat:
                               @"(USERNAME=%@)AND(foodType!=NULL)", rcUsername];
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcQuery = [itemTable queryWithPredicate:dataFilter];
    
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
            }
        }
    }];

}

// Update an entry into the table, retrieve the information first and then update that entry
- (void) incrementSequenceNumberWithDictionary:(NSDictionary*)myDict Callback:(void(^)(NSNumber* completeFlag)) returnCallback{
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
            returnCallback(@NO);
        } else {
            NSLog(@"Successfully updated dictionary");
            returnCallback(@YES);
        }
    }];
}


// Collect data into NSDictionary object.
// NSDictioanry format: NSDictionary *dict = @{ key : value, key2 : value2}
//    Object descriptions:
//    1.    Name of the restaurant (if not yet exist, option to add restaurant appears)
//    2.    Username
//    3.    Photo

- (void)insertResNameData:(NSString *)resName {
    // Insert restaurant name into mutable dictionary
    [self.rcDataDictionary setObject:resName forKey:@"rName"];
}

- (void)insertTypeData:(NSString *)foodType { 
    // Insert food type into mutable dictionary
    [self.rcDataDictionary setObject:foodType forKey:@"foodType"];
}

- (void)insertSequenceNumber:(NSString *)sequenceNumber username:(NSString *)username { 
    // Insert username and sequence number (image reference) into mutable dictionary
    [self.rcDataDictionary setObject:username forKey:@"userName"];
    [self.rcDataDictionary setObject:sequenceNumber forKey:@"sequence"];
}

// Search user with same username and return entries in callback
- (void)verifyUsername:(NSString *)rcUsername Callback:(void(^)(BOOL callbackItem))returnCallback{
    // Return a MSTable instance with tableName
    MSTable *itemTable = [self.client tableWithName:@"rcUserDataInfo"];
    
    // Create a filter for
    // 1. Username
    NSPredicate *dataFilter = [NSPredicate predicateWithFormat:
                               @"USERNAME=%@", rcUsername];
    
    // Prepare a MSQuery object with filter dataFilter
    MSQuery *rcQuery = [itemTable queryWithPredicate:dataFilter];
    
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
    
    // Convert location data from double to string
    NSString *longitudeToString = [NSString stringWithFormat:@"%f", myLocation.coordinate.longitude];
    NSString *latitudeToString = [NSString stringWithFormat:@"%f", myLocation.coordinate.latitude];
    // Debug
    NSLog(@"Long:%@\nLat:%@", longitudeToString, latitudeToString);
    
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

@end
