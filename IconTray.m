//
//  IconTray.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/06/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "IconTray.h"

#import "TemporaryFolder.h"

@interface NSImageView (IconTrayDummy)
-(void)copy:(id)sender;
@end

@implementation IconTray

-(id)initWithFrame:(NSRect)frameRect
{
	if( self = [super initWithFrame:frameRect] ) {
		highlited = NO;
	}
	
	return self;
}

-(void)drawRect:(NSRect)rect
{
	if( selected && [[self window] isKeyWindow] ) {
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingAbove);
		[[NSColor secondarySelectedControlColor] set];
		[super drawRect:rect];
		[NSGraphicsContext restoreGraphicsState];
	} else {
		[super drawRect:rect];
	}
	
	if( highlited ) {
		[[NSColor selectedControlColor] set];
		NSFrameRectWithWidth( [self visibleRect], 2 );
	}
}

-(void)setSelected:(BOOL)flag
{
	NSRect updateRect;
	
	selected = flag;

	// フォーカスリングのゴミを消すため大きめに再描画
	updateRect = NSInsetRect([self frame],-2,-2);
	[[self superview] setNeedsDisplayInRect:updateRect];
}
-(void)setHighlite:(BOOL)flag
{	
	highlited = flag;
	
	[self setNeedsDisplay:YES];
}

-(BOOL)setImage:(NSImage *)image ofFile:(NSString *)imageFileName
{
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:willChangeFileOfImage:)]
		&& ![delegate iconTray:self willChangeFileOfImage:imageFileName] ) {
		return NO;
	}
	[self setImage:image];
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:didChangeFileOfImage:)] ) {
		
		[delegate iconTray:self didChangeFileOfImage:imageFileName];
	}
	
	return YES;
}
BOOL createTemporaryImageFile( NSData *inImageData,
							   NSString *inFilename,
							   NSImage **outImage,
							   NSString **outFullPath )
{
	TemporaryFolder *tmp =[TemporaryFolder temporaryFolder];
	
	*outImage = [[[NSImage alloc] initWithData:inImageData] autorelease];
	if( !*outImage ) {
		*outFullPath = nil;
		return NO;
	}
	
	*outFullPath = [tmp path];
	*outFullPath = [*outFullPath stringByAppendingPathComponent:inFilename];
	if( ![inImageData writeToFile:*outFullPath atomically:NO] ) {
		*outFullPath = nil;
		*outImage = nil;
		return NO;
	}
	
	return YES;
}	
-(BOOL)setImageFromPasteboard:(NSPasteboard *)pasteboard
{
	NSArray *paths = nil;
	NSString *imagePath;
	NSImage *image = nil;
	NSArray *pbTypes;
		
	pbTypes = [pasteboard types];
	
	if( [pbTypes containsObject:NSFilenamesPboardType] ) {
		paths = [pasteboard propertyListForType:NSFilenamesPboardType];
		imagePath = [paths objectAtIndex:0];
		
		image = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
	} else if( [pbTypes containsObject:NSTIFFPboardType] ) {
		NSData *data;		
		
		data = [pasteboard dataForType:NSTIFFPboardType];
		if( !createTemporaryImageFile( data, @"temp.tiff", &image, &imagePath ) ) {
			image = nil;
			imagePath = nil;
		}
	} else if( [pbTypes containsObject:NSURLPboardType] ) {
		NSURL *pathURL;
		NSString *filename;
		NSString *lowerExtension;
		NSData *data;
		
		paths = [pasteboard propertyListForType:NSURLPboardType];
		if( ![paths isKindOfClass:[NSArray class]] ) return NO;
		
		pathURL = [NSURL URLWithString:[paths objectAtIndex:0]];
		if( !pathURL ) return NO;
		
		filename = [[pathURL path] lastPathComponent];
		lowerExtension = [[filename pathExtension] lowercaseString];
		if( ![[NSImage imageFileTypes] containsObject:lowerExtension] ) return NO;
		
		data = [pathURL resourceDataUsingCache:YES];
		if( !data ) return NO;
		
		if( !createTemporaryImageFile( data, filename, &image, &imagePath ) ) {
			imagePath = nil;
			image = nil;
		}
	}
	
	if( image ) {
		return [self setImage:image ofFile:imagePath];
	}
	
	return NO;
}
-(void)removeImage
{
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTrayWillRemoveImage:)]
		&& ![delegate iconTrayWillRemoveImage:self] ) {
		return;
	}
	[self setImage:nil];
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTrayDidRemoveImage:)] ) {
		
		[delegate iconTrayDidRemoveImage:self];
	}
}

