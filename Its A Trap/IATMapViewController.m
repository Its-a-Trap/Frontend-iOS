//
//  IATMapViewController.m
//  Its A Trap
//
//  Created by Carlton Keedy on 5/10/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import "IATMapViewController.h"
#import "SWRevealViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "IATAppDelegateProtocol.h"
#import "IATDataObject.h"

@interface IATMapViewController ()

@end

@implementation IATMapViewController

//@synthesize mapView;
@synthesize locationManager;
GMSMapView *mapView;
CLLocationCoordinate2D mostRecentCoordinate;
GMSMarker *lastTouchedMarker;
IATUser *mainUser;
int myMaxTrapCount = 12;
NSMutableArray *names;
NSMutableArray *scores;

- (IATDataObject*) theAppDataObject;
{
	id<IATAppDelegateProtocol> theDelegate = (id<IATAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
	IATDataObject* theDataObject;
	theDataObject = (IATDataObject*) theDelegate.theAppDataObject;
	return theDataObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.myActiveTraps = [[NSMutableArray alloc] init];
    self.enemyTraps = [[NSMutableArray alloc] init];
    
    [self setUpMainUser];
    [self setupGoogleMap];
    [self setupTrapCountButton];
    [self setupSweepButton];
    //[self setupTestEnemyTraps];
    [self startStandardUpdates];
    [self setupMyScoreLabel];
}

-(void)setUpMainUser{
    IATDataObject* theDataObject = [self theAppDataObject];
    
    mainUser = [[IATUser alloc] init];
    mainUser.username = theDataObject.userName;
    mainUser.emailAddr = theDataObject.userEmail;
    mainUser.score = @"Score\n0";
    [self postGetUserIDToBackend];
    
}

- (IBAction)manageSweepConfirmation:(id)sender {
    NSLog(@"Managing sweep confirmation.");
    [self manageConfirmation:1];
}

- (void)manageConfirmation:(int)typeCode {
    NSString *title;
    NSString *message;
    if (typeCode == 0) {
        if (myMaxTrapCount - [self.myActiveTraps count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Can't do that!"
                                        message:@"You don't have any traps."
                                       delegate:self
                              cancelButtonTitle:@"GRRR! OKAY!"
                              otherButtonTitles:nil];
            [alert show];
            return;
        }
        title = @"Confirm Trap Placement";
        message = @"Do you really wanna put a trap here?";
    } else if (typeCode == 1) {
        title = @"Confirm Sweep";
        message = @"Are you sure you want to sweep?";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                                message:message
                               delegate:self
                      cancelButtonTitle:@"No"
                      otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Action canceled.");
    } else if (buttonIndex == 1) {
        if ([alertView.title isEqual:@"Confirm Sweep"]) {
            NSLog(@"Sweep confirmed.");
            [self manageSweep];
        } else if ([alertView.title isEqual:@"Confirm Trap Placement"]){
            NSLog(@"Trap placement confirmed.");
            [self manageTrapPlacement];
        } else {
            NSLog(@"Trap Delete confirmed.");
            [self manageTrapRemoval];
        }
    }
}

- (void)manageSweep {
    // Get enemy traps from DB.
    [self postChangeAreaToBackend];
    
    // Place a marker for each nearby trap.
    NSMutableArray *markers = [[NSMutableArray alloc]init];
    
    for (IATTrap *trap in self.enemyTraps) {
        CLLocation* trapLocation = [[CLLocation alloc] initWithLatitude:trap.coordinate.latitude longitude:trap.coordinate.longitude];
        // Only show traps within a hard-coded radius of 10m.
        if ([trapLocation distanceFromLocation:self.myLocation] <= 1000) {
            GMSMarker *marker = [GMSMarker markerWithPosition:trap.coordinate];
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
            marker.title = trap.trapID;
            marker.map = mapView;
            [markers addObject:marker];
        }
    }
    
    // Remove markers after 10 seconds.
    [self performSelector:@selector(clearAllMarkers:) withObject:markers afterDelay:10 inModes:@[NSRunLoopCommonModes]];
}

- (void)clearAllMarkers:(NSMutableArray*) markers {
    for (GMSMarker *marker in markers) {
        marker.map = nil;
    }
}

- (void)manageTrapPlacement {
    NSLog(@"Managing trap placement.");
    // Make a new trap; set its coordinate, activeness, time planted, radius
    IATTrap *newTrap = [[IATTrap alloc] init];
    newTrap.coordinate = mostRecentCoordinate;
    newTrap.isActive = YES;
    //newTrap.radius = 10;
    
    // Place a marker on the map for the new trap.
    GMSMarker *marker = [GMSMarker markerWithPosition:mostRecentCoordinate];
    marker.snippet = @"Tap to Delete";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.map = mapView;
    
    [self postNewTrapToBackend:newTrap];
}

- (void)postChangeAreaToBackend {
    // make an NSURL object from the API's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/API/changeArea";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // make a string of JSON data, including user's lat, lon, and ID
    NSString *stringData = [NSString stringWithFormat:
    @"{"
    @" \"location\": {"
    @" \"lat\": 0.930943,"
    @" \"lon\": 0.8293874983},"
    @" \"user\": "
    @" %@}", mainUser.userID];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] > 0 && error == nil){
             //process the JSON response
             //use the main queue so that we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self parseResponse:data];
             });
         } else if ([data length] == 0 && error == nil){
             return;
         } else if (error != nil){
             return;
         }
     }];
}

