//
//  AddViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddViewController.h"
#import "LocationPin.h"
#import "LocationProximity.h"
#import "LocationProximityView.h"
#import "DistanceModel.h"
#import "MapViewAdditions.h"
#import "LocationController.h"
#import "AddMapViewController.h"
#import "AddTitleViewController.h"
#import "AddRingtoneViewController.h"

@implementation AddViewController

@synthesize titleTextField, saveButton, delegate;
@synthesize editLocationPin, updatedLocationPin, tableView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",@"CancelButtonTitle") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction:)];	
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save",@"SaveButtonTitle") style:UIBarButtonItemStyleBordered target:self action:@selector(saveAction:)];
	self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.titleTextField = nil;
	self.saveButton = nil;
}


#pragma mark --

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (updatedLocationPin == nil)
		updatedLocationPin = [[LocationPin alloc] init];

	[tableView reloadData];
	
	[self updateSaveButton];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

#pragma mark - internal

- (void)updateSaveButton {
	if ([[updatedLocationPin title] length] > 0 && [updatedLocationPin coordinateIsValid] == YES)
		saveButton.enabled = YES;
	else 
		saveButton.enabled = NO;
}

#pragma mark IBActions

- (void)cancelAction:(id)sender {
	[[self delegate] AddViewController:self didDismissWithSave:NO];
}

- (void)saveAction:(id)sender {
	[[self delegate] AddViewController:self didDismissWithSave:YES];	
}

#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tV cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	switch (indexPath.row) {
		case 0:
			cell = [tableView dequeueReusableCellWithIdentifier:@"titleCellID"];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"titleCellID"];
				cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];	
			}
			cell.textLabel.text = NSLocalizedString(@"Title", @"AddPin-Title");
			cell.detailTextLabel.text = [updatedLocationPin title];
			break;
		case 1:
			cell = [tableView dequeueReusableCellWithIdentifier:@"ringtoneCellID"];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ringtoneCellID"];
				cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];	
			}
			cell.textLabel.text = NSLocalizedString(@"Ringtone", @"AddPin-Ringtone");
			cell.detailTextLabel.text = [updatedLocationPin ringtoneTitle];
			break;
		case 2:
			cell = [tableView dequeueReusableCellWithIdentifier:@"locationCellID"];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locationCellID"];
				cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];	
			}
			cell.textLabel.text = NSLocalizedString(@"Location", @"AddPin-Location");
			cell.detailTextLabel.text = nil;
			break;
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tV didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AddMapViewController *mapController;
	AddTitleViewController *titleController;
	AddRingtoneViewController *ringtoneController;
	
	[tV deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.row) {
		case 0:
			titleController = [[AddTitleViewController alloc] initWithNibName:@"AddTitleViewController" bundle:nil];
			titleController.addViewController = self;
			[[self navigationController] pushViewController:titleController animated:YES];
			break;
		case 1:
			ringtoneController = [[AddRingtoneViewController alloc] initWithNibName:@"AddRingtoneViewController" bundle:nil];
			ringtoneController.addViewController = self;
			[[self navigationController] pushViewController:ringtoneController animated:YES];
			break;
		case 2:
			mapController = [[AddMapViewController alloc] initWithNibName:@"AddMapViewController" bundle:nil];
			mapController.addViewController = self;
			[[self navigationController] pushViewController:mapController animated:YES];
			break;
	}
}


@end
