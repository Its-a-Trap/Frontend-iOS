//
//  IATLeaderBoardViewController.h
//  Its A Trap
//
//  Created by Adam Canady on 5/24/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface IATLeaderBoardViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@end
