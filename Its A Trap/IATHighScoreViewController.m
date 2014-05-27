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
    
    
    cell.playerNameLabel.text = ;
    cell.playerScoreLabel.text = highScores[0];
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
    
    
    //string for the URL request
    NSString *myUrlString = @"http://107.170.182.13:3000/API/changeArea";
    
    NSString *stringData = @"{"
                            @" \"location\": {"
                            @" \"lat\": 42.930943,"
                            @" \"lon\": 23.8293874983},"
                            @" \"user\": "
                            @"  \"537e48763511c15161a1ed9c\"}";
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];

    
    //create a NSURL object from the string data
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    //create a mutable HTTP request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    //sets the receiver’s timeout interval, in seconds
    [urlRequest setTimeoutInterval:30.0f];
    //sets the receiver’s HTTP request method
    [urlRequest setHTTPMethod:@"POST"];
    //sets the request body of the receiver to the specified data.
    [urlRequest setHTTPBody:requestBodyData];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    self.highScoreRecords = [[NSMutableArray alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] >0 && error == nil){
             //process the JSON response
             //use the main queue so that we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self parseResponse:data];
             });
         }
         else if ([data length] == 0 && error == nil){
             return;
         }
         else if (error != nil){
             return;
         }
     }];
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

- (void) parseResponse:(NSData *) data {
    
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data = %@", myData);
    
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // Create a new array to hold the scores
    NSMutableArray *highScores = [[NSMutableArray alloc] init];
    NSArray *array = [jsonDictionary objectForKey:@"scores"];
    
}


@end
