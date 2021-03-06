//
//  ShowItemsTableViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 10/3/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "ShowItemsTableViewController.h"
#import "ShowGMapViewController.h"

@interface ShowItemsTableViewController ()

@end

@implementation ShowItemsTableViewController {
    // Store the type name of the enum that current instance will be displaying
    NSString *fTypename;
    
    // Outlet of map button on right hand side of navigation bar
    IBOutlet UIButton *rcMapButton;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    // Initialize to 0
    self.searchFoodType = FOODTYPE_ALL;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide map button and only show it when valid data is returned
    rcMapButton.hidden = YES;
    
    // Set up overlay UIView
    self.overlayUIView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 85, 85)];
    
    // Get center point for the overlay view
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.tabBarController.view.bounds), CGRectGetMidY(self.tabBarController.view.bounds));
    
    // Set overlay view to center and make it transparent
    self.overlayUIView.center = centerPoint;
    self.overlayUIView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    // Round corner
    self.overlayUIView.layer.cornerRadius = 5;
    self.overlayUIView.layer.masksToBounds = true;
    
    // Display an activity indicator to alert user that download is in progress
    UIActivityIndicatorView *rcSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)UIActivityIndicatorViewStyleWhiteLarge];
    
    // Setup spinner
    [rcSpinner setFrame:self.overlayUIView.bounds];
    [rcSpinner.layer setBackgroundColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    rcSpinner.hidesWhenStopped = YES;
    
    // Add subview
    [self.overlayUIView addSubview:rcSpinner];
    
    // Add spinner subview and start spinner
    [rcSpinner startAnimating];
    [self.tabBarController.view addSubview:self.overlayUIView];
    
    // stop tableview from loading by setting delegate and datasource to null
    self.rcTableView.delegate = nil;
    self.rcTableView.dataSource = nil;
    
    // Initialize singleton instances
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    self.rcBlobContainer = [rcAzureBlobContainer sharedStorageContainer];
    
    // Initialize cell mutable array
    self.rcCellMutableArray = [[NSMutableArray alloc] init];
    
    // Get typename from data connection translation method
    fTypename = [self.rcDataConnection getFoodTypeNameWithEnum:self.searchFoodType];
    NSLog(@"Performing a search on food type: %@", fTypename);
    
    // Get all data for the food type from server
    [self.rcDataConnection getDatafromUser:nil FoodType:self.searchFoodType RangeOfSearch_Lat:(float)0.8 RangeOfSearch_Long:(float)0.8 Callback:^(NSArray *callbackItem) {
        // In Callback function
        if (callbackItem == nil){
            // No items are returned
            
            // Stop the spinner from spinning
            [rcSpinner stopAnimating];
            [self.overlayUIView removeFromSuperview];
            
            
            // ========= Create Alert =========
            // Create a UI AlertController to show warning message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry.." message:@"Nothing can be located" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:NULL];
            // ================================
            
        } else {
            // Successful download
            NSLog(@"Array Data received, storing data self.foodFromMainDataTable_Array");
            // Store the array as class property
            self.foodFromMainDataTable_Array = callbackItem;
            
            // Show Map button
            rcMapButton.hidden = NO;

            // Check for first read
            static BOOL ImageIsReturned;
            ImageIsReturned = NO;
            // Store result items into cell array.
            for (NSDictionary* returnDict in callbackItem){
                // Premade the cell that are going to be displayed in tableview
                rcShowItemsTableViewCell *rcCell = [self.rcTableView dequeueReusableCellWithIdentifier:@"rcShowItemCell"];
                
                // === Retrieve data from the returned dictionary ===
                NSString *sequenceNum = [[returnDict objectForKey:@"sequence"] stringValue];
                NSString *dataOwner = [returnDict objectForKey:@"userName"];
                NSString *restaurantName = [returnDict objectForKey:@"rName"];
                
                // Set cell properties
                rcCell.rcMainCellLabel.text = [NSString stringWithFormat:@"Restaurant: %@", restaurantName];
                rcCell.rcSecondCellLabel.text = [NSString stringWithFormat:@"User: %@", dataOwner];

                // Request one image stored inside dictionary key "sequence"
                [self.rcBlobContainer getImagefromBlobFromUser:dataOwner sequenceNumber:sequenceNum rcCallback:^(UIImage *rcReturnedImage) {
                    // Handle Error
                    if (rcReturnedImage == nil){
                        // Re-try download again;
                        [self retryImageDownloadForUser:dataOwner Sequence:sequenceNum callback:^(UIImage *callbackItem) {
                            // Assign returned image directly to target cell in main thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // Display image in current cell
                                rcCell.rcCellRightImage.image = callbackItem;
                            }); // End of dispatch to main thread
                        }];
                    } else {
                        // Get the returned UIImage into the cell in main thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Display image in current cell
                            rcCell.rcCellRightImage.image = rcReturnedImage;
                            
                            // Remove the overlay view when the first image is loaded
                            if (ImageIsReturned == NO){
                                // Stop the spinner from spinning
                                [rcSpinner stopAnimating];
                                [self.overlayUIView removeFromSuperview];
                                // Set flag to Yes
                                ImageIsReturned = YES;
                            }
                        }); // End of dispatch to main thread
                    } // End of valid return image
                    

                }]; // End of download image method
                
                // Add cell to the end of the array
                [self.rcCellMutableArray addObject:rcCell];
            } // End of for loop, end of processing of one entry
        }
        // Display number of entries in title
        dispatch_async(dispatch_get_main_queue(), ^{
            // Set title
            self.title = [NSString stringWithFormat:@"%@ : %lu items", fTypename, (unsigned long)[callbackItem count]];
        });
        
        // After storing all entries into cell mutable array, ask table to refresh
        // Note: Image might not be returned at this point.
        self.rcTableView.delegate = self;
        self.rcTableView.dataSource = self;
        [self.rcTableView reloadData];
        
    }]; // End of getDatafromUser

}

