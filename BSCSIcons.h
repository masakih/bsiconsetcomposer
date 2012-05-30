//
//  BSCSIcons.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 07/03/11.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSCSIcons : NSObject <NSCopying>
{
	NSImage *image;
	NSFileWrapper *imageFileWrapper;
	NSImage *placeholder;
	NSString *title;
	NSString *identifier;
}
@property (retain, nonatomic) NSImage *image;
@property (retain, nonatomic) NSFileWrapper *imageFileWrapper;
@property (retain, nonatomic) NSImage *placeholder;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *identifier;

@end
