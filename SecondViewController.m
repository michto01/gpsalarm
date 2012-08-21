//
//  SecondViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 27/08/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "AddViewController.h"
#import "GPSAlarmAppDelegate.h"
#import "AlarmModel.h"
#import "DestinationTableViewCell.h"
#import "DistanceModel.h"

@implementation SecondViewController

@synthesize destinationTable, navItem;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navItem.leftBarButtonItem = [self editButtonItem];
	
	[destinationTable setAllowsSelectionDuringEditing:YES];
	[destinationTable setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    DLog(@"SecondViewController - viewWillAppear");
	[super viewWillAppear:animated];
	[destinationTable reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	if (self.editing == YES)
		[self setEditing:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.destinationTable = nil;
	self.navItem = nil;
}


- (AlarmModel *)alarmModel {
	return [AlarmModel sharedInstance];
}

#pragma mark UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.alarmModel.pinArray count];
}

- (void)cellSwitchAction:(id)sender {
	UISwitch *alarmSwitch = (UISwitch *)sender;
	
	// Nasty hack
	for (DestinationTableViewCell *cell in [destinationTable visibleCells]) {
		if (alarmSwitch == [cell alarmSwitch]) {
			[self.alarmModel alarmOn:[alarmSwitch isOn] withIndex:[cell index]];
			[self.destinationTable reloadData];
			return;
		}
	}	
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self isEditing])
		return UITableViewCellEditingStyleDelete;
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DestinationViewCell_ID";

    DestinationTableViewCell *cell = (DestinationTableViewCell *)[destinationTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[DestinationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell.alarmSwitch addTarget:self action:@selector(cellSwitchAction:) forControlEvents:UIControlEventValueChanged];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
	LocationPin *pin = [self.alarmModel.pinArray objectAtIndex:indexPath.row];
	cell.titleLabel.text = [pin title];
	cell.subtitleLabel.text = [NSString stringWithFormat:@"Proximity %@", [DistanceModel getDistanceStringForType:[pin distanceType]]];
	[cell.alarmSwitch setOn:[pin alarmOn] animated:NO];
	cell.index = indexPath.row;

    return cell;
}

- (void)pushEditController:(LocationPin *)editPin {
	AddViewController *controller = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
	controller.delegate = self;
	if (editPin != nil) {
		controller.editLocationPin = editPin;
		controller.updatedLocationPin = [editPin copy];	
	}
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AddViewController *controller = [[AddViewController alloc] initWithNibName:@"AddViewController" bundle:nil];
	controller.delegate = self;

	[self pushEditController:[self.alarmModel.pinArray objectAtIndex:indexPath.row]];
}

// Override to support conditional editing of the table view.
/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}*/

/*- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
 */

/*
 * Disable the ability to move rows ... for now
 *
 
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	LocationPin *pin = [self.alarmModel.pinArray objectAtIndex:fromIndexPath.row];

	[pin retain];
	[self.alarmModel.pinArray removeObjectAtIndex:fromIndexPath.row];
	[self.alarmModel.pinArray insertObject:pin atIndex:toIndexPath.row];
	[pin release];
}
 */

#pragma mark UIViewController

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    // Updates the appearance of the Edit|Done button as necessary.
    [super setEditing:editing animated:YES];
    [destinationTable setEditing:editing animated:YES];
	
    // Disable the add button while editing.
    if (editing) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {     // If row is deleted, remove it from the list.
		[self.alarmModel.pinArray removeObjectAtIndex:indexPath.row];
		
		// Animate the deletion from the table.
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

#pragma mark IBActions

- (IBAction)addDestination:(id)sender {	
	[self pushEditController:nil];
}

- (IBAction)editAction:(id)sender {
	[destinationTable setEditing:YES animated:YES];
}

#pragma mark AddViewController Delegate

- (void)AddViewController:(AddViewController *)addViewController didDismissWithSave:(BOOL)save {
	LocationPin *pin = [addViewController updatedLocationPin];
	if (save == YES) {
		LocationPin *editPin = [addViewController editLocationPin];
		if (editPin != nil) {		// Replace existing 
			NSInteger index = [self.alarmModel.pinArray indexOfObject:editPin];
			NSAssert(index != NSNotFound, @"Error: addViewController:didDismissWithSave: - index of editPin not found!");
			[self.alarmModel.pinArray replaceObjectAtIndex:index withObject:pin];
		} else {					// Add new
			[self.alarmModel.pinArray addObject:pin];
		}
		[destinationTable reloadData];

		// Force a save of our state (in case we crash later)
		[[AlarmModel sharedInstance] saveState];
	}
	[self dismissModalViewControllerAnimated:YES];
}

@end
