//
//  AddTitleViewController.h
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddViewController;

@interface AddTitleViewController : UIViewController {
//	IBOutlet UITextField *titleTextField;
	
	AddViewController *addViewController;
}

@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, strong) AddViewController *addViewController;

@end
