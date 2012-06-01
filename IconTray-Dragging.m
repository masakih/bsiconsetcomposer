//
//  IconTray-Dragging.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import <IconTray/IconTray.h>

#import "TemporaryFolder.h"

@interface IconTray(DraggingPrivate)
-(NSArray *)acceptPasteTypes;
@end

@implementation IconTray(Dragging)
- (TemporaryFolder *)temporaryFolder
{
	static TemporaryFolder *_sTemp = nil;
	if(_sTemp) return _sTemp;
	
	_sTemp = [[TemporaryFolder alloc] init];
	return _sTemp;
}
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
	id oldImage = [self image];
	NSPasteboard *pb = [sender draggingPasteboard];
	NSArray *types = [pb types];
	
	if([types containsObject:NSFilesPromisePboardType]) {
		TemporaryFolder *tmp = [self temporaryFolder];
		NSArray *paths = [sender namesOfPromisedFilesDroppedAtDestination:[tmp url]];
		NSString *path = [paths objectAtIndex:0];
		
		path = [[tmp path] stringByAppendingPathComponent:path];
		[self setImageFilePath:path];
		if([self image] != oldImage) return YES;
	}
	
	[self setImageFromPasteboard:pb];
	return [self image] != oldImage;
}
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setHighlighted:NO];
}

@end
