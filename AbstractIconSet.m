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
	
//	[iconTray setImage:image];
	
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
	
//	[iconTray setImage:image];
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
//	[iconTrayDict setObject:age forKey:threadIconSetAge];
//	[iconTrayDict setObject:sage forKey:threadIconSetSage];
//	[iconTrayDict setObject:mail forKey:threadIconSetMailAttachment];
//	[iconTrayDict setObject:newRes forKey:threadIconSetLastUpdatedHeader];
//	[iconTrayDict setObject:normalEllipsisProxy forKey:threadIconSetEllipsisProxy];
//	[iconTrayDict setObject:mouseOverEllipsisProxy forKey:threadIconSetEllipsisMouseOver];
//	[iconTrayDict setObject:mouseDownEllipsisProxy forKey:threadIconSetEllipsisMouseDown];
//	[iconTrayDict setObject:normalEllipsisUpProxy forKey:threadIconSetEllipsisUpProxy];
//	[iconTrayDict setObject:mouseOverEllipsisUpProxy forKey:threadIconSetEllipsisUpMouseOver];
//	[iconTrayDict setObject:mouseDownEllipsisUpProxy forKey:threadIconSetEllipsisUpMouseDown];
//	[iconTrayDict setObject:normalEllipsisDownProxy forKey:threadIconSetEllipsisDownProxy];
//	[iconTrayDict setObject:mouseOverEllipsisDownProxy forKey:threadIconSetEllipsisDownMouseOver];
//	[iconTrayDict setObject:mouseDownEllipsisDownProxy forKey:threadIconSetEllipsisDownMouseDown];
//	[iconTrayDict setObject:contentHeaderAqua forKey:threadIconSetTitleRulerBgAquaBlue];
//	[iconTrayDict setObject:contentHeaderGraphite forKey:threadIconSetTitleRulerBgAquaGraphite];
}
@end

