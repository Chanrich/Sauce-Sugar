//
//  ShowGMapViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/18/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "ShowGMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>


static NSString *const HIDE_GMAP_POI_JSON = @"["
@"  {"
@"    \"featureType\": \"poi.business\","
@"    \"elementType\": \"all\","
@"    \"stylers\": ["
@"      {"
@"        \"visibility\": \"off\""
@"      }"
@"    ]"
@"  },"
@"  {"
@"    \"featureType\": \"transit\","
@"    \"elementType\": \"labels.icon\","
@"    \"stylers\": ["
@"      {"
@"        \"visibility\": \"off\""
@"      }"
@"    ]"
@"  }"
@"]";

@interface ShowGMapViewController (){
    // Keep all marks' references in this array
    NSMutableArray *markerArray;
    
    // current coordinates
    double current_latitude;
    double current_longitude;
    CLLocationCoordinate2D currentCoordinate;
    
    // Map object
    GMSMapView *mapView;
}

@end

@implementation ShowGMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize singleton instances
    self.rcDataConnection = [rcAzureDataTable sharedDataTable];
    
    // initialize mutable array
    self.marksArray = [[NSMutableArray alloc] init];
    
    current_latitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.latitude;
    current_longitude = (double)self.rcDataConnection.currentGPSLocation.coordinate.longitude;
    
    // Create a coordinate at current location
    currentCoordinate = CLLocationCoordinate2DMake(current_latitude, current_longitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current_latitude
                                                            longitude:current_longitude
                                                                 zoom:7];
    
    GMSMutablePath *pathPoints = [GMSMutablePath path];
    
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    mapView.myLocationEnabled = YES;
    
    // ======== Hide all POI on map object ==========
    NSError *error;
    GMSMapStyle *style = [GMSMapStyle styleWithJSONString:HIDE_GMAP_POI_JSON error:&error];
    if (!style){
        NSLog(@"JSON to hide POI on google map is not initialized");
    }
    mapView.mapStyle = style;
    // ================================================
    
    // Assign google map view to container view
    self.view = mapView;
    
    // Loop through each entry (NSDictionary) in mapItemsArray
    for (NSDictionary* item in self.mapItemsArray){
        // Collect information from item
        float latitude = [[item objectForKey:GPS_LATITUDE] floatValue];
        float longitude = [[item objectForKey:GPS_LONGITUDE] floatValue];
        
        // Store location data into coordinate
        CLLocationCoordinate2D tempCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        
        // Get text information for the marker
        FoodTypes foodTypeEnum = [[item objectForKey:AZURE_DATA_TABLE_FOODTYPE] intValue];
        NSLog(@"Print out food type enum:%d", foodTypeEnum);
        NSString *foodType = [self.rcDataConnection getFoodTypeNameWithEnum:foodTypeEnum];
        NSString *restaurantName = [item objectForKey:AZURE_DATA_TABLE_RESTAURANT_NAME];
        
        // Setup marker and show it in map
        GMSMarker *markerItem = [[GMSMarker alloc] init];
        markerItem.position = tempCoordinate;
        markerItem.title = restaurantName;
        markerItem.snippet = foodType;
        markerItem.map = mapView;
        
        // Capture coordinates of the marker into a display path which will be used for zooming in later.
        [pathPoints addCoordinate:markerItem.position];
        
        // Keep references to those marker in a mutable array
        [self.marksArray addObject:markerItem];
    }
    
    // Zoom in the camera after a delay so all marks are visible
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Get bounds from paths of coordinates
        GMSCoordinateBounds *inclusiveBounds = [[GMSCoordinateBounds alloc] initWithPath:pathPoints];
        
        // Create a camera update object with the bounds
        GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:inclusiveBounds];
        
        // Show new bounds after delay
        [mapView animateWithCameraUpdate:cameraUpdate];
    });
    
    NSUInteger tempCount = [self.marksArray count];
    NSLog(@"Marks Array count: %lu", (unsigned long) tempCount);
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

@end
