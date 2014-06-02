
//  IATSignInViewController.m
//  Its A Trap
//
//  Created by Adam Canady on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "SignInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>




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
    
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    
    signIn.scopes = @[ @"profile" ];
    
    signIn.clientID = kClientId;
    
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2 - loginview.frame.size.width/2, self.view.frame.size.height/2 - loginview.frame.size.height/2, loginview.frame.size.width, loginview.frame.size.height);
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    [loginview sizeToFit];
    [signIn trySilentAuthentication];
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
    if (FBSession.activeSession.isOpen) {
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                
                 NSString *tmpUsername = [[NSString alloc] init];
                 tmpUsername = user.first_name;

                 NSString *tmpEmail = [[NSString alloc] init];
                 tmpEmail = [user objectForKey:@"email"];
                 
                 _mainUser = [[IATUser alloc] init];
                 _mainUser.username = tmpUsername;
                 _mainUser.emailAddr = tmpEmail;
             }
         }];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = nil;
}

-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error{
    NSLog(@"Received error %@ and auth object %@", error, auth);
    [self performSegueWithIdentifier: @"loggedIn" sender: self];
}

-(void)refreshInterfaceBasedOnSignIn {
    if ([[GPPSignIn sharedInstance] authentication]) {
        // The user is signed in.
        self.signInButton.hidden = YES;
        // Perform other actions here, such as showing a sign-out button
    } else {
        self.signInButton.hidden = NO;
        // Perform other actions here
    }
}


@end

