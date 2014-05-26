//
//  IATHighScoreViewController.m
//  Its A Trap
//
//  Created by Carlton Keedy on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATHighScoreViewController.h"
#import "IATHighScoreCell.h"


@interface IATHighScoreViewController ()

@end

@implementation IATHighScoreViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger)section {
    return 8;//[self.highScoreRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IATHighScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HighScoreCell" forIndexPath:indexPath];
    /*
     TO-DO: FIGURE OUT HOW THIS SHOULD WORK
    Class highScoreRecord = [self.highScoreRecords objectAtIndex:indexPath.row];
    cell.playerNameLabel.text = highScoreRecord.playerName;
    cell.playerScoreLabel.text = highScoreRecord.playerScore;
     */
    cell.playerNameLabel.text = @"foo";
    cell.playerScoreLabel.text = @"bar";
    return cell;
}

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
    
    loginview.frame = CGRectMake(self.view.frame.size.width/2.45 - loginview.frame.size.width/2, self.view.frame.size.height/1.05 - loginview.frame.size.height/2, loginview.frame.size.width, loginview.frame.size.height);
    
    loginview.delegate = self;
    
    [self.view addSubview:loginview];
    
    [loginview sizeToFit];
    
    // Create the request.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://107.170.182.13:3000/changeArea"]];
    //POST request
    request.HTTPMethod = @"POST";
    
    //Set header fields
    //[request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // Convert your data and set your request's HTTPBody property
    //NSDictionary *dictionary = @{ @"location" : @{ @"lat" : @"42.930943", @"lon" : @"-23.8293874983" }, @"user" : @"537d2b4b221e2a193a385e3f"};
    NSString *stringData = @"{'location: {'lat':-42.930943,'lon': 23.8293874983},'user': '537d2b4b221e2a193a385e3f'}";
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = requestBodyData;
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    self.highScoreRecords = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    
    [self performSegueWithIdentifier: @"loggedOut" sender: self];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
