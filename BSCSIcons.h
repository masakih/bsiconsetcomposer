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

- (void)setImage:(NSImage *)image;
- (NSImage *)image;
- (void)setImageFileWrapper:(NSFileWrapper *)imageFileWrapper;
- (NSFileWrapper *)imageFileWrapper;
- (void)setPlaceholder:(NSImage *)placeholder;
- (NSImage *)placeholder;
- (void)setTitle:(NSString *)title;
- (NSString *)title;
- (void)setIdentifier:(NSString *)identifier;
- (NSString *)identifier;

@end
