//
//  SBTableAlert.m
//  SBTableAlert
//
//  Created by Simon Blommegård on 2011-04-08.
//  Copyright 2011 Simon Blommegård. All rights reserved.
//

#import "SBTableAlert.h"
#import <QuartzCore/QuartzCore.h>
#import <dispatch/dispatch.h>

@interface SBTableAlert ()

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)format args:(va_list)args;
- (void)increaseHeightBy:(CGFloat)delta;
- (void)layout;

@end

@implementation SBTableAlert

@synthesize view=_alertView;
@synthesize tableView=_tableView;
@synthesize type=_type;
@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;


- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)format args:(va_list)args {
	if ((self = [super init])) {
		NSString *message = format ? [[[NSString alloc] initWithFormat:format arguments:args] autorelease] : nil;
		
		_alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:nil];
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		[_tableView setDelegate:self];
		[_tableView setDataSource:self];
		[_tableView setBackgroundColor:[UIColor colorWithWhite:0.90 alpha:1.0]];
		[_tableView setRowHeight:kDefaultRowHeight];
		[_tableView setSeparatorColor:[UIColor lightGrayColor]];
		_tableView.layer.cornerRadius = kTableCornerRadius;
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification *n) {
			dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue(), ^{[self layout];});
		}];
	}
	
	return self;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle messageFormat:(NSString *)message, ... {
	va_list list;
	va_start(list, message);
	self = [self initWithTitle:title cancelButtonTitle:cancelTitle messageFormat:message args:list];
	va_end(list);
	return self;
}

- (void)dealloc {
	[self setTableView:nil];
	[self setView:nil];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -

- (void)show {
	[_tableView reloadData];
	[_alertView show];
}

#pragma mark - Private

- (void)increaseHeightBy:(CGFloat)delta {
	CGPoint c = _alertView.center;
	CGRect r = _alertView.frame;
	r.size.height += delta;
	_alertView.frame = r;
	_alertView.center = c;
	_alertView.frame = CGRectIntegral(_alertView.frame);
	
	for(UIView *subview in [_alertView subviews]) {
		if([subview isKindOfClass:[UIControl class]]) {
			CGRect frame = subview.frame;
			frame.origin.y += delta;
			subview.frame = frame;
		}
	}
}


- (void)layout {
	NSInteger visibleRows = [_tableView numberOfRowsInSection:0];
	
	if (visibleRows > kNumMaximumVisibleRowsInTableView)
		visibleRows = kNumMaximumVisibleRowsInTableView;
	
	[self increaseHeightBy:(_tableView.rowHeight * visibleRows)];
	if ([_alertView message])
		[_tableView setFrame:CGRectMake(12, 75, _alertView.frame.size.width - 24, (_tableView.rowHeight * visibleRows))];
	else
		[_tableView setFrame:CGRectMake(12, 50, _alertView.frame.size.width - 24, (_tableView.rowHeight * visibleRows))];
	
	[_alertView addSubview:_tableView];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_type == SBTableAlertTypeSingleSelect)
		[_alertView dismissWithClickedButtonIndex:-1 animated:YES];
	
	if ([_delegate respondsToSelector:@selector(tableAlert:didSelectRow:)])
		[_delegate tableAlert:self didSelectRow:[indexPath row]];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	return [_dataSource tableAlert:self	cellForRow:[indexPath row]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_dataSource numberOfRowsInTableAlert:self];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertViewCancel:(UIAlertView *)alertView {
	if ([_delegate respondsToSelector:@selector(tableAlertCancel:)])
		[_delegate tableAlertCancel:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([_delegate respondsToSelector:@selector(tableAlert:clickedButtonAtIndex:)])
		[_delegate tableAlert:self clickedButtonAtIndex:buttonIndex];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	[self layout];
	if ([_delegate respondsToSelector:@selector(willPresentTableAlert:)])
		[_delegate willPresentTableAlert:self];
}
- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([_delegate respondsToSelector:@selector(didPresentTableAlert:)])
		[_delegate didPresentTableAlert:self];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([_delegate respondsToSelector:@selector(tableAlert:willDismissWithButtonIndex:)])
		[_delegate tableAlert:self willDismissWithButtonIndex:buttonIndex];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([_delegate respondsToSelector:@selector(tableAlert:didDismissWithButtonIndex:)])
		[_delegate tableAlert:self didDismissWithButtonIndex:buttonIndex];
}

@end
