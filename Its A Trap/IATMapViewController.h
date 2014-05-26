//
//  IATMapViewController.h
//  Its A Trap
//
//  Created by the It's A Trap! Team on 5/10/14.
//    Adam Canady
//    Jiatao Cheng
//    Calder Coalson
//    Carlton Keedy
//    Carissa Knipe
//    Quinn Radich
//    Daniel Simmons-Marengo
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "IATUser.h"
#import "IATTrap.h"
#import "IATTrapCountButton.h"
#import <GoogleMaps/GoogleMaps.h>

@interface IATMapViewController : UIViewController <GMSMapViewDelegate, UIAlertViewDelegate> {
    CLLocationManager *locationManager;
}

//@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property NSMutableArray *myActiveTraps;
@property NSMutableArray *allTraps;
@property IBOutlet UIButton *sweepButton;
@property IATTrapCountButton *trapCountButton;
@property (nonatomic, strong, readonly) CLLocation *myLocation;

- (void)updateMyTraps;
- (void)updateAllTraps;

@end
