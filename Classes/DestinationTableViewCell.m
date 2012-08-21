//
//  DestinationTableViewCell.m
//  GPSAlarm
//
//  Created by Chris Hughes on 03/09/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DestinationTableViewCell.h"

@implementation DestinationTableViewCell

@synthesize titleLabel, alarmSwitch, index, subtitleLabel; // , imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		CGRect contentRect = [self.contentView bounds];
		
		self.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
		
		CGRect frame = CGRectMake(contentRect.origin.x + 15.0f, contentRect.origin.y + 19.0f, 175.0f, 22.0f);
		titleLabel = [[UILabel alloc] initWithFrame:frame];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.shadowColor = [UIColor whiteColor];
		titleLabel.shadowOffset = CGSizeMake(0,1);
		titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
		[self.contentView addSubview:titleLabel];
		
		frame = CGRectMake(contentRect.origin.x + 15.0f, contentRect.origin.y + 43.0f, 170.0f, 18.0f);
		subtitleLabel = [[UILabel alloc] initWithFrame:frame];
		subtitleLabel.textColor = [UIColor darkGrayColor];
		subtitleLabel.backgroundColor = [UIColor clearColor];
		subtitleLabel.shadowColor = [UIColor whiteColor];
		subtitleLabel.shadowOffset = CGSizeMake(0,1);
		subtitleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];		
		[self.contentView addSubview:subtitleLabel];
	
/*		UIImage *speakerImage = [UIImage imageNamed:@"SpeakerIcon-20x20.png"];
		frame = CGRectMake(contentRect.origin.x + 170.0f, contentRect.origin.y + 19.0f, 20.0f, 20.0f);
		imageView = [[UIImageView alloc] initWithFrame:frame];
		imageView.image = speakerImage;
		[self.contentView addSubview:imageView];
 */
		
		frame = CGRectMake(contentRect.origin.x + 195.0f, contentRect.origin.y + 26.0f, 94.0f, 27.0f);
		alarmSwitch = [[UISwitch alloc] initWithFrame:frame];
		[self.contentView addSubview:alarmSwitch];

		[alarmSwitch setOn:NO animated:NO]; // Default to off

		index = -1;
    }
    return self;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	}
	if (editing == YES) {
		alarmSwitch.alpha = 0.0f;
		
	} else {
		alarmSwitch.alpha = 1.0f;		
	}
	if (animated) 
		[UIView commitAnimations];
}




@end
