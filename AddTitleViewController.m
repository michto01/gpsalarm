//
//  AddTitleViewController.m
//  GPSAlarm
//
//  Created by Chris Hughes on 11/09/2009.
//  Copyright 2009 Super Sugoi Apps. All rights reserved.
//

#import "AddTitleViewController.h"

#import "AddViewController.h"

@implementation AddTitleViewController

@synthesize titleTextField, addViewController;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	self.titleTextField = nil;
	self.addViewController = nil;
}

#pragma mark --

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[titleTextField becomeFirstResponder];		
	
	if (addViewController.updatedLocationPin.title != nil)
		titleTextField.text = addViewController.updatedLocationPin.title;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	addViewController.updatedLocationPin.title = titleTextField.text;
}

@end
