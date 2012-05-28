//
//  BSCSLastUpdatePreview.h
//  BSIconSetComposer
//
//  Created by 堀 昌樹 on 12/05/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSCSLastUpdatePreview : NSView
{
	NSRect _imageRect;
	NSTimer *_nobinobiTimer;
	NSInteger _nobinobiStatus;
	
	NSImage *_leftImage;
	NSImage *_middleImage;
	NSImage *_rightImage;
	
	NSImageCell *imageCell;
	NSImageCell *defauleImageCell;
}
@property NSRect imageRect;

@property (retain, nonatomic) NSImage *defaultImage;

@property (retain, nonatomic) NSImage *singleImage;
@property (retain, nonatomic) NSImage *leftImage;
@property (retain, nonatomic) NSImage *middleImage;
@property (retain, nonatomic) NSImage *rightImage;
@end
