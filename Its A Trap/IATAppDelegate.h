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

static NSString * const kClientId = @"780610866037-tgfn7rpcjv34cedu1c21jvknatu344le.apps.googleusercontent.com";

@interface IATAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (strong, nonatomic) UIWindow *window;

@end
