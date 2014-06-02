//
//  IATHighScoreViewController.h
//  Its A Trap
//
//  Created by Carlton Keedy on 5/23/14.
//  Copyright (c) 2014 Its-A-Trap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "IATMapViewController.h"

@interface IATHighScoreViewController : UIViewController <FBLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate, IATMapViewControllerDelegate>

@property (nonatomic, assign) id <IATMapViewControllerDelegate> delegate;
@property (nonatomic, strong) id jsonObject;
@property NSArray *highScoreRecords;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;

@property NSMutableData *responseData;
@property NSArray *playerList;
@property NSDictionary *scoreList;
@property NSMutableArray *highScores;
@property NSDictionary *ID;



@end
