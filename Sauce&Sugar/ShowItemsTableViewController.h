//
//  ShowItemsTableViewController.h
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/3/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "rcAzureDataTable.h"
#import "rcAzureBlobContainer.h"
#import "rcShowItemsTableViewCell.h"

@interface ShowItemsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

// UI element, table view
@property (strong, nonatomic) IBOutlet UITableView *rcTableView;


// Singleton instance of table data management
@property (strong, nonatomic) rcAzureDataTable *rcDataConnection;

// Singleton instance of Blob Container
@property (strong, nonatomic) rcAzureBlobContainer *rcBlobContainer;

// A array to store all data downloaded
@property NSArray *userDataInfo_NSArray;
@property UIView *overlayUIView;
@property NSMutableArray<rcShowItemsTableViewCell*> *rcCellMutableArray;

@end
