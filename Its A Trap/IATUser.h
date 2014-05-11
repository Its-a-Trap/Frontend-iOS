//
//  IATUser.h
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

@interface IATUser : NSObject

// ID: int (unique to trap)
@property int *userID;

// Username: string
@property NSString *username;

// Email Address: string
@property NSString *emailAddr;


@end
