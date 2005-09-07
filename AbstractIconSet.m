//
//  AbstractIconSet.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/07/10.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AbstractIconSet.h"
#import "IconSetComposer.h"

#import "IconTray.h"

@implementation AbstractIconSet

-(id)init
{
	if(self = [super init]) {
		plist = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}

-(void)dealloc
{
	[plist release];
	
	[super dealloc];
}

// do not overwried.
-(void)setImageFilePath:(NSString *)path forKey:(NSString *)key
{
	IconTray *iconTray;
	NSImage *image;
	
	iconTray = [self iconTrayForKey:key];
	if( !iconTray ) {
		NSLog(@"No such key %@", key );
		return;
	}
	
	if( !path ) {
		image = [IconSetComposer defaultImageForIdentifier:key];
	} else {
		image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	}
	
	if( !image ) {
		NSLog(@"%@ is not Image file", path);
		return;
	}
	
	[iconTray setImage:image];
	
	if( path ) {
		[plist setObject:path forKey:key];
	} else {
		[plist removeObjectForKey:key];
	}
	
	if( delegate 
		&& [delegate respondsToSelector:@selector(iconSet:didChangeImageFilePath:forKey:)] ) {
		[delegate iconSet:self didChangeImageFilePath:path forKey:key];
	}
}
	
	
-(NSString *)imageFilePathForKey:(NSString *)key
{	
	return [plist objectForKey:key];
}
	
-(NSArray *)allKeys
{
	return [plist allKeys];
}

-(void)setImage:(NSImage *)image forKey:(NSString *)key
{
	IconTray *iconTray;
	
	iconTray = [self iconTrayForKey:key];
	if( !iconTray ) {
		NSLog(@"No such key %@", key );
		return;
	}
	
	[iconTray setImage:image];
}

	// subclass MUST overwride.
-(IconTray *)iconTrayForKey:(NSString *)key
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id)plist
{
	return [NSDictionary dictionaryWithDictionary:plist];
}

-(NSView *)view
{
	return view;
}

-(id)description
{
	return [plist description];
}

-(void)setDelegate:(id)inDelegate
{
	delegate = inDelegate;
}
-(id)delegate
{
	return delegate;
}

#pragma mark ## IconTrayDelegate ##
-(BOOL)iconTray:(IconTray *)iconTray willChangeFileOfImage:(NSString *)imagePath
{
	NSString *ext = [imagePath pathExtension];
	
	if( !ext ) return NO;
	
	return [IconSetComposer isAcceptImageExtension:ext];
}
-(void)iconTray:(IconTray *)iconTray didChangeFileOfImage:(NSString *)imagePath
{
	NSString *key = [self keyForIconTray:iconTray];
	
	[self setImageFilePath:imagePath forKey:key];
}

-(void)iconTrayDidRemoveImage:(IconTray *)iconTray
{
	NSString *key = [self keyForIconTray:iconTray];
	
	[self setImageFilePath:nil forKey:key];
}

@end
#pragma mark -

static NSString *const toolbarIconSetBoardList = @"BoardList";
static NSString *const toolbarIconSetDelete = @"Delete";
static NSString *const toolbarIconSetReloadList = @"ReloadList";
static NSString *const toolbarIconSetReloadThread = @"ReloadThread";
static NSString *const toolbarIconSetAddFavorites = @"AddFavorites";
static NSString *const toolbarIconSetRemoveFavorites = @"RemoveFavorites";
static NSString *const toolbarIconSetResToThread = @"ResToThread";
static NSString *const toolbarIconSetSaveAsDraft = @"SaveAsDraft";
static NSString *const toolbarIconSetSendMessage = @"SendMessage";
static NSString *const toolbarIconSetBeDisabled = @"beDisabled";
static NSString *const toolbarIconSetBeEnabled = @"beEnabled";
static NSString *const toolbarIconSetCmlf_icon = @"cmlf_icon";
static NSString *const toolbarIconSetOffline = @"offline";
static NSString *const toolbarIconSetOnline = @"online";
static NSString *const toolbarIconSetStopSign = @"stopSign";

