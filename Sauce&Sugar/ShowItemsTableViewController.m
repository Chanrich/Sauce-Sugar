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
    // stop tableview from loading by setting delegate and datasource to null
    self.rcTableView.delegate = nil;
    self.rcTableView.dataSource = nil;
    
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Get current user's data from the cloub
    [self.rcDataConnection getDatafromUser:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername] Callback:^(NSArray *callbackItem) {
        NSLog(@"Array Data received, storing data self.userDataInfo_NSArray");
        // Store the array as class property
        self.userDataInfo_NSArray = callbackItem;
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    rcShowItemsTableViewCell *rcCell = [tableView dequeueReusableCellWithIdentifier:@"rcShowItemCell"];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rcShowItemCell"];
    NSDictionary *currentDict = [self.userDataInfo_NSArray objectAtIndex:indexPath.row];
    NSLog(@"indexPath.row: %ld", (long)indexPath.row);
    NSLog(@"table received dictionary size:%lu", [self.userDataInfo_NSArray count]);
//    if (rcCell == nil) {
//        rcCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"rcShowItemCell"];
//    }
    for (NSString *key in [currentDict allKeys]){
        NSLog(@"key: %@", key);
        NSLog(@"object: %@", [currentDict objectForKey:key]);
    }
    rcCell.rcMainCellLabel.text = [currentDict objectForKey:@"fName"];
    rcCell.rcSecondCellLabel.text = [currentDict objectForKey:@"rName"];
    //cell.textLabel.text = [currentDict objectForKey:@"fName"];
    
    // use cell.textLabel.text = NSString
    // image use cell.imageView.image = UIImage
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
