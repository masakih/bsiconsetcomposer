//
//  UITestAppDelegate.m
//  IconTray3
//
//  Created by Hori,Masaki on 12/05/23.
//  Copyright 2012 masakih. All rights reserved.
//

#import "UITestAppDelegate.h"


@implementation UITestAppDelegate
- (void)awakeFromNib
{
	dict = [[NSMutableDictionary alloc] init];
	[controller setContent:dict];
}

- (IBAction)applyTitle:(id)sender
{
	NSString *title = [titleField stringValue];
	[tray setTitle:title];
}
@end
