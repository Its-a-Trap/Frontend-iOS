//
//  IATAppDelegate.h
//  Its A Trap
//
//  Created by the It's A Trap! Team on 5/7/14.
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
#import "IATAppDelegateProtocol.h"
#import "IATHighScoreViewController.h"


@interface IATAppDelegate : UIResponder <UIApplicationDelegate, IATAppDelegateProtocol> {
    UIWindow *window;
    UINavigationController *navigationController;
    IATAppDataObject* theAppDataObject;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IATAppDataObject* theAppDataObject;

@end
