//
//  AddViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DistanceModel.h"

@class AddViewController, LocationPin, LocationProximity, LocationProximityView;

@protocol AddViewDelegate <NSObject>
- (void)AddViewController:(AddViewController *)addViewController didDismissWithSave:(BOOL)save;
@end

@interface AddViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
//	IBOutlet UITextField *titleTextField;
//	IBOutlet UIBarButtonItem *saveButton;
	
//	IBOutlet UITableView *tableView;
	
	id<AddViewDelegate> __unsafe_unretained delegate;
	LocationPin *updatedLocationPin;     // the new location created by this view controller
	LocationPin *editLocationPin;    // nil or the current destination to be edited
}

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, unsafe_unretained) id<AddViewDelegate> delegate;
@property (nonatomic, strong) LocationPin *editLocationPin;
@property (nonatomic, strong) LocationPin *updatedLocationPin;

- (void)cancelAction:(id)sender;
- (void)saveAction:(id)sender;

// public

// private
- (void)updateSaveButton;

@end