- (void)postNewTrapToBackend:(IATTrap*)trap {
    // make an NSURL from a string of the backend's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/api/placemine";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the new NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    /* make a string of JSON data to be posted, like so:
     {
        "location": {
            "lat":"<latitude>",
            "lon":"<longitude>"
        },
        "user":"<userID>"
     } */
    NSMutableString *stringData = [[NSMutableString alloc] initWithString:@"{\"location\":{\"lat\":"];
    NSString *latStr = [NSString stringWithFormat:@"%f", mostRecentCoordinate.latitude];
    NSString *lonStr = [NSString stringWithFormat:@"%f", mostRecentCoordinate.longitude];
    
    [stringData appendString:latStr];
    [stringData appendString:@", \"lon\":"];
    [stringData appendString:lonStr];
    [stringData appendString:@"}, \"user\":"];
    [stringData appendString:mainUser.userID];
    [stringData appendString:@"}"];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] > 0 && error == nil){
             //process the JSON response
             //use the main queue so we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *trapIDDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 
                 // init myTraps, otherTraps, and highScores dictionaries
                 trap.trapID = [trapIDDictionary objectForKey:@"id"];
                 
                 [self.myActiveTraps addObject:trap];
                 [self updateTrapCount];
                 NSLog(@"Posted new trap to backend.");
                 return;
             });
         } else if ([data length] == 0 && error == nil){
             NSLog(@"Problem posting new trap to backend:");
             NSLog(@"data length == 0 && error == nil");
             return;
         } else if (error != nil){
             NSLog(@"Problem posting new trap to backend:");
             NSLog(@"error != nil");
             return;
         }
     }];
}

- (void)postRemoveTrapToBackend:(NSString *)trapID {
    // make an NSURL from a string of the backend's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/api/removemine";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the new NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    /* make a string of JSON data to be posted, like so: { "id":"5382c04acd5f5d9268872246" }*/
    NSMutableString *stringData = [[NSMutableString alloc] initWithString:@"{\"id\":\""];
    [stringData appendString:trapID];
    [stringData appendString:@"\" }"];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] > 0 && error == nil){
             //process the JSON response
             //use the main queue so we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"Posted trap removal to backend.");
                 return;
             });
         } else if ([data length] == 0 && error == nil){
             NSLog(@"Problem posting trap removal to backend:");
             NSLog(@"data length == 0 && error == nil");
             return;
         } else if (error != nil){
             NSLog(@"Problem posting trap removal to backend:");
             NSLog(@"error != nil");
             return;
         }
     }];
}

