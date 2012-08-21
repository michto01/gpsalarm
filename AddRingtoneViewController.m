//
//  AddRingtoneViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import "AddRingtoneViewController.h"

#import "AddViewController.h"
#import "RingtoneModel.h"

@implementation AddRingtoneViewController

@synthesize addViewController, ringtoneTitleArray;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	RingtoneModel *rm = [RingtoneModel sharedInstance];
	self.ringtoneTitleArray = [rm.ringtoneDict allKeys];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.addViewController = nil;
	self.ringtoneTitleArray = nil;
}



#pragma mark --

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	RingtoneModel *rm = [RingtoneModel sharedInstance];	
	[rm stopOncePlayer];
}


#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if (section == 0) 
		return 1;
	RingtoneModel *rm = [RingtoneModel sharedInstance];
	return [[rm ringtoneDict] count];
}

- (UITableViewCell *)tableView:(UITableView *)tV cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseId = @"ringtoneID";
	
	UITableViewCell *cell = [tV dequeueReusableCellWithIdentifier:reuseId];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
		cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];	
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;			
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (indexPath.section == 1) {
		if ([ringtoneTitleArray indexOfObject:addViewController.updatedLocationPin.ringtoneTitle] == indexPath.row)
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textLabel.text = [ringtoneTitleArray objectAtIndex:indexPath.row];
	} else {
		if (addViewController.updatedLocationPin.ringtoneTitle == nil)
			cell.accessoryType = UITableViewCellAccessoryCheckmark;			
		cell.textLabel.text = NSLocalizedString(@"None", @"None ringtone");
	}
	return cell;
}

- (void)tableView:(UITableView *)tV didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tV deselectRowAtIndexPath:indexPath animated:YES];

	RingtoneModel *rm = [RingtoneModel sharedInstance];	
	if (indexPath.section == 1) {
		NSString *title = [ringtoneTitleArray objectAtIndex:indexPath.row];
		addViewController.updatedLocationPin.ringtoneTitle = title;
		[rm playOnceWithRingtone:title];
	} else {
		addViewController.updatedLocationPin.ringtoneTitle = nil;
		[rm stopOncePlayer];
	}
	[tV reloadData];
}

@end
