//
//  AddToDatabase_ViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/30/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "AddToDatabase_ViewController.h"

@interface AddToDatabase_ViewController ()

@end

// Declare function
void createBlobContainer(NSString *contianerName);
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer);


@implementation AddToDatabase_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.MainImageView setImage:_rcImageHolder];
    [self.UploadButtonNavibar setTarget:self];
    [self.UploadButtonNavibar setAction:@selector(executeUpload:)];
    
    // Set delegate to self to hide keyboard after pressing return
    [self.TextField_Name setDelegate:self];
    [self.TextField_RestaurantName setDelegate:self];
    [self.TextView_Comment setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeybaord)];
    [self.view addGestureRecognizer:tap];
    
    // Set current user
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] setCurrentUsername:@"rchan"];
    // Initialize a singleton instance
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // Request a unique serial number
    [self.rcDataConnection getUniqueNumber_WithUsername:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername] Callback:^(NSArray *callbackItem) {
        for (NSDictionary *item in callbackItem){ //items are NSArray item
            // Get data by its key
            NSLog(@"Type of data returned:%@", [[item objectForKey:@"SequenceNumber"] class]);
            NSLog(@"Retrieved number: %@", [item objectForKey:@"SequenceNumber"]);
        }
    }];
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

- (void) executeUpload: (id)sender{
    NSLog(@"Upload button pressed");
}


- (IBAction)ButtonTouchedUpInside_Add:(id)sender {
    // Button touch up inside event has been triggered.
    
    // Insert data into DataTable Class
    [self.rcDataConnection prepareFoodData:self.TextField_Name.text resName:self.TextField_RestaurantName.text comment:self.TextView_Comment.text username:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername]];
    
    // Insert Data collection into table
    // Table name:rcMainDataTable
    [self.rcDataConnection InsertDataIntoTable:@"rcMainDataTable"];
    
    //NSLog(@"Creating Container");
    // Create a blob container with the current username from the shared app delegate object
    //[self createBlobContainer:[(AppDelegate*)[[UIApplication sharedApplication] delegate] currentUsername]];
}

// Create a container with containerName
- (void) createBlobContainer:(NSString*)containerName{
    NSError *AZSAccountError;
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:@"DefaultEndpointsProtocol=https;AccountName=imagestorageblobs;AccountKey=d8e1NrdP49wzHvxaPtLa41uO3mX/fXPWPMSBa4MPGSe4/+5E7zavNBsvMuqSoN1HynKuyYumoyNLkCpgaowJOQ==" error:&AZSAccountError];
    if (AZSAccountError){
        // Show error message then quit
        NSLog(@"Error when creating account");
    } else {
        // No Error
        
        // Create a blob client object
        AZSCloudBlobClient *blobClient = [account getBlobClient];
        
        // Create a container
        AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:containerName];
        
        [blobContainer createContainerIfNotExistsWithAccessType:AZSContainerPublicAccessTypeContainer requestOptions:[blobClient defaultRequestOptions] operationContext:nil completionHandler:^(NSError * _Nullable error, BOOL exist) {
            if (error){
                NSLog(@"Error when creating container:\n %@", error);
            } else {
                if (exist){
                    NSLog(@"Container existing");
                } else {
                    NSLog(@"Container created");
                }
                
                //[self getImagefromblob:@"image1" blobContainer:blobContainer];
            }
        }];        
    }
    

}

// Grab image from blobName inside blobCotainer and a UIImageView to this image
- (void)getImagefromblob:(NSString*)blobName blobContainer:(AZSCloudBlobContainer*)blobContainer{
    // Create a blob
    AZSCloudBlockBlob *blockblob = [blobContainer blockBlobReferenceFromName:blobName];
    
    // Perform blob download
    [blockblob downloadToDataWithCompletionHandler:^(NSError * _Nullable error, NSData * _Nullable downloadedData) {
        if (error){
            NSLog(@"Error when downloading:\b %@", error);
        } else {
            NSLog(@"Download successful");
            UIImage *imagefromdata = [UIImage imageWithData:downloadedData];
            // Set UIImageView to downloaded image
            [self.MainImageView setImage:imagefromdata];
        }
        
    }];
}

// Dismiss keyboard when return pressed in textfields
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return NO;
}

- (void) dismissKeybaord{
    [self.TextView_Comment resignFirstResponder];
}

@end

// BlobName has to be all lowercase, letters or numbers
void AddImageBlob(NSString *imageName, NSString *blobName, AZSCloudBlobContainer *blobContainer){
    UIImage *myimage1 = [UIImage imageNamed:imageName];
    NSData *imgdata = UIImagePNGRepresentation(myimage1);
    AZSCloudBlockBlob *imageblockblob = [blobContainer blockBlobReferenceFromName:blobName];
    [imageblockblob uploadFromData:imgdata completionHandler:^(NSError *error) {
        if (error){
            NSLog(@"Error when uploading blob\n %@", error);
        } else {
            NSLog(@"Successfully uploaded %@", imageName);
        }
    }];
}

// Add a text string to a blob
void AddTextBlob(NSString *text, NSString *blobName, AZSCloudBlobContainer *blobContainer){
    // Create the blob
    AZSCloudBlockBlob *blockblob = [blobContainer blockBlobReferenceFromName:blobName];
    
    //Upload blob
    [blockblob uploadFromText:text completionHandler:^(NSError * _Nullable error) {
        if (error){
            NSLog(@"Error when uploading blob\n %@", error);
        } else {
            NSLog(@"Successfully uploaded: %@", text);
        }
    }];
}
