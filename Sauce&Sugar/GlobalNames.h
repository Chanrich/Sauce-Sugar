//
//  GlobalNames.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/18/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#ifndef GlobalNames_h
#define GlobalNames_h


#endif /* GlobalNames_h */

// Corresponding name in Azure Data Table
#define GPS_LONGITUDE @"longitude"
#define GPS_LATITUDE @"latitude"
#define AZURE_DATA_TABLE_RESTAURANT_NAME @"rName"
#define AZURE_DATA_TABLE_FOODTYPE @"foodType"
#define AZURE_DATA_TABLE_USERNAME @"userName"
#define AZURE_DATA_TABLE_SEQUENCE @"sequence"

// Corresponding name in Azure User Table
#define AZURE_USER_TABLE_USERNAME @"USERNAME"
#define AZURE_USER_TABLE_SEQUENCE @"SequenceNumber" // This has a type of NSNumber
#define AZURE_USER_TABLE_PASSWORD @"PASSWORD"
#define AZURE_USER_GUEST @"Guest"
#define AZURE_USER_GUEST_PASSWORD @"0000"

// Main view constants
#define SLIDEMENU_WIDTH 275
#define SLIDE_DURATION 0.2
#define CORNER_RADIUS 4
#define SLIDEOUT_VIEW_TAG 2

// Fading parameters
#define fadeDuration 0.8
#define fadeDuration_fast 0.3

// Food Data Array Dictionary key names
#define FOOD_DATA_KEY_TYPE_NAME @"NAME"
#define FOOD_DATA_KEY_ICON @"ICON"
#define FOOD_DATA_KEY_ENUM @"ENUM"
