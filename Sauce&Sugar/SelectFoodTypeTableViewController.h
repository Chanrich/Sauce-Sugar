//
//  SelectFoodTypeTableViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/28/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "rcAzureBlobContainer.h"
#import "AddToDatabase_ViewController.h"

@interface SelectFoodTypeTableViewController : UITableViewController

// ============ Custom Properties ==============
// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;


// Finish adding and return to main menu
- (IBAction)Finish_TouchUpInside:(id)sender;

@end