-(void)awakeFromNib
{
	[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
	
	[self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
}

-(void)setDelegate:(id)inDelegate
{
	delegate = inDelegate;
}
-(id)delegate
{
	return delegate;
}

#pragma mark-
#pragma mark ### NSResponder methods ###
- (void)mouseDown:(NSEvent *)theEvent
{
	[[self window] makeFirstResponder:self];
}
- (void)keyDown:(NSEvent *)theEvent
{
	if( [theEvent isARepeat] ) return;
	
	if( NSDeleteCharacter == [[theEvent characters] characterAtIndex:0] ) {
		[self removeImage];
	}
}
- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)becomeFirstResponder
{
	[self setSelected:YES];
	
	return YES;
}
- (BOOL)resignFirstResponder
{
	[self setSelected:NO];
	
	return YES;
}
- (BOOL)canBecomeKeyView
{
	return YES;
}

#pragma mark-
#pragma mark ### Actions ###
-(IBAction)cut:(id)sender
{
	[self copy:sender];
	[self delete:sender];
}
-(IBAction)copy:(id)sender
{
	[super copy:sender];
}
-(IBAction)paste:(id)sender
{
	if( ![self setImageFromPasteboard:[NSPasteboard generalPasteboard]] ) {
		NSBeep();
	}
}
-(IBAction)delete:(id)sender
{
	[self removeImage];
}

-(NSArray *)acceptPasteTypes
{
	return [NSArray arrayWithObjects:
		NSFilenamesPboardType,
		NSFilesPromisePboardType,
		NSURLPboardType,
		NSTIFFPboardType,
		nil];
}
-(BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	SEL action = [menuItem action];
	
	if( action == @selector(paste:) ) {
		NSPasteboard *pb = [NSPasteboard generalPasteboard];
		NSString *availableType = [pb availableTypeFromArray:[self acceptPasteTypes]];
		
		if( availableType != nil && ![availableType isEqualTo:NSURLPboardType] ) {
			return YES;
		} else if( [availableType isEqualTo:NSURLPboardType] ) {
			NSArray *paths;
			NSString *path;
			NSString *lowerExtension;
			
			paths = [pb propertyListForType:NSURLPboardType];
			if( ![paths isKindOfClass:[NSArray class]] ) return NO;
			
			path = [paths objectAtIndex:0];
			if( !path ) return NO;
			
			lowerExtension = [[[path lastPathComponent] pathExtension] lowercaseString];
			if( ![[NSImage imageFileTypes] containsObject:lowerExtension] ) return NO;
		} else {
			return NO;
		}
	}
	
	return YES;
}

#pragma mark-
#pragma mark ### Dragging ###
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{	
	[self setHighlite:YES];
	
	return NSDragOperationGeneric;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self setHighlite:NO];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	[self setHighlite:NO];
	
	return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb;
	NSArray *paths;
	NSString *path;
	NSImage *image = nil;
	NSArray *types;
	
	//	NSLog(@"Enter %@.", NSStringFromSelector(_cmd));
	
	pb = [sender draggingPasteboard];
	types = [pb types];
	
	if( [types containsObject:NSFilesPromisePboardType] ) {
		TemporaryFolder *tmp = [TemporaryFolder temporaryFolder];
		paths = [sender namesOfPromisedFilesDroppedAtDestination:[tmp url]];
		path = [paths objectAtIndex:0];
		
		path = [[tmp path] stringByAppendingPathComponent:path];
		image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	}
	
	// image が nil ならべつのタイプを試みる。
	if( !image ) {
		return [self setImageFromPasteboard:pb];
	} else {
		return [self setImage:image ofFile:path];
	}
	
	return NO;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setHighlite:NO];
}

@end