- (void)postTriggerTrapToBackend:(NSString *)trapID {
    // make an NSURL from a string of the backend's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/api/explodemine";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the new NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    /* make a string of JSON data to be posted, like so:
     {
        "id":"5382c04acd5f5d9268872246",
        "user":"<my_awesome_name_which_is_Steve>"
     } */
    NSMutableString *stringData = [[NSMutableString alloc] initWithString:@"{\"id\":\""];
    [stringData appendString:trapID];
    [stringData appendString:@"\",\"user\":\""];
    [stringData appendString:mainUser.username];
    [stringData appendString:@"\"}"];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] > 0 && error == nil){
             //process the JSON response
             //use the main queue so we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 //[self parseResponse:data];
             });
         } else if ([data length] == 0 && error == nil){
             NSLog(@"Problem posting trap trigger to backend:");
             NSLog(@"data length == 0 && error == nil");
             return;
         } else if (error != nil){
             NSLog(@"Problem posting trap trigger to backend:");
             NSLog(@"error != nil");
             return;
         }
     }];
}

- (void)postGetUserIDToBackend {
    // make an NSURL from a string of the backend's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/api/getuserid";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the new NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    /* make a string of JSON data to be posted, like so:
     {
        "email":"maegereg@gmail.com",
        “name”:”<my_awesome_name>”
     } */
    
    NSMutableString *stringData = [[NSMutableString alloc] initWithString:@"{\"email\":\""];
    [stringData appendString:mainUser.emailAddr];
    [stringData appendString:@"\",\"name\":\""];
    [stringData appendString:mainUser.username];
    [stringData appendString:@"\"}"];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error) {
         if ([data length] > 0 && error == nil){
             //process the JSON response
             //use the main queue so we can interact with the screen
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *myData = [[NSString alloc] initWithData:data
                                                          encoding:NSUTF8StringEncoding];
                 mainUser.userID = myData;
                 
                 // NOTE: postChangeAreaToBackend called!
                    [self postChangeAreaToBackend];
             });
         } else if ([data length] == 0 && error == nil){
             NSLog(@"Problem posting userID request to backend:");
             NSLog(@"data length == 0 && error == nil");
             return;
         } else if (error != nil){
             NSLog(@"Problem posting userID request to backend:");
             NSLog(@"error != nil");
             return;
         }
     }];
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    mapView.selectedMarker = marker;
    return TRUE;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    lastTouchedMarker = marker;
    if ([marker.snippet isEqual:@"Tap to Delete"]){
        UIAlertView *deleteAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Confirm Trap Removal"
                                    message:@"You really wanna remove this trap?"
                                    delegate:self
                                    cancelButtonTitle:@"No"
                                    otherButtonTitles:@"Yes", nil];
        [deleteAlert show];
    }
}

- (void)manageTrapRemoval {
    for (IATTrap *trap in self.myActiveTraps){
        if (trap.coordinate.latitude == lastTouchedMarker.position.latitude && trap.coordinate.longitude == lastTouchedMarker.position.longitude) {
            [self postRemoveTrapToBackend:trap.trapID];
            [self.myActiveTraps removeObject:trap];
            [self updateTrapCount];
            lastTouchedMarker.map = nil;
            
            // ********************************************************************************
            // "Let's just assume it always works." - Jiatao, on why we're not using this code:
            // ********************************************************************************
            /*
            BOOL succeeded = [self postRemoveTrapToBackend:trap.trapID];
            if (!succeeded) {
                // TO-DO: Handle failure by showing user popup?
                NSLog(@"Failed to post trap removal from backend.");
                return NO;
            } else {
                [self.myActiveTraps removeObject:trap];
                [self updateTrapCount];
                lastTouchedMarker.map = nil;
                return YES;
            }
             */
        }
    }
}

- (void)setupTestEnemyTraps {
    IATTrap *testEnemy = [[IATTrap alloc] init];
    CLLocationDegrees latitude = 44.4604636;
    CLLocationDegrees longitude = -93.1535;
    testEnemy.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [self.enemyTraps addObject:testEnemy];
}

- (void)setupGoogleMap {
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:_myLocation.coordinate.latitude //44.4604636
                                 longitude:_myLocation.coordinate.longitude //-93.1535
                                 zoom:14];
    
    mapView = [GMSMapView mapWithFrame:CGRectMake(10, 20, self.view.frame.size.width, self.view.frame.size.height - 70) camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    mapView.layer.zPosition = -1;
    [self.view addSubview:mapView];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    mostRecentCoordinate = coordinate;
    [self manageConfirmation:0];
}

