//
//  IconTray.h
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IconTray : NSControl
{
//	NSImageCell *imageCell;
	NSTextFieldCell *titleCell;
	NSString *identifier;
	NSImage *image;
	NSImage *placeholderImage;
	
	id delegate;
	
	NSCellImagePosition imagePosition;
	int isHighlighted;
	
	// binding.
	id bindKeyPathDict;
	id bindControllerDict;
}

-(id)delegate;
-(void)setDelegate:(id)delegate;

-(NSImage *)image;
-(NSString *)imageName;
-(NSFileWrapper *)imageFileWrapper;
-(BOOL)setImageFileWrapper:(NSFileWrapper *)imageFileWrapper;
-(BOOL)setImageFilePath:(NSString *)imageFilePath;
-(BOOL)setImage:(NSImage *)image;
-(BOOL)setImageName:(NSString *)imageName;
-(BOOL)setImage:(NSImage *)image withName:(NSString *)imageName; // with extension.
-(BOOL)setImageFromPasteboard:(NSPasteboard *)pasteboard;
-(NSString *)title;
-(void)setTitle:(NSString *)title;
-(NSString *)identifier;
-(void)setIdentifier:(NSString *)identifier;

-(NSImage *)placeholderImage;
-(void)setPlaceholderImage:(NSImage *)placeholder;

-(BOOL)isHighlighted;
-(void)setHighlighted:(BOOL)flag;

- (NSFont *)font;
- (void)setFont:(NSFont *)fontObj;

- (NSTextAlignment)alignment;
- (void)setAlignment:(NSTextAlignment)mode;

- (NSImageAlignment)imageAlignment;
- (void)setImageAlignment:(NSImageAlignment)newAlign;
- (NSImageScaling)imageScaling;
- (void)setImageScaling:(NSImageScaling)newScaling;

- (NSCellImagePosition)imagePosition;
- (void)setImagePosition:(NSCellImagePosition)aPosition;

- (void)setControlSize:(NSControlSize)size;
- (NSControlSize)controlSize;

@end

@interface NSObject (IconTrayDeletate)

-(BOOL)iconTray:(IconTray *)iconTray willChangeFileOfImage:(NSFileWrapper *)imageFileWrapper;
-(void)iconTray:(IconTray *)iconTray didChangeFileOfImage:(NSFileWrapper *)imageFileWrapper;

@end

extern NSString *IconTrayImageFileDidChangeNotification;

@interface NSObject (IconTrayNotifications)

-(void)iconTrayImageFileDidChangeNotification:(NSNotification *)notification;

@end