//
//  IconTray.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/06/27.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IconTray : NSImageView
{
	IBOutlet id delegate;
	
	BOOL highlited;
	BOOL selected;
}

-(void)setDelegate:(id)delegate;
-(id)delegate;

-(void)setSelected:(BOOL)flag;
-(void)setHighlite:(BOOL)flag;

-(BOOL)setImage:(NSImage *)image ofFile:(NSString *)imageFileName;
-(BOOL)setImageFromPasteboard:(NSPasteboard *)pasteboard;
-(void)removeImage;

-(IBAction)cut:(id)sender;
-(IBAction)copy:(id)sender;
-(IBAction)paste:(id)sender;
-(IBAction)delete:(id)sender;

@end

@interface NSObject (IconTrayDelegate)

-(BOOL)iconTray:(IconTray *)iconTray willChangeFileOfImage:(NSString *)imagePath;
-(void)iconTray:(IconTray *)iconTray didChangeFileOfImage:(NSString *)imagePath;

-(BOOL)iconTrayWillRemoveImage:(IconTray *)iconTray;
-(void)iconTrayDidRemoveImage:(IconTray *)iconTray;

@end
