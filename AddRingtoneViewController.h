//
//  AddRingtoneViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddViewController;

@interface AddRingtoneViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	AddViewController *addViewController;
	
	NSArray *ringtoneTitleArray;

}

@property (nonatomic, strong) AddViewController *addViewController;
@property (nonatomic, strong) NSArray *ringtoneTitleArray;

@end
