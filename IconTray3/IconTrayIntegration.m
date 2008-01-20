//
//  IconTray.m
//  IconTray3
//
//  Created by Hori,Masaki on 08/01/17.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import <IconTray/IconTray.h>
#import "IconTrayIBPluginInspector.h"

@interface IconTray (IconTrayPalettePrivate)
-(NSRect)titleRect;
-(NSRect)imageRect;
@end

@implementation IconTray ( IconTray )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];
	
	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
    [classes addObject:[IconTrayIBPluginInspector class]];
}

//- (NSView *)ibDesignableContentView
//{
//	return self;
//}

//- (void)ibDidAddToDesignableDocument:(IBDocument *)document
//{
//	NSLog(@"self -> %@", self);
//	NSLog(@"doc -> %@", document);
//	NSLog(@"objects -> %@", [document objects]);
//	
//	[document addObject:[[[NSImageCell alloc] initImageCell:nil] autorelease]
//			   toParent:self];
//}

-(void)drawInPalette
{
	NSRect imageCellRect = [self imageRect];
	
	{
		NSColor *color;
		
		color = [NSColor selectedKnobColor];
		color = [color colorWithAlphaComponent:0.5];
		[color set];
		[NSBezierPath fillRect:NSInsetRect( imageCellRect, 2, 2 )];
		
		[[NSColor whiteColor] set];
		NSFrameRect( NSInsetRect( imageCellRect, 1, 1 ) );
		
		[[NSColor lightGrayColor] set];
		NSFrameRect( imageCellRect );
	}
	
	// draw size string.
	{
		NSSize messageSize;
		NSRect drawingRect;
		
		NSString *sizeString = [NSString stringWithFormat:@"%.0fpx %C %.0fpx",
								imageCellRect.size.width, 0x00D7, imageCellRect.size.height];
		NSFont *font = [NSFont labelFontOfSize:[NSFont labelFontSize]];
		
		NSDictionary *messageAttr;
		NSAttributedString *messageString;
		
		messageAttr = [NSDictionary dictionaryWithObjectsAndKeys:
					   font ,NSFontAttributeName,
					   [NSColor whiteColor], NSForegroundColorAttributeName,
					   nil];
		messageString = [[[NSAttributedString alloc] initWithString:sizeString 
														 attributes:messageAttr] autorelease];
		messageSize = [messageString size];
		
		drawingRect = imageCellRect;
		drawingRect.origin.x += imageCellRect.size.width * 0.5 - messageSize.width * 0.5;
		if( [self isFlipped] ) {
			drawingRect.origin.y += imageCellRect.size.height * 0.5 + messageSize.height * 0.5;
		} else {
			drawingRect.origin.y += imageCellRect.size.height * 0.5 - messageSize.height * 0.5;
		}
		drawingRect.size = messageSize;
		
		[messageString drawInRect:drawingRect];
	}
}

/* Returns the baseline count, and provides access to the baselines by index. */
- (int)ibBaselineCount
{
	return 1;
}
- (float)ibBaselineAtIndex:(int)index
{
	NSRect titleRect;
	float baseline;
	
	if( index != 0 ) return 0;
	
	titleRect = [self titleRect];
	
	baseline = titleRect.origin.y;
	if( [self isFlipped] ) {
		baseline += [[self font] descender];
	} else {
		baseline -= [[self font] descender];
	}
	
	return baseline;
}

@end

