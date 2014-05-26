//
//  IATMapViewController.m
//  Its A Trap
//
//  Created by Carlton Keedy on 5/10/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATMapViewController.h"
#import "SWRevealViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface IATMapViewController ()

@end

@implementation IATMapViewController

//@synthesize mapView;
GMSMapView *mapView_;
CLLocationCoordinate2D mostRecentCoordinate;
int myMaxTrapCount = 5;

/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog([locations lastObject]);
}
 */

- (IBAction)manageSweepConfirmation:(id)sender {
    NSLog(@"Managing sweep confirmation.");
    [self manageConfirmation:1];
}

- (void)manageConfirmation:(int)typeCode {
    NSString *title;
    NSString *message;
    if (typeCode == 0) {
        if (myMaxTrapCount - [self.myActiveTraps count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You can't do that!"
                                                            message:@"You don't have any traps."
                                                           delegate:self
                                                  cancelButtonTitle:@"GRRR! OKAY!"
                                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
        title = @"Confirm Trap Placement";
        message = @"Are you sure you want to place a trap?";
    } else if (typeCode == 1) {
        title = @"Confirm Sweep";
        message = @"Are you sure you want to sweep?";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Action canceled.");
    } else if (buttonIndex == 1) {
        if ([alertView.title isEqual:@"Confirm Sweep"]) {
            NSLog(@"Sweep confirmed.");
        } else {
            NSLog(@"Trap placement confirmed.");
            [self manageTrapPlacement];
        }
    }
}

- (void)manageSweep {
    // TO-DO: Get all nearby traps from DB.
    
    // TO-DO: Place marker for each nearby trap.
    /*
    for (IATTrap in *self.allTraps) {
        GMSMarker *marker = [GMSMarker markerWithPosition:mostRecentCoordinate];
        marker.map = mapView_;
    }
     */
    
    // TO-DO: Get rid of markers at some point.
}

- (void)manageTrapPlacement {
    IATTrap *newTrap = [[IATTrap alloc] init];
    newTrap.trapID = @"222";
    newTrap.ownerID = @"222";
    newTrap.coordinate = mostRecentCoordinate;
    newTrap.isActive = YES;
    //newTrap.timePlanted = 222;
    //newTrap.radius = 10;
    
    [self.myActiveTraps addObject:newTrap];
    [self updateTrapCount];
    
    GMSMarker *marker = [GMSMarker markerWithPosition:mostRecentCoordinate];
    marker.title = newTrap.trapID;
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.map = mapView_;
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
         */
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myActiveTraps = [[NSMutableArray alloc] init];
    self.allTraps = [[NSMutableArray alloc] init];
    
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:_myLocation.coordinate.latitude
                                          longitude:_myLocation.coordinate.longitude
                                               zoom:6];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(10, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    mapView_.layer.zPosition = -1;
    [self.view addSubview:mapView_];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //mapView.showsUserLocation = YES;
    
    /*
    MKUserLocation *userLocation = mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
            userLocation.location.coordinate, 200000, 200000);
    
    MKCoordinateRegion region;
    region.center.latitude = 44.4604636;
    region.center.longitude = -93.1535;
    region.span.latitudeDelta = 0.0075;
    region.span.longitudeDelta = 0.0075;
    [mapView setRegion:region];
     */
    [self setupTrapCountButton];
    [self setupSweepButton];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"Managing didTapAtCoordinate confirmation");
    mostRecentCoordinate = coordinate;
    [self manageConfirmation:0];
}

/*
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 200.0f, 200.0f);
    [self.mapView setRegion:region animated:YES];
}
 */

- (void)updateAllTraps {
    //TO-DO: PUT SOMETHING HERE
}

- (void)updateMyTraps {
    //TO-DO: PUT SOMETHING HERE
}

- (void)setupSweepButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(manageSweepConfirmation:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Sweep" forState:UIControlStateNormal];
    button.frame = CGRectMake(125, 30, self.view.frame.size.width, 30);
    [self.view addSubview:button];
}

- (void)setupTrapCountButton {
    self.trapCountButton = [[IATTrapCountButton alloc] init];
    self.trapCountButton.frame = CGRectMake(10, 30, 40, 40);
    
    [self updateTrapCount];
    
    [self.view addSubview:self.trapCountButton];
    [self.trapCountButton drawCircleButton:[UIColor redColor]];
}

- (void)updateTrapCount {
    int trapCount = myMaxTrapCount - [self.myActiveTraps count];
    NSString *trapCountString = [@(trapCount) stringValue];
    [self.trapCountButton setTitle:trapCountString forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
// In a storyboard-based application, you'll often want to prepare before navigation.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
