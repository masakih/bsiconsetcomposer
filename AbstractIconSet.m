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
		iconTrayDict = [[NSMutableDictionary dictionary] retain];
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

-(IconTray *)iconTrayForKey:(NSString *)key
{
	return [iconTrayDict objectForKey:key];;
}

-(NSString *)keyForIconTray:(IconTray *)iconTray
{
	return [[iconTrayDict allKeysForObject:iconTray] objectAtIndex:0];
}

-(void)awakeFromNib
{
	[self buildIconTrayDict];
}

// subclass MUST overwride.
-(void)buildIconTrayDict
{
//	[self doesNotRecognizeSelector:_cmd];
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
static NSString *const toolbarIconSetOrderFrontBrowser = @"OrderFrontBrowser";

@implementation ToolbarIconSet
-(void)buildIconTrayDict
{
	[iconTrayDict setObject:board forKey:toolbarIconSetBoardList];
	[iconTrayDict setObject:delete_ forKey:toolbarIconSetDelete];
	[iconTrayDict setObject:reloadBoard forKey:toolbarIconSetReloadList];
	[iconTrayDict setObject:reloadThread forKey:toolbarIconSetReloadThread];
	[iconTrayDict setObject:addFav forKey:toolbarIconSetAddFavorites];
	[iconTrayDict setObject:delFav forKey:toolbarIconSetRemoveFavorites];
	[iconTrayDict setObject:res forKey:toolbarIconSetResToThread];
	[iconTrayDict setObject:draft forKey:toolbarIconSetSaveAsDraft];
	[iconTrayDict setObject:send forKey:toolbarIconSetSendMessage];
	[iconTrayDict setObject:disableBe forKey:toolbarIconSetBeDisabled];
	[iconTrayDict setObject:enableBe forKey:toolbarIconSetBeEnabled];
	[iconTrayDict setObject:logFinder forKey:toolbarIconSetCmlf_icon];
	[iconTrayDict setObject:offline forKey:toolbarIconSetOffline];
	[iconTrayDict setObject:online forKey:toolbarIconSetOnline];
	[iconTrayDict setObject:stop forKey:toolbarIconSetStopSign];
	[iconTrayDict setObject:orderFrontBrowser forKey:toolbarIconSetOrderFrontBrowser];
}
@end
#pragma mark -

static NSString *const boardListIconSetBoard = @"Board";
static NSString *const boardListIconSetFavoritesItem = @"FavoritesItem";
static NSString *const boardListIconSetFolder = @"Folder";
static NSString *const boardListIconSetSelectedItemActive = @"boardListSelBgFocused";
static NSString *const boardListIconSetSelectedItemDeactive = @"boardListSelBg";

@implementation BoardListIconSet
-(void)buildIconTrayDict
{
	[iconTrayDict setObject:board forKey:boardListIconSetBoard];
	[iconTrayDict setObject:fav forKey:boardListIconSetFavoritesItem];
	[iconTrayDict setObject:folder forKey:boardListIconSetFolder];
	[iconTrayDict setObject:selectedItemActive forKey:boardListIconSetSelectedItemActive];
	[iconTrayDict setObject:selectedItemDeactive forKey:boardListIconSetSelectedItemDeactive];
}

@end
#pragma mark -

static NSString *const threadListIconSetStatus_logcached = @"Status_logcached";
static NSString *const threadListIconSetStatus_updated = @"Status_updated";
static NSString *const threadListIconSetStatus_newThread = @"Status_newThread";

@implementation ThreadListIconSet
-(void)buildIconTrayDict
{
	[iconTrayDict setObject:cache forKey:threadListIconSetStatus_logcached];
	[iconTrayDict setObject:update forKey:threadListIconSetStatus_updated];
	[iconTrayDict setObject:newThread forKey:threadListIconSetStatus_newThread];
	
	[newThread setTarget:self];
	[newThread setAction:@selector(test:)];
}

-(IBAction)test:(id)sender
{
	NSLog(@"Enter test:");
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
static NSString *const threadIconSetTitleRulerBgAquaBlue = @"titleRulerBgAquaBlue";
static NSString *const threadIconSetTitleRulerBgAquaGraphite = @"titleRulerBgAquaGraphite";

@implementation ThreadIconSet
-(void)buildIconTrayDict
{
	[iconTrayDict setObject:age forKey:threadIconSetAge];
	[iconTrayDict setObject:sage forKey:threadIconSetSage];
	[iconTrayDict setObject:mail forKey:threadIconSetMailAttachment];
	[iconTrayDict setObject:newRes forKey:threadIconSetLastUpdatedHeader];
	[iconTrayDict setObject:normalEllipsisProxy forKey:threadIconSetEllipsisProxy];
	[iconTrayDict setObject:mouseOverEllipsisProxy forKey:threadIconSetEllipsisMouseOver];
	[iconTrayDict setObject:mouseDownEllipsisProxy forKey:threadIconSetEllipsisMouseDown];
	[iconTrayDict setObject:normalEllipsisUpProxy forKey:threadIconSetEllipsisUpProxy];
	[iconTrayDict setObject:mouseOverEllipsisUpProxy forKey:threadIconSetEllipsisUpMouseOver];
	[iconTrayDict setObject:mouseDownEllipsisUpProxy forKey:threadIconSetEllipsisUpMouseDown];
	[iconTrayDict setObject:normalEllipsisDownProxy forKey:threadIconSetEllipsisDownProxy];
	[iconTrayDict setObject:mouseOverEllipsisDownProxy forKey:threadIconSetEllipsisDownMouseOver];
	[iconTrayDict setObject:mouseDownEllipsisDownProxy forKey:threadIconSetEllipsisDownMouseDown];
	[iconTrayDict setObject:contentHeaderAqua forKey:threadIconSetTitleRulerBgAquaBlue];
	[iconTrayDict setObject:contentHeaderGraphite forKey:threadIconSetTitleRulerBgAquaGraphite];
}
@end

