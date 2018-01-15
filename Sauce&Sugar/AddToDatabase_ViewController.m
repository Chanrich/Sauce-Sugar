//
//  AddToDatabase_ViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

/*
 The purpose of this view is to capture:
     1. Restaurant Name -> Azure Data Table
     2. Camera Image -> Azure Blob Storage
 The data should be save to their respective data objects during segue to next view
 
 */

#import "AddToDatabase_ViewController.h"
#import "YelpAPIConnection.h"

@interface AddToDatabase_ViewController () <UITableViewDelegate, UITableViewDataSource>

@end

// Declare function
void createBlobContainer(NSString *contianerName);
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer);


@implementation AddToDatabase_ViewController {
    // Table to show auto complete suggestion for nearby restaurant name
    IBOutlet UITableView *rcAutoCompleteTable;
    // Array to store auto complete cell
    NSMutableArray* rcAutoCompleteCells;
    // Cell to display Yelp logo
    UITableViewCell *yelpCell;
    // Store YELP connection
    YelpAPIConnection* yelpAPI;
    // Array containing yelp returned buisness objects
    NSArray *yelpDataArray;
    
    // Locations
    double current_latitude;
    double current_longitude;
    
    // UI labels
    IBOutlet UILabel *originalSize_Label;
    IBOutlet UILabel *newSize_Label;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set all textfield and image view to transparent so they can be faded in later
    [self.TextField_RestaurantName setAlpha:0];
    [self.MainImageView setAlpha:0];
    [self.rcUsernameLabel setAlpha:0];
    [originalSize_Label setAlpha:0];
    [newSize_Label setAlpha:0];
    
    // Hide auto complete table

    rcAutoCompleteTable.alpha = 0;

    // Set shadow to auto complete table - DISABLED
    // Set shadow to auto complete table
//    rcAutoCompleteTable.layer.shadowColor = [[UIColor blackColor] CGColor];
//    rcAutoCompleteTable.layer.shadowOffset = CGSizeMake(2.0, 3.0);
//    rcAutoCompleteTable.layer.shadowOpacity = 0.3;
//    rcAutoCompleteTable.layer.shadowRadius = 2;
//    rcAutoCompleteTable.layer.masksToBounds = YES;
    
    // Set username to the label
    NSString* username = [(AppDelegate*)[[UIApplication sharedApplication] delegate] getUsername];
    NSString *usernameLabel = [NSString stringWithFormat:@"Username: %@", username];
    [self.rcUsernameLabel setText:usernameLabel];
    
    // Set image sizes labels
    NSString *oSizeString = [NSString stringWithFormat:@"Original Size: %luKB", ([self.originalRcImageSize integerValue]/1024)];
    NSString *nSizeString = [NSString stringWithFormat:@"New Size: %luKB", ([self.nRcImageSize integerValue]/1024)];
    originalSize_Label.text = oSizeString;
    newSize_Label.text = nSizeString;
    
    // Perform animation to fade in restaurant textfield first
    [self.rcUsernameLabel viewFadeInWithCompletion:nil];
    [self.MainImageView viewFadeInWithCompletion:nil];
    [self.TextField_RestaurantName viewFadeInWithCompletion:nil];
    [newSize_Label viewFadeInWithCompletion:nil];
    [originalSize_Label viewFadeInWithCompletion:nil];
    
    // Load image to Azure Blob Storage if image is valid
    if (_rcImageHolder != nil){
        // Initialize a singleton instance for Azure Blob
        self.rcBlobstorage = [rcAzureBlobContainer sharedStorageContainer];
        
        // Store image to blob container
        [self.rcBlobstorage insertImage:_rcImageHolder];
        
        // Set UI Image display
        [self.MainImageView setImage:_rcImageHolder];
    }
    
    // Initialize mutable array
    rcAutoCompleteCells = [[NSMutableArray alloc] init];
    
    // Initialize a singleton instance for Azure Data
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    
    // ================== UI Interaction ==================
    // Set delegate to self to hide keyboard after pressing return
    [self.TextField_RestaurantName setDelegate:self];
    
    // Capture textfield UI Event
    [self.TextField_RestaurantName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.TextField_RestaurantName addTarget:self action:@selector(textFieldStartEdit:) forControlEvents:UIControlEventEditingDidBegin];
    [self.TextField_RestaurantName addTarget:self action:@selector(textFieldEndEdit:) forControlEvents:UIControlEventEditingDidEnd];
    
    // Register a tap recognizer to dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybaord)];
    //[self.view addGestureRecognizer:tap];
    // Add gesture recognizer to UI elements instead of self.view as it would interrupt with aotucomplete table selection
    [self.rcUsernameLabel addGestureRecognizer:tap];
    [self.MainImageView addGestureRecognizer:tap];
    
    
    // Yelp Connection
    yelpAPI = [[YelpAPIConnection alloc] init];
    
    // Set myself as delegate in order to receive data
    yelpAPI.delegate = self;
    
    // Retreive current GPS location
    current_latitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.latitude;
    current_longitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.longitude;
    
    // Create Yelp Cell to display yelp's logo
    yelpCell = [rcAutoCompleteTable dequeueReusableCellWithIdentifier:@"AutoCompleteCell_Yelp"];
    
    // Send an api request to Yelp to retrieve listing of businesses around coordinates provided, this will return the data in a callback method <didReceivedBusinessData>
    [yelpAPI requestForBusinessNamesNearLatitude:current_latitude Longitude:current_longitude];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/* Next button clicked
 - Insert restaurant name to Azure Data Table
 - Proceed to next view
 */
- (IBAction)NextButton_TouchUpInside:(id)sender {
    // If restaurant text field is empty, stop the segue to next view and display alert
    if ([self.TextField_RestaurantName.text isEqualToString:@""]){
        // Alert user to enter a text
        // ----- Create a UI AlertController to show warning message -----
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Restaurant name is empty" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:NULL];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:NULL];
        // ---------------------------------------------------------------
    } else {
        // Restaurant name is valid
        NSLog(@"Adding restuarant name to rcDataConnection");
        // Set restaurant name to Azure Data placeholder
        [self.rcDataConnection insertResNameData:self.TextField_RestaurantName.text];
        

        
        // Proceed to next view
        [self performSegueWithIdentifier:@"ShowFoodTypeSegue" sender:sender];
    }
    
}

// Hide keyboard when a single tap occured
- (void) dismissKeybaord{
    // Hide keyboard for restaurant textbox
    [self.TextField_RestaurantName resignFirstResponder];
}

// Hide keyboard when return is pressed
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

// UI Textfield event triggered when text field is edited
// Updat auto complete table to match current user inputs
- (void) textFieldDidChange:(UITextField*)textField{
    NSLog(@"UITextField value change to: %@", [textField text]);
    
    NSPredicate *parser = [NSPredicate predicateWithFormat:@"name contains[cd] %@", [textField text]];
    NSArray *resultArray;
    
    if ([[textField text] isEqualToString:@""]){
        // Return unfiltered array
        resultArray = yelpDataArray;
    } else {
        resultArray = [yelpDataArray filteredArrayUsingPredicate:parser];
    }


    // Clear out old cell array
    [rcAutoCompleteCells removeAllObjects];
    
    // Create a cell and store it into cell array for each entry
    unsigned long aCount = [resultArray count];
    for (int i = 0; i < aCount; i++) {
        // Unpack the array
        NSDictionary *iDict = [resultArray objectAtIndex:i];
        
        // Get cell with business name and add it to the end of the array
        UITableViewCell *dCell = [self createCellWithName:[iDict objectForKey:@"name"] fromTable:rcAutoCompleteTable];
        [rcAutoCompleteCells addObject:dCell];
        
        // enumerate through the array and print out the names
        NSLog(@"index %d, Business Name:%@", i, [iDict objectForKey:@"name"]);
    }
    
    NSLog(@"Total cell: %lu", [rcAutoCompleteCells count]);
    // Refresh table
    rcAutoCompleteTable.delegate = self;
    rcAutoCompleteTable.dataSource = self;
    [rcAutoCompleteTable reloadData];
}

// When textfield come into focus, display autocomplete table
- (void) textFieldStartEdit:(UITextField*)textField{
    [rcAutoCompleteTable viewFadeInWithCompletion:nil];
}

// Hide autocomplete table when text edit ends
- (void) textFieldEndEdit:(UITextField*)textField{
    //[rcAutoCompleteTable viewFadeOutWithCompletion:nil];
}
#pragma mark - Auto-complete table

// Replace restaurant name field with currently selected field in tableview
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.TextField_RestaurantName.text = cell.textLabel.text;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView viewFadeOutWithCompletion:nil];
    NSLog(@"Selected text: %@", cell.textLabel.text);
}

