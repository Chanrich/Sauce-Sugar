//
//  SelectFoodTypeTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/28/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

/*
 The purpose of this view is to load type data into Azure Data Table
 
*/
#import "SelectFoodTypeTableViewController.h"

@interface SelectFoodTypeTableViewController ()

@end

@implementation SelectFoodTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Initialize a singleton instance for Azure Data
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // indexPath.row is the currently selected row, use it to access menu items
    
    FoodTypes typeName;
    switch (indexPath.row) {
        case 0:
            // Noodle
            typeName = NOODLES;
            break;
        case 1:
            // Rice
            typeName = RICE;
            break;
        case 2:
            // Drinks
            typeName = DRINK;
            break;
        case 3:
            typeName = DESSERT;
            // Desserts
            break;
        case 4:
            typeName = ICECREAM;
            // Ice Cream
            break;
        default:
            // Default
            typeName = FOODTYPE_ALL;
            break;
    }
    
    // Insert type data into Azure Data Table
    [self.rcDataConnection insertTypeData:typeName];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
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


- (IBAction)Finish_TouchUpInside:(id)sender {
    //[self.navigationController popToRootViewControllerAnimated:YES];
}
@end