- (void)setupMyTrapMarkers {
    for (IATTrap *trap in self.myActiveTraps) {
        // Place a marker on the map for the new trap.
        GMSMarker *marker = [GMSMarker markerWithPosition:trap.coordinate];
        marker.position = trap.coordinate;
        marker.snippet = @"Tap to Delete";
        marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        marker.map = mapView;
    }
}

- (void)setupSweepButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(manageSweepConfirmation:)
     forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(self.view.frame.size.width - 75, self.view.frame.size.height - 50, 75, 50);
    //button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    //button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [button setTitle:@"Detect\nTraps" forState:UIControlStateNormal];
    
    [self.view addSubview:button];
}

- (void)setupMyScoreLabel {
    self.myScoreLabel = [[UILabel alloc] init];
    self.myScoreLabel.frame = CGRectMake(((self.view.frame.size.width - 10) / 2) - 30, self.view.frame.size.height - 50, 80, 50);
    
    self.myScoreLabel.text = mainUser.score;
    self.myScoreLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.myScoreLabel.textAlignment = NSTextAlignmentCenter;
    self.myScoreLabel.numberOfLines = 0;
    
    [self.view addSubview:self.myScoreLabel];
}

-(void)updateMyScoreLabel{
    self.myScoreLabel.text = [@"Score\n" stringByAppendingString:mainUser.score];
}

- (void)setupTrapCountButton {
    self.trapCountLabel =[[UILabel alloc] init];
    self.trapCountLabel.frame = CGRectMake(10, self.view.frame.size.height - 50, 75, 50);
    self.trapCountLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.trapCountLabel.textAlignment = NSTextAlignmentCenter;
    self.trapCountLabel.numberOfLines = 0;
    
    [self.trapCountLabel setFont: [UIFont fontWithName:@"System-Bold" size:15.0]];
    
    [self updateTrapCount];
    [self.view addSubview:self.trapCountLabel];
    
    /*
    self.trapCountButton = [[IATTrapCountButton alloc] init];
    self.trapCountButton.frame = CGRectMake(10, self.view.frame.size.height - 50, 40, 40);
    
    [self updateTrapCount];
    
    [self.view addSubview:self.trapCountButton];
    [self.trapCountButton drawCircleButton:[UIColor redColor]];
     */
}

- (void)updateTrapCount {
    long trapCount = myMaxTrapCount - [self.myActiveTraps count];
    NSString *trapCountString = [@(trapCount) stringValue];
    [self.trapCountLabel setText: [@"Traps\n" stringByAppendingString:trapCountString]];
    
    //[self.trapCountButton setTitle:trapCountString forState:UIControlStateNormal];
}

