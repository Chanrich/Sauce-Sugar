//
//  AppDelegate.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/25/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "rcAzureBlobContainer.h"
#import "GlobalNames.h"
@interface AppDelegate ()

@end

@implementation AppDelegate {
    rcAzureDataTable *rcDataConnection;
    rcAzureBlobContainer *rcBlobContainer;
    NSString *currentUsername;
    NSString *currentUserPassword;
    // Store credential space
    // Create a protection space
    NSURL *ssURL;
    NSURLProtectionSpace *selfProtectionSpace;

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Invalidate current user
    currentUsername = @"";
    currentUserPassword = @"";
    
    // Enable Google API
    [GMSServices provideAPIKey:@"AIzaSyCElpQ25SaS9VxqFsdgR1pRkVYEbspWALI"];
    
    // Initialize singleton instances
    rcDataConnection = [rcAzureDataTable sharedDataTable];
    rcBlobContainer = [rcAzureBlobContainer sharedStorageContainer];
    
    // Create a protection space
    ssURL = [NSURL URLWithString:@"https://saucensugarmobileapp.azurewebsites.net"];
    selfProtectionSpace = [[NSURLProtectionSpace alloc] initWithHost:ssURL.host port:[ssURL.port integerValue] protocol:ssURL.scheme realm:nil authenticationMethod:NSURLAuthenticationMethodDefault];
    
    return YES;
}

// Set username
- (void) setUsername:(NSString*)username{
    currentUsername = username;
}

// Save a copy of current username
- (void) setPassword:(NSString*)password{
    currentUserPassword = password;
}

// If no user is set return 'Guest' as current username
- (NSString*) getUsername{
    if ([currentUsername  isEqual: @""]){
        return AZURE_USER_GUEST;
    } else {
        return currentUsername;
    }
}

// Retrun current user password retrieved from credential
- (NSString*) getPassword{
    return currentUserPassword;
}

// Logout current user
- (void) logoutUser{
    currentUsername = @"";
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Sauce_Sugar"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - User credentials
// Store username and password
- (void) setUserCredential:(NSURLCredential*)credential{
    [[NSURLCredentialStorage sharedCredentialStorage] setCredential:credential forProtectionSpace:selfProtectionSpace];
}

// Get stored credential.
- (NSURLCredential*) getUserCredentail{
    NSDictionary *credentialsDict;
    credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:selfProtectionSpace];
    
    // Retrieve user credential
    NSURLCredential *userCredential = [credentialsDict.objectEnumerator nextObject];
    
    return userCredential;
}

// Clean credential
- (void) cleanUserCredential{
    NSDictionary *credentialsDict;
    NSURLCredential *tempCred;
    credentialsDict = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:selfProtectionSpace];
    tempCred = [credentialsDict.objectEnumerator nextObject];
    [[NSURLCredentialStorage sharedCredentialStorage] removeCredential:tempCred forProtectionSpace:selfProtectionSpace];
}

@end
