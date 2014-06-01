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
#import <CoreLocation/CoreLocation.h>
#import "IATUser.h"
#import "IATTrap.h"
#import "IATTrapCountButton.h"
#import <GoogleMaps/GoogleMaps.h>

@interface IATMapViewController : UIViewController <GMSMapViewDelegate, UIAlertViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@property NSMutableArray *myActiveTraps;
@property NSMutableArray *enemyTraps;
@property IBOutlet UIButton *sweepButton;
@property IATTrapCountButton *trapCountButton;
@property (nonatomic, strong) CLLocation *myLocation;
@property NSMutableData *responseData;
@property NSArray *playerList;
@property NSDictionary *scoreList;
@property NSArray *highScores;
@property NSMutableArray *names;
@property NSMutableArray *scores;

@property NSDictionary *myTraps;
@property NSDictionary *otherTraps;

<<<<<<< HEAD

- (void)updateMyTraps;
- (void)updateEnemyTraps;

=======
>>>>>>> b89f38b078016c1ec5e8e5eabfcd8f693b3dd4c3
@end
