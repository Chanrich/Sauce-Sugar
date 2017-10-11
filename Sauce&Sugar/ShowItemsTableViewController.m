//
//  ShowItemsTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/3/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "ShowItemsTableViewController.h"

@interface ShowItemsTableViewController ()

@end

@implementation ShowItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // get current username
    NSString *currentUser = [(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername];
    // stop tableview from loading by setting delegate and datasource to null
    self.rcTableView.delegate = nil;
    self.rcTableView.dataSource = nil;
    
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    self.rcBlobContainer = [rcAzureBlobContainer sharedStorageContainer];
    
    // Initialize cell mutable array
    self.rcCellMutableArray = [[NSMutableArray alloc] init];
    
    // Connect blob container
    [self.rcBlobContainer connectToContainerWithName:currentUser];
    
    // Get current user's data from the cloub
    [self.rcDataConnection getDatafromUser:currentUser Callback:^(NSArray *callbackItem) {
        NSLog(@"Array Data received, storing data self.userDataInfo_NSArray");
        // Store the array as class property
        self.userDataInfo_NSArray = callbackItem;
        
        // Fast enumerate through returned array
        for (NSDictionary* returnDict in callbackItem){
            // Premade the cell that are going to be displayed in tableview
            rcShowItemsTableViewCell *rcCell = [self.rcTableView dequeueReusableCellWithIdentifier:@"rcShowItemCell"];
            
            // Set cell properties
            rcCell.rcMainCellLabel.text = [returnDict objectForKey:@"fName"];
            rcCell.rcSecondCellLabel.text = [returnDict objectForKey:@"rName"];
            
            // Get sequence number
            NSString *sequenceNum = [[returnDict objectForKey:@"sequence"] stringValue];
            // Request one image stored inside dictionary key "sequence"
            [self.rcBlobContainer getImagefromBlobFromUser:currentUser sequenceNumber:sequenceNum rcCallback:^(UIImage *rcReturnedImage) {
                // Get the returned UIImage into the cell in main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"SN %@ Image setting complete", sequenceNum);
                    rcCell.rcCellRightImage.image = rcReturnedImage;
                });
                
            }];
            // Add cell to the end of the array
            [self.rcCellMutableArray addObject:rcCell];
            NSLog(@"added an item to cell mutable array, size: %lu", (unsigned long)[self.rcCellMutableArray count]);
        }
        
        
        // After data finished downloading, enable tableview to reload by setting its delegate and datasource to self
        self.rcTableView.delegate = self;
        self.rcTableView.dataSource = self;
        
        // Trigger data reload
        [self.rcTableView reloadData];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return 1 section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Store unsigned long into a NSnumber to avoid xcode warning
    NSNumber *temp = [NSNumber numberWithUnsignedLong:[self.userDataInfo_NSArray count]];
    
    // Debug
    NSLog(@"Setting number of rows to %@", temp);
    
    // Return number of rows in this table
    return [self.userDataInfo_NSArray count];
}

// This method is called each time row re-appear on the screen!
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Debug
    NSLog(@"cellForRowAtIndexPath started with row: %ld", (long)indexPath.row);
    rcShowItemsTableViewCell *rcCell = [self.rcCellMutableArray objectAtIndex:indexPath.row];
    return rcCell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