// Number of business found
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"<Reloading cell count> : %lu", [rcAutoCompleteCells count] + 1);
    // Add 1 for displaying of yelp cell
    return ([rcAutoCompleteCells count] + 1);
}

// Set the height for cells
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == ([rcAutoCompleteCells count])){
        // Height set to 50 for last cell
        return 50;
    } else {
        // Other cells are 30
        return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"<Reloading cell> at index:%lu", indexPath.row);
    // Index starts from 0, so [rcAutoCompleteCells count] should return the last cell
    if (indexPath.row == ([rcAutoCompleteCells count])){
        return yelpCell;
    } else {
        // Grab cell from the array
        UITableViewCell *cell = [rcAutoCompleteCells objectAtIndex:indexPath.row];
        return cell;
    }

}

// Create a cell object with name
- (UITableViewCell*) createCellWithName:(NSString*)name fromTable:(UITableView*)tableview{
    // Get cell from table view cell reference
    UITableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:@"AutoCompleteCell_ID"];
    // Assign name as the primary text label in cell
    cell.textLabel.text = name;
    
    return cell;
}

#pragma mark Yelp Data Return
- (void) didReceivedBusinessData:(NSArray*)businesssArray{
    // Store a reference to the array
    yelpDataArray = businesssArray;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"<didReceivedBusinessData> Number of business returned: %lu", (unsigned long)[businesssArray count]);
        // Get the number of entries returned
        unsigned long aCount = [businesssArray count];
        
        // Create a cell and store it into cell array for each entry
        for (int i = 0; i < aCount; i++) {
            // Unpack the array
            NSDictionary *iDict = [businesssArray objectAtIndex:i];
            
            // Get cell with business name and add it to the end of the array
            UITableViewCell *dCell = [self createCellWithName:[iDict objectForKey:@"name"] fromTable:rcAutoCompleteTable];
            [rcAutoCompleteCells addObject:dCell];
            
            // enumerate through the array and print out the names
            NSLog(@"index %d, Business Name:%@", i, [iDict objectForKey:@"name"]);
        }
        
        NSLog(@"Total cell saved: %lu", [rcAutoCompleteCells count]);
        // Refresh table
        rcAutoCompleteTable.delegate = self;
        rcAutoCompleteTable.dataSource = self;
        [rcAutoCompleteTable reloadData];
    });
}


@end
