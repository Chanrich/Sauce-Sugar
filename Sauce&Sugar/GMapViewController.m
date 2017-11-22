//
//  GMapViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 11/17/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "GMapViewController.h"
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

@interface GMapViewController ()

@end

@implementation GMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    GMSCameraPosition *cameraPos = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.2 zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectZero camera:cameraPos];
    mapView.myLocationEnabled = YES;
    
    // Hide all POI on map
    NSError *error;
    GMSMapStyle *style = [GMSMapStyle styleWithJSONString:HIDE_GMAP_POI_JSON error:&error];
    if (!style){
        NSLog(@"JSON to hide POI on google map is not initialized");
    }
    mapView.mapStyle = style;
    
    // Assign google map view will takeover the view of an object
    self.view = mapView;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.2);
    marker.title = @"mark title";
    marker.snippet = @"Snippet text";
    marker.map = mapView;
}

- (UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
