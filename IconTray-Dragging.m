//
//  IconTray-Dragging.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconTray/IconTray.h"

#import "TemporaryFolder.h"

@interface IconTray(DraggingPrivate)
-(NSArray *)acceptPasteTypes;
@end

@implementation IconTray(Dragging)
-(void)registDraggedTypes
{
	[self registerForDraggedTypes:[self acceptPasteTypes]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{	
	[self setHighlighted:YES];
	
	return NSDragOperationGeneric;
}
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self setHighlighted:NO];
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	[self setHighlighted:NO];
	
	return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb;
	NSArray *paths;
	NSString *path;
	NSImage *aImage = nil;
	NSString *imageName = nil;
	NSArray *types;
	
	//	NSLog(@"Enter %@.", NSStringFromSelector(_cmd));
	
	pb = [sender draggingPasteboard];
	types = [pb types];
	
	if( [types containsObject:NSFilesPromisePboardType] ) {
		TemporaryFolder *tmp = [TemporaryFolder temporaryFolder];
		paths = [sender namesOfPromisedFilesDroppedAtDestination:[tmp url]];
		path = [paths objectAtIndex:0];
		
		path = [[tmp path] stringByAppendingPathComponent:path];
		aImage = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
		imageName = [path lastPathComponent];
	}
	
	// image が nil ならべつのタイプを試みる。
	if( !aImage ) {
		return [self setImageFromPasteboard:pb];
	} else {
		return [self setImage:aImage withName:imageName];
	}
	
	return NO;
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setHighlighted:NO];
}

@end
