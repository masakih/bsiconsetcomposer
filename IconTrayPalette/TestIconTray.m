//
//  TestIconTray.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TestIconTray.h"

#import "IconTray.h"

@implementation TestIconTray

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSString *path;
	NSImage *iconTrayImage;
	
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"IconTray" ofType:@"tiff"];
	iconTrayImage = [[NSImage alloc] initByReferencingFile:path];
	
	[k setPlaceholderImage:iconTrayImage];
}

@end
