//
//  DestinationTableViewCell.h
//  GPSAlarm
//
//  Created by Chris Hughes on 03/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DestinationTableViewCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *subtitleLabel;
	UISwitch *alarmSwitch;
//	UIImageView *imageView;
	NSInteger index;
}

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *subtitleLabel;
@property (nonatomic) UISwitch *alarmSwitch;
@property (nonatomic, assign) NSInteger index;
//@property (nonatomic, retain) UIImageView *imageView;

@end
