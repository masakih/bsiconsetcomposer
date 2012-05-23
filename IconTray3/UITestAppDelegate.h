//
//  UITestAppDelegate.h
//  IconTray3
//
//  Created by Hori,Masaki on 12/05/23.
//  Copyright 2012 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IconTray/IconTray.h>

@interface UITestAppDelegate : NSObject
{
	IBOutlet NSWindow *window;
	IBOutlet NSObjectController *controller;
	NSMutableDictionary *dict;
	
	IBOutlet IconTray *tray;
	IBOutlet NSTextField *titleField;
}
- (IBAction)applyTitle:(id)sender;

@end
