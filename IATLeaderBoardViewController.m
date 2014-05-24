//
//  IATLeaderBoardViewController.m
//  Its A Trap
//
//  Created by Adam Canady on 5/24/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATLeaderBoardViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>

@interface IATLeaderBoardViewController ()

@end

@implementation IATLeaderBoardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2.45 - loginview.frame.size.width/2, self.view.frame.size.height/1.05 - loginview.frame.size.height/2, loginview.frame.size.width, loginview.frame.size.height);
    
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    
    [self performSegueWithIdentifier: @"loggedOut" sender: self];
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */

@end