// Before view disappear
- (void) viewWillDisappear:(BOOL)animated{
    // Remove the loading overlay view if it is not removed already
    if (self.overlayUIView){
        [self.overlayUIView removeFromSuperview];
    }
}

// Re-download image and return a warning image if redownload failed
- (void) retryImageDownloadForUser:(NSString*)username Sequence:(NSString*)seq callback:(void(^)(UIImage *callbackItem)) returnCallback{
    [self.rcBlobContainer getImagefromBlobFromUser:username sequenceNumber:seq rcCallback:^(UIImage *rcReturnedImage) {
        UIImage *target;
        // If the image is not valid, return a warning image
        if (rcReturnedImage == nil){
            // Get warning image from file
            target = [UIImage imageNamed:@"warning"];
        } else {
            // If imgae is valid, return it to caller function
            target = rcReturnedImage;
        }
        returnCallback(target);
    }];
    
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
    NSNumber *temp = [NSNumber numberWithUnsignedLong:[self.foodFromMainDataTable_Array count]];
    
    // Debug
    NSLog(@"Setting number of rows to %@", temp);
    
    // Return number of rows in this table
    return [self.foodFromMainDataTable_Array count];
}

// This method is called each time row re-appear on the screen!
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // Debug
    NSLog(@"cellForRowAtIndexPath started with row: %ld", (long)indexPath.row);
    rcShowItemsTableViewCell *rcCell = [self.rcCellMutableArray objectAtIndex:indexPath.row];
    return rcCell;
}

#pragma mark - Table Click Event

// When an entry in the table is selected, present google map view to show its location
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // Use current index to get selected dictionary object from data array
    NSDictionary *selectedEntry = [self.foodFromMainDataTable_Array objectAtIndex:indexPath.row];
    
    // Create an array with only the selected item
    NSArray *singleItemArray = [NSArray arrayWithObject:selectedEntry];
    
    // Get storyboard
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"searchTable" bundle:nil];
    // Get the view controller from storyboard
    ShowGMapViewController *vc = (ShowGMapViewController*)[sb instantiateViewControllerWithIdentifier:@"showGmapID"];
    
    // Send selected item to the vc
    vc.mapItemsArray = singleItemArray;

    [self.navigationController pushViewController:vc animated:YES];
}

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


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"fromSearchTableToMap"]){
        // Get the destination view controller using [segue destinationViewController].
        ShowGMapViewController *destVC = [segue destinationViewController];
        // Pass the array containing all map locations to destination view controller
        destVC.mapItemsArray = self.foodFromMainDataTable_Array;
    }
}


@end
