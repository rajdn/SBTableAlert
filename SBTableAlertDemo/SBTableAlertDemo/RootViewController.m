//
//  RootViewController.m
//  SBTableAlertDemo
//
//  Created by Simon Blommegård on 2011-05-30.
//  Copyright 2011 Simon Blommegård. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitle:@"SBTableAlert"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

	if ([indexPath row])
		[cell.textLabel setText:@"Single Select"];
	else
		[cell.textLabel setText:@"Multiple Select"];
		
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SBTableAlert *alert;
	if ([indexPath row]) {
		alert	= [[SBTableAlert alloc] initWithTitle:@"Single Select" cancelButtonTitle:@"Cancel" messageFormat:nil];
	} else {
		alert	= [[SBTableAlert alloc] initWithTitle:@"Multiple Select" cancelButtonTitle:@"Cancel" messageFormat:@"Select multiple rows!"];
		[alert setType:SBTableAlertTypeMultipleSelct];
		[alert.view addButtonWithTitle:@"OK"];
	}
	
	[alert setDelegate:self];
	[alert setDataSource:self];
	
	[alert show];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark - SBTableAlertDataSource

- (UITableViewCell *)tableAlert:(SBTableAlert *)tableAlert cellForRow:(NSInteger)row {
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
	
	[cell.textLabel setText:[NSString stringWithFormat:@"Cell %i", row]];
	
	return cell;
}

- (NSInteger)numberOfRowsInTableAlert:(SBTableAlert *)tableAlert {
	if (tableAlert.type == SBTableAlertTypeSingleSelect)
		return 3;
	else
		return 10;
}

#pragma mark - SBTableAlertDelegate

- (void)tableAlert:(SBTableAlert *)tableAlert didSelectRow:(NSInteger)row {
	if (tableAlert.type == SBTableAlertTypeMultipleSelct) {
		UITableViewCell *cell = [tableAlert.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
		if (cell.accessoryType == UITableViewCellAccessoryNone)
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		else
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		[tableAlert.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES];
	}
}

- (void)tableAlert:(SBTableAlert *)tableAlert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"Dismissed: %i", buttonIndex);
	
	[tableAlert release];
}

@end
