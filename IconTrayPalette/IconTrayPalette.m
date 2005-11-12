//
//  IconTrayPalette.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconTrayPalette.h"

NSTextField *_fieldEditor = nil;

@implementation IconTrayPalette

- (void)finishInstantiate
{
    /* `finishInstantiate' can be used to associate non-view objects with
     * a view in the palette's nib.  For example:
     *   [self associateObject:aNonUIObject ofType:IBObjectPboardType
     *                withView:aView];
     */
#ifdef DEBUG	
	NSString *path;
	NSImage *iconTrayImage;
	
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"IconTray" ofType:@"tiff"];
	iconTrayImage = [[NSImage alloc] initByReferencingFile:path];
	
	[iconTray setImage:iconTrayImage];
#endif
	[iconTray setTitle:@"IconTray"];
	
	_fieldEditor = editor;
}

+(NSTextField *)fieldEditor
{
	return _fieldEditor;
}

@end
@interface IconTray (IconTrayPalettePrivate)
-(NSRect)titleRect;
-(NSRect)imageRect;
@end
@implementation IconTray (IconTrayPalette)
static inline NSView *topView( NSView *inView )
{
	NSView *view;
	NSView *superview = nil;
	
	view = inView;
	while( (superview = [view superview]) ) {
		view = superview;
	}
	
	return view;
}
static inline NSPoint iboffset( NSView *inView )
{	
	return [topView( inView ) frame].origin;
}
	
- (BOOL)canEditSelf
{
	return YES;
}
- (void)editSelf:(NSEvent *)theEvent in:(NSView<IBEditors>*)viewEditor
{
	NSPoint mouse = [theEvent locationInWindow];
	NSPoint offset = iboffset( self );
	
	mouse.x += offset.x; mouse.y += offset.y;
	mouse = [self convertPoint:mouse fromView:nil];
	
	if( NSPointInRect( mouse, [self titleRect] ) ) {
		NSTextField *e;
		NSPoint p;
		
//		NSLog(@"Track Title");
		
		e = [IconTrayPalette fieldEditor];
		
		[e setHidden:YES];
		[viewEditor addSubview:e];
		
		[e setFont:[self font]];
		[e setAlignment:[self alignment]];
		
		[e sizeToFit];
		
		p = [self frame].origin;
		p.y += [self titleRect].origin.y;
		[e setFrameOrigin:p];
		[e setFrameSize:NSMakeSize( [self titleRect].size.width, [e frame].size.height )];
		
		[e setStringValue:[self title]];
		[e setDelegate:self];
		[e setHidden:NO];
		[[viewEditor window] makeFirstResponder:e];
		
	}
}
- (void)controlTextDidEndEditing:(NSNotification *)notification
{
	NSLog(@"End Deiting" );
	
	id obj = [notification object];
	if( ![obj isKindOfClass:[NSTextField class]] ) {
		NSLog(@"### Object MUST be NSTextField class or subclass. but Object is %@", NSStringFromClass([obj class]));
		return;
	}
	
	[self setTitle:[obj stringValue]];
	[obj removeFromSuperview];
	[[(id <IBEditors>)[obj superview] document] touch];
	[(id <IBEditors>)[obj superview] resetObject:self];
}

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
- (NSString *)nibLabel:(NSString*)objectName
{
    return [NSString stringWithFormat:@"%@ (%@)", NSStringFromClass([self class]), [self title]];
}
- (int)ibNumberOfBaseLine
{
	return 1;
}
- (float)ibBaseLineAtIndex:(int)index
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
@implementation IconTray (IconTrayPaletteInspector)

- (NSString *)inspectorClassName
{
    return @"IconTrayInspector";
}

@end

@implementation IconTrayPalette (DraggingDelegate)

- (NSArray *)viewResourcePasteboardTypes
{
	return [NSArray arrayWithObject:NSTIFFPboardType];
}
- (BOOL)acceptsViewResourceFromPasteboard:(NSPasteboard *)pasteboard
								forObject:(id)object
								  atPoint:(NSPoint)point
{
	return NO;
}
- (void)depositViewResourceFromPasteboard:(NSPasteboard *)pasteboard
								 onObject:(id)object
								  atPoint:(NSPoint)point
{
	//
}
- (BOOL)shouldDrawConnectionFrame
{
	return NO;
}

@end