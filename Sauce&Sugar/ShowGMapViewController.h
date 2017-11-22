//
//  ShowGMapViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/18/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalNames.h"
#import "rcAzureDataTable.h"

@interface ShowGMapViewController : UIViewController

// The array will store all data returned from Azure data table
@property NSArray *mapItemsArray;
// A mutable array to store all mark's pointers
@property NSMutableArray *marksArray;
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;



@end