@implementation ToolbarIconSet
-(IconTray *)iconTrayForKey:(NSString *)key
{
	id result = nil;
	
	if( [key isEqualTo:toolbarIconSetBoardList] ) {
		result = board;
	} else if( [key isEqualTo:toolbarIconSetDelete] ) {
		result = delete_;
	} else if( [key isEqualTo:toolbarIconSetReloadList] ) {
		result = reloadBoard;
	} else if( [key isEqualTo:toolbarIconSetReloadThread] ) {
		result = reloadThread;
	} else if( [key isEqualTo:toolbarIconSetAddFavorites] ) {
		result = addFav;
	} else if( [key isEqualTo:toolbarIconSetRemoveFavorites] ) {
		result = delFav;
	} else if( [key isEqualTo:toolbarIconSetResToThread] ) {
		result = res;
	} else if( [key isEqualTo:toolbarIconSetSaveAsDraft] ) {
		result = draft;
	} else if( [key isEqualTo:toolbarIconSetSendMessage] ) {
		result = send;
	} else if( [key isEqualTo:toolbarIconSetBeDisabled] ) {
		result = disableBe;
	} else if( [key isEqualTo:toolbarIconSetBeEnabled] ) {
		result = enableBe;
	} else if( [key isEqualTo:toolbarIconSetCmlf_icon] ) {
		result = logFinder;
	} else if( [key isEqualTo:toolbarIconSetOffline] ) {
		result = offline;
	} else if( [key isEqualTo:toolbarIconSetOnline] ) {
		result = online;
	} else if( [key isEqualTo:toolbarIconSetStopSign] ) {
		result = stop;
	}
	
	return result;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	NSString *result = nil;
	
	if( [iconTray isEqualTo:board] ) {
		result = toolbarIconSetBoardList;
	} else if( [iconTray isEqualTo:delete_] ) {
		result = toolbarIconSetDelete;
	} else if( [iconTray isEqualTo:reloadBoard] ) {
		result = toolbarIconSetReloadList;
	} else if( [iconTray isEqualTo:reloadThread] ) {
		result = toolbarIconSetReloadThread;
	} else if( [iconTray isEqualTo:addFav] ) {
		result = toolbarIconSetAddFavorites;
	} else if( [iconTray isEqualTo:delFav] ) {
		result = toolbarIconSetRemoveFavorites;
	} else if( [iconTray isEqualTo:res] ) {
		result = toolbarIconSetResToThread;
	} else if( [iconTray isEqualTo:draft] ) {
		result = toolbarIconSetSaveAsDraft;
	} else if( [iconTray isEqualTo:send] ) {
		result = toolbarIconSetSendMessage;
	} else if( [iconTray isEqualTo:disableBe] ) {
		result = toolbarIconSetBeDisabled;
	} else if( [iconTray isEqualTo:enableBe] ) {
		result = toolbarIconSetBeEnabled;
	} else if( [iconTray isEqualTo:logFinder] ) {
		result = toolbarIconSetCmlf_icon;
	} else if( [iconTray isEqualTo:offline] ) {
		result = toolbarIconSetOffline;
	} else if( [iconTray isEqualTo:online] ) {
		result = toolbarIconSetOnline;
	} else if( [iconTray isEqualTo:stop] ) {
		result = toolbarIconSetStopSign;
	}
	
	return result;
}

@end
#pragma mark -

static NSString *const boardListIconSetBoard = @"Board";
static NSString *const boardListIconSetFavoritesItem = @"FavoritesItem";
static NSString *const boardListIconSetFolder = @"Folder";

@implementation BoardListIconSet

-(IconTray *)iconTrayForKey:(NSString *)key
{
	id result = nil;
	
	if( [key isEqualTo:boardListIconSetBoard] ) {
		result = board;
	} else if( [key isEqualTo:boardListIconSetFavoritesItem] ) {
		result = fav;
	} else if( [key isEqualTo:boardListIconSetFolder] ) {
		result = folder;
	}
	
	return result;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	NSString *result = nil;
	
	if( [iconTray isEqualTo:board] ) {
		result = boardListIconSetBoard;
	} else if( [iconTray isEqualTo:fav] ) {
		result = boardListIconSetFavoritesItem;
	} else if( [iconTray isEqualTo:folder] ) {
		result = boardListIconSetFolder;
	}
	return result;
}

@end
#pragma mark -

static NSString *const threadListIconSetStatus_logcached = @"Status_logcached";
static NSString *const threadListIconSetStatus_updated = @"Status_updated";
static NSString *const threadListIconSetStatus_newThread = @"Status_newThread";

@implementation ThreadListIconSet

-(IconTray *)iconTrayForKey:(NSString *)key
{
	id result = nil;
	
	if( [key isEqualTo:threadListIconSetStatus_logcached] ) {
		result = cache;
	} else if( [key isEqualTo:threadListIconSetStatus_updated] ) {
		result = update;
	} else if( [key isEqualTo:threadListIconSetStatus_newThread] ) {
		result = newThread;
	}
	
	return result;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	NSString *result = nil;
	
	if( [iconTray isEqualTo:cache] ) {
		result = threadListIconSetStatus_logcached;
	} else if( [iconTray isEqualTo:update] ) {
		result = threadListIconSetStatus_updated;
	} else if( [iconTray isEqualTo:newThread] ) {
		result = threadListIconSetStatus_newThread;
	}
	
	return result;
}


