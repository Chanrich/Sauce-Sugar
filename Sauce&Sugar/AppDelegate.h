//
//  AppDelegate.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
// Import Azure Mobile app framework
#import <MicrosoftAzureMobile/MicrosoftAzureMobile.h>
// Import Azure storage framework
#import <AZSClient/AZSClient.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

// Add Microsoft client to connect to Azure
@property (strong, nonatomic) MSClient *client;


- (void)saveContext;


@end

