//
//  BSCSLastUpdatePreview.m
//  BSIconSetComposer
//
//  Created by 堀 昌樹 on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSCSLastUpdatePreview.h"

@implementation BSCSLastUpdatePreview
@synthesize leftImage = _leftImage;
@synthesize middleImage = _middleImage;
@synthesize rightImage = _rightImage;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageCell = [[NSImageCell alloc] initImageCell:nil];
		[imageCell setImageAlignment:NSImageAlignLeft];
		defauleImageCell = [[NSImageCell alloc] initImageCell:nil];
		[defauleImageCell setImageAlignment:NSImageAlignLeft];
    }
    
    return self;
}
- (void)dealloc
{
	[_leftImage release];
	[_middleImage release];
	[_rightImage release];
	[imageCell release];
	[defauleImageCell release];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	if(_leftImage) {
		NSDrawThreePartImage([self bounds], _leftImage, _middleImage, _rightImage, NO, NSCompositeSourceOver, 1.0, [self isFlipped]);
		return;
	}
	if(self.singleImage) {
		[imageCell drawInteriorWithFrame:[self bounds] inView:self];
		return;
	}
	if(self.defaultImage) {
		[defauleImageCell drawInteriorWithFrame:[self bounds] inView:self];
	}
	
}
- (NSImage *)defaultImage
{
	return [defauleImageCell image];
}
- (void)setDefaultImage:(NSImage *)defaultImage
{
	[defauleImageCell setImage:defaultImage];
	[self setNeedsDisplay:YES];
}
- (NSImage *)singleImage
{
	return [imageCell image];
}
- (void)setSingleImage:(NSImage *)singleImage
{
	[imageCell setImage:singleImage];
	[self setNeedsDisplay:YES];
}
- (void)setLeftImage:(NSImage *)leftImage
{
	[_leftImage autorelease];
	_leftImage = [leftImage retain];
	[self setNeedsDisplay:YES];
}
- (void)setMiddleImage:(NSImage *)middleImage
{
	[_middleImage autorelease];
	_middleImage = [middleImage retain];
	[self setNeedsDisplay:YES];
}
- (void)setRightImage:(NSImage *)rightImage
{
	[_rightImage autorelease];
	_rightImage = [rightImage retain];
	[self setNeedsDisplay:YES];
}
@end
