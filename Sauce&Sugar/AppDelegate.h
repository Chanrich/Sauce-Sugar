//
//  AppDelegate.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
// Import Azure storage framework
#import <AZSClient/AZSClient.h>
// Import Azure Mobile app framework
#import <MicrosoftAzureMobile/MicrosoftAzureMobile.h>

// Import google map features
@import GoogleMaps;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

- (void) setUsername:(NSString*)username;
- (NSString*) getUsername;
- (void) logoutUser;

@end

