
//  IATSignInViewController.m
//  Its A Trap
//
//  Created by Adam Canady on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "SignInViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface SignInViewController ()

@end

@implementation SignInViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2 - loginview.frame.size.width/2, self.view.frame.size.height/2 - loginview.frame.size.height/2, loginview.frame.size.width, loginview.frame.size.height);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    [loginview sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self performSegueWithIdentifier: @"loggedIn" sender: self];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.objectID;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = nil;
}



@end