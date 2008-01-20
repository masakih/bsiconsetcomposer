//
//  IconTrayIBPluginInspector.m
//  IconTray3
//
//  Created by Hori,Masaki on 08/01/17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IconTrayIBPluginInspector.h"

@implementation IconTrayIBPluginInspector

- (NSString *)viewNibName {
	return @"IconTrayIBPluginInspector";
}

- (void)refresh {
	// Synchronize your inspector's content view with the currently selected objects.
	[super refresh];
}

@end
