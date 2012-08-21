//
//  GPSAlarmAppDelegate.h
//  GPSAlarm
//
//  Created by Chris Hughes on 25/08/2009.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlarmViewController, SecondViewController;

@interface GPSAlarmAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
//    UIWindow *window;
//    UITabBarController *tabBarController;
	
//@private
//	IBOutlet AlarmViewController *alarmViewController;
//	IBOutlet SecondViewController *secondViewController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, weak) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, weak) IBOutlet AlarmViewController *alarmViewController;
@property (nonatomic, weak) IBOutlet SecondViewController *secondViewController;

@end

