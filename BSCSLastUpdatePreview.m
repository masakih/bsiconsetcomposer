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
		[imageCell setImageScaling:NSImageScaleNone];
		defauleImageCell = [[NSImageCell alloc] initImageCell:nil];
		[defauleImageCell setImageAlignment:NSImageAlignLeft];
		[defauleImageCell setImageScaling:NSImageScaleNone];
		
		NSTrackingArea *ta = [[NSTrackingArea alloc] initWithRect:frame
														  options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow
															owner:self
														 userInfo:nil];
		
		[self addTrackingArea:ta];
		[self updateImageRect];
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

enum {
	nobinobiGrow = 0,
	nobinobiShrink = 1,
};

- (void)nobinobi:(id)timer
{
	CGFloat myWidth = [self bounds].size.width;
	NSRect imageRect = self.imageRect;
	CGFloat imageWidth = imageRect.size.width;
	imageWidth += _nobinobiStatus == nobinobiGrow ? 20 : -20;
	if(imageWidth > myWidth) {
		imageWidth = myWidth;
		_nobinobiStatus = nobinobiShrink;
	}
	if(imageWidth < 150) {
		imageWidth = 150;
		_nobinobiStatus = nobinobiGrow;
	}
	imageRect.size.width = imageWidth;
	self.imageRect = imageRect;
}
- (void)mouseEntered:(NSEvent *)theEvent
{
	if(!_leftImage) return;
	
	_nobinobiTimer = [NSTimer timerWithTimeInterval:0.08
											 target:self
										   selector:@selector(nobinobi:)
										   userInfo:nil
											repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:_nobinobiTimer
							  forMode:NSDefaultRunLoopMode];
}
- (void)mouseExited:(NSEvent *)theEvent
{
	[_nobinobiTimer invalidate];
	_nobinobiTimer = nil;
}

- (void)updateImageRect
{
	NSImage *current = self.leftImage;
	if(!current) current = self.singleImage;
	if(!current) current = self.defaultImage;
	if(!current) return;
	
	CGFloat frameHeight = [self frame].size.height;
	NSRect currentRect = self.imageRect;
	currentRect.size.height = [current size].height;
	currentRect.origin.y = (frameHeight - _imageRect.size.height) / 2.0;
	self.imageRect = currentRect;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	if(_leftImage) {
		NSDrawThreePartImage([self imageRect], _leftImage, _middleImage, _rightImage, NO, NSCompositeSourceOver, 1.0, [self isFlipped]);
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

- (NSRect)imageRect
{
	if(NSEqualRects(NSZeroRect, _imageRect)) {
		_imageRect = [self bounds];
		_imageRect.size.height = 100;
	}
	return _imageRect;
}
- (void)setImageRect:(NSRect)imageRect
{
	_imageRect = imageRect;
	[self setNeedsDisplay:YES];
}

- (NSImage *)defaultImage
{
	return [defauleImageCell image];
}
- (void)setDefaultImage:(NSImage *)defaultImage
{
	[defauleImageCell setImage:defaultImage];
	[self updateImageRect];
	[self setNeedsDisplay:YES];
}
- (NSImage *)singleImage
{
	return [imageCell image];
}
- (void)setSingleImage:(NSImage *)singleImage
{
	[imageCell setImage:singleImage];
	[self updateImageRect];
	[self setNeedsDisplay:YES];
}
- (void)setLeftImage:(NSImage *)leftImage
{
	[_leftImage autorelease];
	_leftImage = [leftImage retain];
	[self updateImageRect];
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
