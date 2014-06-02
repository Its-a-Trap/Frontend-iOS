//
//  SignInViewController.h
//  Its A Trap
//
//  Created by Adam Canady on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePLus.h>
#import <FacebookSDK/FacebookSDK.h>
#import "IATUser.h"

static NSString * const kClientId = @"542509304002";

@class GPPSignInButton;

@interface SignInViewController : UIViewController <FBLoginViewDelegate, GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet IATUser *mainUser;
@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

@end
