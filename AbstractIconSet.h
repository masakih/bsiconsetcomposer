//
//  AbstractIconSet.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/07/10.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IconTray;

@interface AbstractIconSet : NSObject
{
@private
	id plist;
@protected
	id iconTrayDict;
	id delegate;
	
	IBOutlet NSView *view;
}

// do not overwried.
-(void)setImageFilePath:(NSString *)path forKey:(NSString *)key;
-(NSString *)imageFilePathForKey:(NSString *)key;
-(NSArray *)allKeys;
-(void)setImage:(NSImage *)image forKey:(NSString *)key;
-(IconTray *)iconTrayForKey:(NSString *)key;
-(NSString *)keyForIconTray:(IconTray *)iconTray;

// subclass MUST overwride.
-(void)buildIconTrayDict;

-(id)plist;

-(NSView *)view;

-(void)setDelegate:(id)delegate;
-(id)delegate;
@end

@interface NSObject (IconSetDelegate)
-(void)iconSet:(AbstractIconSet *)iconSet didChangeImageFilePath:(NSString *)path forKey:(NSString *)key;
@end

@interface ToolbarIconSet : AbstractIconSet
{
	IBOutlet id board;
	IBOutlet id delete_;
	IBOutlet id reloadThread;
	IBOutlet id reloadBoard;
	IBOutlet id addFav;
	IBOutlet id delFav;
	IBOutlet id res;
	IBOutlet id draft;
	IBOutlet id send;
	IBOutlet id enableBe;
	IBOutlet id disableBe;
	IBOutlet id logFinder;
	IBOutlet id offline;
	IBOutlet id online;
	IBOutlet id stop;
	IBOutlet id orderFrontBrowser;
}

@end

@interface BoardListIconSet : AbstractIconSet
{
	IBOutlet id fav;
	IBOutlet id folder;
	IBOutlet id board;
	IBOutlet id selectedItemActive;
	IBOutlet id selectedItemDeactive;
}

@end

@interface ThreadListIconSet : AbstractIconSet
{
	IBOutlet id newThread;
	IBOutlet id update;
	IBOutlet id cache;
}

@end

@interface ThreadIconSet : AbstractIconSet
{
	IBOutlet id contentHeaderAqua;
	IBOutlet id contentHeaderGraphite;
	IBOutlet id normalEllipsisProxy;
	IBOutlet id mouseOverEllipsisProxy;
	IBOutlet id mouseDownEllipsisProxy;
	IBOutlet id normalEllipsisUpProxy;
	IBOutlet id mouseOverEllipsisUpProxy;
	IBOutlet id mouseDownEllipsisUpProxy;
	IBOutlet id normalEllipsisDownProxy;
	IBOutlet id mouseOverEllipsisDownProxy;
	IBOutlet id mouseDownEllipsisDownProxy;
	IBOutlet id newRes;
	IBOutlet id age;
	IBOutlet id sage;
	IBOutlet id mail;
}

@end