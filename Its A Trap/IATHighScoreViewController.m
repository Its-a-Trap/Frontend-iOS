//
//  IATHighScoreViewController.m
//  Its A Trap
//
//  Created by Carlton Keedy on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATHighScoreViewController.h"
#import "IATHighScoreCell.h"
#import "IATAppDelegateProtocol.h"
#import "IATDataObject.h"


@interface IATHighScoreViewController ()

@end

@implementation IATHighScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FBLoginView *loginview = [[FBLoginView alloc] init];
    self.loginView.readPermissions = @[@"public_profile", @"email", @"user_friends"];
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2.45 - loginview.frame.size.width/2, self.view.frame.size.height/1.05 - loginview.frame.size.height/2, loginview.frame.size.width, loginview.frame.size.height);
    
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
}

- (IATDataObject*)theAppDataObject;
{
	id<IATAppDelegateProtocol> theDelegate = (id<IATAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
	IATDataObject* theDataObject;
	theDataObject = (IATDataObject*) theDelegate.theAppDataObject;
	return theDataObject;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section {
    IATDataObject* theDataObject = [self theAppDataObject];
    return [theDataObject.names count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IATHighScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HighScoreCell" forIndexPath:indexPath];
    
    IATDataObject* theDataObject = [self theAppDataObject];
    
    cell.playerNameLabel.text = [theDataObject.names objectAtIndex:indexPath.row];
    cell.playerScoreLabel.text = [NSString stringWithFormat:@"%@", [theDataObject.scores objectAtIndex:indexPath.row]];
    return cell;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [self performSegueWithIdentifier: @"loggedOut" sender: self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
