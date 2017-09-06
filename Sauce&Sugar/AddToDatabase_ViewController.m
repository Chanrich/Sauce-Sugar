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

- (IBAction)ButtonTouchedUpInside_Add:(id)sender {
    // Button touch up inside event has been triggered.
    // Add data into Azure database
    MSClient *client = [(AppDelegate *)[[UIApplication sharedApplication] delegate] client];
    NSDictionary *item = @{@"text": @"Very good Item"};
    MSTable *itemTable = [client tableWithName:@"TodoItem"];
    // Table name:Table_objectInfo
    //    Object descriptions:
    //    1.	Name of the food
    //    2.	Name of the restaurant (if not yet exist, option to add restaurant appears)
    //    3.	Photo
    //    4.	Rating (Binary option: Good or bad)
    //    5.	Comments
    //    6.	Price range

    [itemTable insert:item completion:^(NSDictionary *InsertedItem, NSError *error) {
        if (error){
            NSLog(@"error: %@", error);
        } else {
            NSLog(@"Item inserted: id:%@", [InsertedItem objectForKey:@"id"]);
        }
    }];
    
    
    NSLog(@"Creating Container");
    [self createBlobContainer:@"rchan"];
}

// Create a container with containerName
- (void) createBlobContainer:(NSString*)containerName{
    NSError *AZSAccountError;
    AZSCloudStorageAccount *account = [AZSCloudStorageAccount accountFromConnectionString:@"DefaultEndpointsProtocol=https;AccountName=imagestorageblobs;AccountKey=d8e1NrdP49wzHvxaPtLa41uO3mX/fXPWPMSBa4MPGSe4/+5E7zavNBsvMuqSoN1HynKuyYumoyNLkCpgaowJOQ==" error:&AZSAccountError];
    if (AZSAccountError){
        NSLog(@"Error when creating account");
    }
    
    // Create a blob client object
    AZSCloudBlobClient *blobClient = [account getBlobClient];
    
    // Create a container
    AZSCloudBlobContainer *blobContainer = [blobClient containerReferenceFromName:containerName];
    
    [blobContainer createContainerIfNotExistsWithAccessType:AZSContainerPublicAccessTypeContainer requestOptions:[blobClient defaultRequestOptions] operationContext:nil completionHandler:^(NSError * _Nullable error, BOOL exist) {
        if (error){
            NSLog(@"Error when creating container:\n %@", error);
        } else {
            if (exist){
                NSLog(@"container is existing");
            } else {
                NSLog(@"Container created");
            }
            
            [self getImagefromblob:@"image1" blobContainer:blobContainer];
        }
    }];
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
