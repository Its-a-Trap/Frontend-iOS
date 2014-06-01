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

@interface IATMapViewController ()

@end

@implementation IATMapViewController

//@synthesize mapView;
GMSMapView *mapView;
CLLocationCoordinate2D mostRecentCoordinate;
GMSMarker *lastTouchedMarker;
IATUser *testUser;
int myMaxTrapCount = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    testUser = [[IATUser alloc] init];
    testUser.userID = @"test_user_id_222";
    //testUser.UserID = [self postGetUserIDToBackend];
    
    // Carlton's curiosity: What's this for?
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.myActiveTraps = [[NSMutableArray alloc] init];
    self.enemyTraps = [[NSMutableArray alloc] init];
    
    [self postChangeAreaToBackend];
    [self setupTestEnemyTraps];
    [self setupGoogleMap];
    [self setupTrapCountButton];
    [self setupSweepButton];
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
                                  initWithTitle:@"You can't do that!"
                                        message:@"You don't have any traps."
                                       delegate:self
                              cancelButtonTitle:@"GRRR! OKAY!"
                              otherButtonTitles:nil];
            [alert show];
            return;
        }
        title = @"Confirm Trap Placement";
        message = @"Are you sure you want to place a trap here?";
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
        if ([trapLocation distanceFromLocation:self.myLocation] <= 10) {
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
    // Make a new trap; set its coordinate, activeness, time planted, radius
    IATTrap *newTrap = [[IATTrap alloc] init];
    newTrap.coordinate = mostRecentCoordinate;
    newTrap.isActive = YES;
    newTrap.timePlanted = 222;
    //newTrap.radius = 10;
    
    [self.myActiveTraps addObject:newTrap];
    [self updateTrapCount];
    
    // Place a marker on the map for the new trap.
    GMSMarker *marker = [GMSMarker markerWithPosition:mostRecentCoordinate];
    marker.title = newTrap.trapID;
    marker.snippet = @"Tap to Delete";
    marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    marker.map = mapView;
    
    [self postNewTrapToBackend];
}

