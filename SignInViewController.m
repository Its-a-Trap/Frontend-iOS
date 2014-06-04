
//  IATSignInViewController.m
//  Its A Trap
//
//  Created by Adam Canady on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "SignInViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "IATAppDelegateProtocol.h"
#import "IATDataObject.h"

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

- (IATDataObject*) theAppDataObject;
{
    id<IATAppDelegateProtocol> theDelegate = (id<IATAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    IATDataObject* theDataObject;
    theDataObject = (IATDataObject*) theDelegate.theAppDataObject;
    return theDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    FBLoginView *loginview = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email"]];
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2 - loginview.frame.size.width/2, self.view.frame.size.height - 60, loginview.frame.size.width, loginview.frame.size.height);
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
    

    
    if (FBSession.activeSession.isOpen) {
        
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 
                 
                 IATDataObject* theDataObject = [self theAppDataObject];
                 
                 NSString *tmpUsername = [[NSString alloc] init];
                 tmpUsername = user.name;
                 
                 NSString *tmpEmail = [[NSString alloc] init];
                 tmpEmail = [user objectForKey:@"email"];
                 
                 theDataObject.userName = tmpUsername;
                 theDataObject.userEmail = tmpEmail;
                 
             }
         }];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = nil;
}




@end

