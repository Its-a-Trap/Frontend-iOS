//
//  IATTrap.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IATTrap : NSObject

// ID (int): unique to traps table
@property NSString* trapID;
 
// owner (player ID): the player who set the trap
@property NSString* ownerID;

// location (GPS coordinates)
@property CLLocationCoordinate2D coordinate;

// isActive (boolean): set to false when a trap is triggered
@property Boolean isActive;

// time planted (long)
@property long *timePlanted;

// time of expiration (long)
// DEPRECATED: Expiration time derivable from time planted.

// radius (float)
@property float *radius;


@end