- (void)postChangeAreaToBackend {
    // make an NSURL object from the API's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/API/changeArea";
    NSURL *myUrl = [NSURL URLWithString:myUrlString];
    
    // make a mutable HTTP request from the NSURL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    [urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // make a string of JSON data, including user's lat, lon, and ID
    NSString *myString = @"{\"location\": {\"lat\": 42.930943,\"lon\": 23.8293874983},\"user\":\"";
    NSMutableString *stringData = [[NSMutableString alloc] initWithString:myString];
    [stringData appendString:testUser.userID];
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

- (void)postNewTrapToBackend {
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
    [stringData appendString:@"}, \"user\":\""]; //orig: @" \"user\": "@"\"537e48763511c15161a1ed9c\"}"
    [stringData appendString:testUser.userID];
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
                 [self parseResponse:data];
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

// NOTE: WE DO NOT YET CALL ANY OF THE NEXT THREE METHODS ANYWHERE.

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
                 [self parseResponse:data];
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
    [stringData appendString:testUser.username];
    [stringData appendString:@"\"}"];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // set the receiver’s request body, timeout interval (seconds), and HTTP request method
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:requestBodyData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    
<<<<<<< HEAD
    // Change area to get all traps that exist before launch?

    [self postChangeArea];
    [self setupTestEnemyTraps];
    [self updateMyTraps];
    [self updateEnemyTraps];
    [self setupGoogleMap];
    [self setupTrapCountButton];
    [self setupSweepButton];
}

-(void)postChangeArea {
    //create a NSURL object from the string data
    NSString *myUrlString = @"http://107.170.182.13:3000/API/changeArea";
=======
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
                 [self parseResponse:data];
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

- (NSString *)postGetUserIDToBackend {
    // make an NSURL from a string of the backend's URL
    NSString *myUrlString = @"http://107.170.182.13:3000/api/getuserid";
>>>>>>> b89f38b078016c1ec5e8e5eabfcd8f693b3dd4c3
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
    [stringData appendString:testUser.emailAddr];
    [stringData appendString:@"\",\"name\":\""];
    [stringData appendString:testUser.username];
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
                 // NSString *userID = [self parseResponse:data];
                 // return userID;
                 return;
                 //[self parseResponse:data];
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
<<<<<<< HEAD
    
=======
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    mapView.selectedMarker = marker;
    return TRUE;
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    lastTouchedMarker = marker;
    if ([marker.snippet isEqual:@"Tap to Delete"]){
        UIAlertView *deleteAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Delete?"
                                    message:@"Remove this trap?"
                                    delegate:self
                                    cancelButtonTitle:@"No"
                                    otherButtonTitles:@"Yes", nil];
        [deleteAlert show];
    }
}

- (BOOL)manageTrapRemoval {
    for (IATTrap *trap in self.myActiveTraps){
        if (trap.coordinate.latitude == lastTouchedMarker.position.latitude && trap.coordinate.longitude == lastTouchedMarker.position.longitude) {
            BOOL succeeded = [self postRemoveTrapToBackend:trap.id];
            if (!succeeded) {
                // TO-DO: Handle failure by showing user popup?
                NSLog(@"Failed to post trap removal from backend.");
            } else {
                [self.myActiveTraps removeObject:trap];
                [self updateTrapCount];
                lastTouchedMarker.map = nil;
            }
        }
    }
}

- (void)setupTestEnemyTraps {
    IATTrap *testEnemy = [[IATTrap alloc] init];
    CLLocationDegrees latitude = 44.4604636;
    CLLocationDegrees longitude = -93.1535;
    testEnemy.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [self.enemyTraps addObject:testEnemy];
>>>>>>> b89f38b078016c1ec5e8e5eabfcd8f693b3dd4c3
}

- (void)setupGoogleMap {
     // Middle of Campus: lat = 44.4604636;
     //                   lon = -93.1535;
    
    GMSCameraPosition *camera = [GMSCameraPosition
                                 cameraWithLatitude:_myLocation.coordinate.latitude
                                 longitude:_myLocation.coordinate.longitude
                                 zoom:6];
    
    mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    //mapView = [GMSMapView mapWithFrame:CGRectMake(10, 0, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    //mapView.myLocationEnabled = YES;
    //mapView.delegate = self;
    //mapView.layer.zPosition = -1;
    [self.view addSubview:mapView];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    mostRecentCoordinate = coordinate;
    [self manageConfirmation:0];
}

- (void)setupSweepButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(manageSweepConfirmation:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Sweep" forState:UIControlStateNormal];
    button.frame = CGRectMake(125, 30, self.view.frame.size.width, 30);
    [self.view addSubview:button];
}

- (void)setupTrapCountButton {
    self.trapCountButton = [[IATTrapCountButton alloc] init];
    self.trapCountButton.frame = CGRectMake(10, 30, 40, 40);
    
    [self updateTrapCount];
    
    [self.view addSubview:self.trapCountButton];
    [self.trapCountButton drawCircleButton:[UIColor redColor]];
}

- (void)updateTrapCount {
    int trapCount = myMaxTrapCount - [self.myActiveTraps count];
    NSString *trapCountString = [@(trapCount) stringValue];
    [self.trapCountButton setTitle:trapCountString forState:UIControlStateNormal];
}

// LOCATION SERVICES ----------------------------------------------------------------
- (void)startStandardUpdates {
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //locationManager.distanceFilter = 1; // in meters
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self updateEnemyTraps];
    self.myLocation = [locations lastObject];
    
    // Determine whether user has stumbled upon any traps
    for (IATTrap *trap in self.enemyTraps) {
        if ([self trapIsNear:trap location:self.myLocation]) {
            [self triggerTrap:trap];
        }
    }
}

- (BOOL)trapIsNear:(IATTrap *)trap location:(CLLocation *)location{
    CLLocation* testLocation = [[CLLocation alloc] initWithLatitude:trap.coordinate.latitude longitude:trap.coordinate.longitude];
    if ([testLocation distanceFromLocation:location] <= 2) {
        return YES;
    };
    return NO;
}


- (void)parseResponse:(NSData *) data {
    NSString *myData = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSLog(@"JSON data: %@", myData);
    
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // init myTraps, otherTraps, and highScores dictionaries
    _myTraps = [jsonDictionary objectForKey:@"myMines"];
    _otherTraps = [jsonDictionary objectForKey:@"mines"];
    _highScores= [jsonDictionary objectForKey:@"scores"];
    
    _names = [[NSMutableArray alloc] initWithArray:_names];
    _scores = [[NSMutableArray alloc] initWithArray:_scores];
    
    for (int i = 0; i < [_highScores count]; i++){
        NSString *tmpScore = [[_highScores objectAtIndex:i]  objectForKey:@"score"];
        NSString *tmpName = [[_highScores objectAtIndex:i] objectForKey:@"name"];
        [_names addObject: tmpName];
        [_scores addObject: tmpScore];
    }
    
    //add mines to myActiveTraps and otherTraps
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