@end
#pragma mark -

static NSString *const threadIconSetAge = @"age";
static NSString *const threadIconSetSage = @"sage";
static NSString *const threadIconSetMailAttachment = @"mailAttachment";
static NSString *const threadIconSetLastUpdatedHeader = @"lastUpdatedHeader";
static NSString *const threadIconSetEllipsisProxy = @"EllipsisProxy";
static NSString *const threadIconSetEllipsisMouseOver = @"EllipsisMouseOver";
static NSString *const threadIconSetEllipsisMouseDown = @"EllipsisMouseDown";
static NSString *const threadIconSetEllipsisUpProxy = @"EllipsisUpProxy";
static NSString *const threadIconSetEllipsisUpMouseOver = @"EllipsisUpMouseOver";
static NSString *const threadIconSetEllipsisUpMouseDown = @"EllipsisUpMouseDown";
static NSString *const threadIconSetEllipsisDownProxy = @"EllipsisDownProxy";
static NSString *const threadIconSetEllipsisDownMouseOver = @"EllipsisDownMouseOver";
static NSString *const threadIconSetEllipsisDownMouseDown = @"EllipsisDownMouseDown";

@implementation ThreadIconSet
-(IconTray *)iconTrayForKey:(NSString *)key
{
	id result = nil;
	
	if( [key isEqualTo:threadIconSetAge] ) {
		result = age;
	} else if( [key isEqualTo:threadIconSetSage] ) {
		result = sage;
	} else if( [key isEqualTo:threadIconSetMailAttachment] ) {
		result = mail;
	} else if( [key isEqualTo:threadIconSetLastUpdatedHeader] ) {
		result = newRes;
	} else if( [key isEqualTo:threadIconSetEllipsisProxy] ) {
		result = normalEllipsisProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisMouseOver] ) {
		result = mouseOverEllipsisProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisMouseDown] ) {
		result = mouseDownEllipsisProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisUpProxy] ) {
		result = normalEllipsisUpProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisUpMouseOver] ) {
		result = mouseOverEllipsisUpProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisUpMouseDown] ) {
		result = mouseDownEllipsisUpProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisDownProxy] ) {
		result = normalEllipsisDownProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisDownMouseOver] ) {
		result = mouseOverEllipsisDownProxy;
	} else if( [key isEqualTo:threadIconSetEllipsisDownMouseDown] ) {
		result = mouseDownEllipsisDownProxy;
	}
	
	return result;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	NSString *result = nil;
	
	if( [iconTray isEqualTo:age] ) {
		result = threadIconSetAge;
	} else if( [iconTray isEqualTo:sage] ) {
		result = threadIconSetSage;
	} else if( [iconTray isEqualTo:mail] ) {
		result = threadIconSetMailAttachment;
	} else if( [iconTray isEqualTo:newRes] ) {
		result = threadIconSetLastUpdatedHeader;
	} else if( [iconTray isEqualTo:normalEllipsisProxy] ) {
		result = threadIconSetEllipsisProxy;
	} else if( [iconTray isEqualTo:mouseOverEllipsisProxy] ) {
		result = threadIconSetEllipsisMouseOver;
	} else if( [iconTray isEqualTo:mouseDownEllipsisProxy] ) {
		result = threadIconSetEllipsisMouseDown;
	} else if( [iconTray isEqualTo:normalEllipsisUpProxy] ) {
		result = threadIconSetEllipsisUpProxy;
	} else if( [iconTray isEqualTo:mouseOverEllipsisUpProxy] ) {
		result = threadIconSetEllipsisUpMouseOver;
	} else if( [iconTray isEqualTo:mouseDownEllipsisUpProxy] ) {
		result = threadIconSetEllipsisUpMouseDown;
	} else if( [iconTray isEqualTo:normalEllipsisDownProxy] ) {
		result = threadIconSetEllipsisDownProxy;
	} else if( [iconTray isEqualTo:mouseOverEllipsisDownProxy] ) {
		result = threadIconSetEllipsisDownMouseOver;
	} else if( [iconTray isEqualTo:mouseDownEllipsisDownProxy] ) {
		result = threadIconSetEllipsisDownMouseDown;
	}
	
	return result;
}

@end

