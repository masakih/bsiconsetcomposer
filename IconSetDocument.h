//
//  IconSetDocument.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/07/10.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "AbstractIconSet.h"
#import "ColorSet.h"

@interface IconSetDocument : NSDocument
{
	IBOutlet ToolbarIconSet* toolbarIconSet;
	IBOutlet BoardListIconSet* boardListIconSet;
	IBOutlet ThreadListIconSet* threadListIconSet;
	IBOutlet ThreadIconSet* threadIconSet;
	
	IBOutlet id colorSet;
	
	IBOutlet NSTabView *tab;
	
	NSFileWrapper *wrapper;
}

-(void)setPath:(NSString *)path forIdentifier:(NSString *)identifier;
-(void)setPlist:(id)plist forIdentifier:(NSString *)identifier;

-(IBAction)apply:(id)sender;
-(IBAction)applyAndRestartBathyScaphe:(id)sender;

-(void)updateAll;
-(void)updateForKey:(NSString *)key;
-(void)setupDefault;

@end