// LOCATION SERVICES ----------------------------------------------------------------
- (void)startStandardUpdates {
    if (nil == self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 0.0f;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"didUpdateLocations");
    [self postChangeAreaToBackend];
    self.myLocation = [locations lastObject];
    
    GMSCameraPosition *whereIAm = [GMSCameraPosition cameraWithLatitude:_myLocation.coordinate.latitude
                                                            longitude:_myLocation.coordinate.longitude
                                                                 zoom:16];
    [mapView setCamera:whereIAm];
    
    // Determine whether user has stumbled upon any traps
    for (IATTrap *trap in self.enemyTraps) {
        if ([self trapIsNear:trap location:self.myLocation]) {
            [self triggerTrap:trap];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to update locations");
}

- (BOOL)trapIsNear:(IATTrap *)trap location:(CLLocation *)location{
    CLLocation* testLocation = [[CLLocation alloc] initWithLatitude:trap.coordinate.latitude longitude:trap.coordinate.longitude];
    if ([testLocation distanceFromLocation:location] <= 5) {
        return YES;
    };
    return NO;
}

- (void)triggerTrap:(IATTrap *)trap{
    // Let backend know something has happened.
    NSLog(@"A trap has been triggered!");
    [self postTriggerTrapToBackend:trap.trapID];
    BOOL triggerSucceeded = YES;
    if (!triggerSucceeded) {
        NSLog(@"ERROR: Failed to trigger trap within triggering range.");
    } else {
        // Notify user that he or she tripped a trap.
        UILocalNotification *notif = [[UILocalNotification alloc] init];
        notif.alertBody = @"You've been trapped!";
        notif.alertAction = @"View Details";
        notif.soundName = UILocalNotificationDefaultSoundName;
        //notif.applicationIconBadgeNumber = 1;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notif];
    }
}

- (void)parseResponse:(NSData *) data {
    //NSString *myData = [[NSString alloc] initWithData:data
    //                                         encoding:NSUTF8StringEncoding];
    //NSLog(@"JSON data: %@", myData);
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // init myTraps, otherTraps, and highScores dictionaries
    _myTraps = [jsonDictionary objectForKey:@"myMines"];
    _otherTraps = [jsonDictionary objectForKey:@"mines"];
    _highScores= [jsonDictionary objectForKey:@"scores"];
    
    //sort _highScores
    NSSortDescriptor *sortByScore = [NSSortDescriptor sortDescriptorWithKey:@"score"
                                                                  ascending:NO];
    NSArray *sortedHighScores = [NSArray arrayWithObject:sortByScore];
    NSArray *sortedArray = [_highScores sortedArrayUsingDescriptors:sortedHighScores];
    
    IATDataObject* theDataObject = [self theAppDataObject];
    
    NSMutableArray* tmpNamesArray = [[NSMutableArray alloc] initWithObjects: nil];
    NSMutableArray* tmpScoresArray = [[NSMutableArray alloc] initWithObjects: nil];

    for (int i = 0; i < [sortedArray count]; i++){
        
        NSDictionary *foo = [sortedArray objectAtIndex:i];
        NSLog(@"%@", foo);
        
        NSNumber *tmpScore = [[sortedArray objectAtIndex:i] objectForKey:@"score"];
        NSString *tmpName = [[sortedArray objectAtIndex:i] objectForKey:@"name"];
        
        if ([tmpName isEqualToString:mainUser.username]){
            mainUser.score = [tmpScore stringValue];
            [self updateMyScoreLabel];
        }
        
        [tmpNamesArray addObject: tmpName];
        [tmpScoresArray addObject: tmpScore];
    }
    
    theDataObject.names = tmpNamesArray;
    theDataObject.scores = tmpScoresArray;
    
    [self.enemyTraps removeAllObjects];
    //add mines to enemyTraps
    for (int i = 0; i < [_otherTraps count]; i++){
        NSDictionary *trapToAdd = [_otherTraps objectAtIndex:i];
        
        IATTrap *addThisTrap = [[IATTrap alloc] init];
        addThisTrap.trapID = [trapToAdd objectForKey:@"id"];
        addThisTrap.ownerID = [trapToAdd objectForKey:@"owner"];
        
        NSDictionary *locationCoordinatesToAdd = [trapToAdd objectForKey:@"location"];
        double tempLat = [[locationCoordinatesToAdd objectForKey:@"lat"] doubleValue];
        double tempLong = [[locationCoordinatesToAdd objectForKey:@"lon"] doubleValue];
        
        CLLocationDegrees lat = tempLat;
        CLLocationDegrees lon = tempLong;
        addThisTrap.coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        [self.enemyTraps addObject:addThisTrap];
    }
    
    
    [self.myActiveTraps removeAllObjects];
    //add mines to myActiveTraps and otherTraps
    for (int i = 0; i < [_myTraps count]; i++){
        NSDictionary *trapToAdd = [_myTraps objectAtIndex:i];
        
        IATTrap *addThisTrap = [[IATTrap alloc] init];
        addThisTrap.trapID = [trapToAdd objectForKey:@"id"];
        addThisTrap.ownerID = [trapToAdd objectForKey:@"owner"];
        
        NSDictionary *locationCoordinatesToAdd = [trapToAdd objectForKey:@"location"];
        double tempLat = [[locationCoordinatesToAdd objectForKey:@"lat"] doubleValue];
        double tempLong = [[locationCoordinatesToAdd objectForKey:@"lon"] doubleValue];
        
        CLLocationDegrees lat = tempLat;
        CLLocationDegrees lon = tempLong;
        addThisTrap.coordinate = CLLocationCoordinate2DMake(lat, lon);
        
        [self.myActiveTraps addObject:addThisTrap];
    }
    
    [self setupMyTrapMarkers];
    [self updateTrapCount];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
