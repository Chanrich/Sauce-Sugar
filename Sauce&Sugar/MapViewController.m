//
//  MapViewController.m
//  Sauce&Sugar
//
//  Created by Richard Chan on 8/27/17.
//  Copyright © 2017 Sauce&Sugar. All rights reserved.
//

#import "MapViewController.h"
#import "LocationDataController.h"
#import "Location.h"


@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated{
    //LocationDataController *model = [[LocationDataController alloc] init];
    //Location *poi = [model getPointOfInterest];
    CLLocationCoordinate2D poiCoodinates;
    poiCoodinates.longitude = 121.552321;
    poiCoodinates.latitude = 25.042355;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 2000, 2750);
    [self.mapView setRegion:viewRegion animated:YES];
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
