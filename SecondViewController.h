//
//  SecondViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AddViewController.h"

@class GPSAlarmAppDelegate, AlarmModel;

@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddViewDelegate> {
//	IBOutlet UITableView *destinationTable;
//	IBOutlet UINavigationItem *navItem;  // Navigation bar
}

@property (nonatomic, weak) IBOutlet UITableView *destinationTable;
@property (nonatomic, weak) IBOutlet UINavigationItem *navItem;

- (IBAction)addDestination:(id)sender;
- (IBAction)editAction:(id)sender;

// public

// private
- (AlarmModel *)alarmModel;
- (void)pushEditController:(LocationPin *)editPin;

@end
