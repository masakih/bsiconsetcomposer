//
//  IconTrayInspector.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconTrayInspector.h"
#import "IconTray.h"

enum {
	kRegularFontTag = 0,
	kSmallFontTag = 1,
	kMiniFontTag = 2,
};

@implementation IconTrayInspector

- (id)init
{
    self = [super init];
    [NSBundle loadNibNamed:@"IconTrayInspector" owner:self];
    return self;
}

-(void)startEditing
{
	[self beginUndoGrouping];
    [self noteAttributesWillChangeForObject:[self object]];
}

- (void)ok:(id)sender
{
	[self startEditing];
	
	if( sender == titleLabel ) {
		[[self object] setTitle:[sender stringValue]];
	} else if( sender == identifierLabel ) {
		[[self object] setIdentifier:[sender stringValue]];
	} else if( sender == tagLabel ) {
		[[self object] setTag:[sender intValue]];
	} else if( sender == textAlignment ) {
		[[self object] setAlignment:[[sender selectedCell] tag]];
	} else if( sender == imageAlignment ) {
		[[self object] setImageAlignment:[[sender selectedCell] tag]];
	} else if( sender == imageScaling ) {
		[[self object] setImageScaling:[[sender selectedCell] tag]];
	} else if( sender == imagePosition ) {
		[[self object] setImagePosition:[[sender selectedCell] tag]];
	} else if( sender == fontSizeBotton ) {
		float size;
		switch( [[sender selectedItem] tag] ) {
			case kRegularFontTag:
				size = [NSFont systemFontSizeForControlSize:NSRegularControlSize];
				break;
			case kSmallFontTag:
				size = [NSFont systemFontSizeForControlSize:NSSmallControlSize];
				break;
			case kMiniFontTag:
				size = [NSFont systemFontSizeForControlSize:NSMiniControlSize];
				break;
			default:
				size = [NSFont systemFontSizeForControlSize:NSRegularControlSize];
				break;
		}
		[[self object] setFont:[NSFont systemFontOfSize:size]];
	}

	
    [super ok:sender];
}

- (void)revert:(id)sender
{
	IconTray *view = [self object];
	
	[titleLabel setStringValue:[view title]];
	[identifierLabel setStringValue:[view identifier]];
	[tagLabel setIntValue:[view tag]];
	
	[textAlignment selectCellWithTag:[view alignment]];
	[imageAlignment selectCellWithTag:[view imageAlignment]];
	[imageScaling selectCellWithTag:[view imageScaling]];
	[imagePosition selectCellWithTag:[view imagePosition]];
	
	// Font size
	{
		float size = [[[self object] font] pointSize];
		int tag;
		
		if( size == [NSFont systemFontSizeForControlSize:NSRegularControlSize] ) {
			tag = kRegularFontTag;
		} else if( size == [NSFont systemFontSizeForControlSize:NSSmallControlSize] ) {
			tag = kSmallFontTag;
		} else if( size == [NSFont systemFontSizeForControlSize:NSMiniControlSize] ) {
			tag = kMiniFontTag;
		} else {
			tag = kRegularFontTag;
		}
		
		[fontSizeBotton selectItemAtIndex:[fontSizeBotton indexOfItemWithTag:tag]];
	}
	
    [super revert:sender];
}

@end
