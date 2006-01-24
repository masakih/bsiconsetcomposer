//
//  IconSetDocument.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/07/10.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconSetDocument.h"

#import <IconTray/IconTray.h>
#import "IconSetComposer.h"
#import "TemporaryFolder.h"

@interface BSISApplyCommand : NSScriptCommand
@end

@interface IconSetDocument(Private)
-(void)setupIconTrays;
@end

@implementation IconSetDocument

static NSArray *sToolbarIdentifiers;
static NSArray *sBoardListIdentifiers;
static NSArray *sThreadListIdentifiers;
static NSArray *sThreadIdentifiers;


+(NSArray *)arrayForImageName:(NSArray *)plist
{
	NSMutableArray *result = [NSMutableArray array];
	NSEnumerator *keysEnum = [plist objectEnumerator];
	NSDictionary *key;
	
	while( key = [keysEnum nextObject] ) {
		[result addObject:[key objectForKey:@"imageName"]];
	}
	
	return result; 
}
+(void)initialize
{
	NSString *imageListPath = [[NSBundle mainBundle] pathForResource:@"ImageList" ofType:@"plist"];
	NSDictionary *imageList = [NSDictionary dictionaryWithContentsOfFile:imageListPath];
	
	sToolbarIdentifiers = [[self arrayForImageName:[imageList objectForKey:@"Toolbar"]] retain];
	sThreadIdentifiers = [[self arrayForImageName:[imageList objectForKey:@"Thread"]] retain];
	sBoardListIdentifiers = [[self arrayForImageName:[imageList objectForKey:@"BoardList"]] retain];
	sThreadListIdentifiers = [[self arrayForImageName:[imageList objectForKey:@"ThreadList"]] retain];
}

+(NSArray *)managedImageNames
{
	NSMutableArray *result = [NSMutableArray array];
	
	[result addObjectsFromArray:sToolbarIdentifiers];
	[result addObjectsFromArray:sBoardListIdentifiers];
	[result addObjectsFromArray:sThreadIdentifiers];
	[result addObjectsFromArray:sThreadListIdentifiers];
	
	return result;
}

-(void)dealloc
{
	[wrapper release];
	
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"IconSetDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	if( !wrapper ) {
		wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	}
	
	[tab selectLastTabViewItem:self];
	[tab selectFirstTabViewItem:self];
	[self setupIconTrays];
	[self updateAll];
	
//	[self updateChangeCount:NSChangeCleared];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	id temp = wrapper;
	wrapper = [fileWrapper retain];
	[temp release];
	
	[self updateAll];
	
//	[self updateChangeCount:NSChangeCleared];
	
	return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
	return wrapper;
}

// For Panther.
- (BOOL)loadFileWrapperRepresentation:(NSFileWrapper *)fileWrapper ofType:(NSString *)type
{
	return [self readFromFileWrapper:fileWrapper ofType:type error:NULL];
}
- (NSFileWrapper *)fileWrapperRepresentationOfType:(NSString *)type
{
	return [self fileWrapperOfType:type error:NULL];
}

/*	NSTabViewItem の view は NSTabView がリサイズされると自動リサイズされる。
	それを避けるため、リサイズする前にダミーの NSView にすり替える。
	ダミーの NSView には選択される前の NSTabViewItem の View --これは、IBパレットによって作られたデフォルトの View--を使う。
*/
- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSView *view = [tabViewItem view];
	id item = [tabView selectedTabViewItem];
	
	[[self windowForSheet] makeFirstResponder:nil]; // for erase highlite rectangle.
	
	[item setView:view];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSView *view = nil;
	NSSize delta;
	NSSize contSize;
	NSSize viewSize;
	NSRect windowRect;
	
	if( [[tabViewItem identifier] isEqualTo:@"Toolbar"] ) {
		view = toolbarIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:@"BoardList"] ) {
		view = boardListIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:@"ThreadList"] ) {
		view = threadListIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:@"Thread"] ) {
		view = threadIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:@"Colors"] ) {
		view = [colorSet view];
	}
	
	if( view ) {
		contSize = [tabView contentRect].size;
		viewSize = [view frame].size;
		
		delta.width = viewSize.width - contSize.width;
		delta.height = viewSize.height - contSize.height;
		
		windowRect = [[tabView window] frame];
		windowRect.size.width += delta.width;
		windowRect.size.height += delta.height;
		windowRect.origin.y -= delta.height;
		
		[tabViewItem setView:view];
		[[tabView window] setFrame:windowRect display:YES animate:YES];
	}
}

#pragma mark-
#pragma mark ## MVC - Model ##

-(NSFileWrapper *)fileWrapperForIdentifier:(NSString *)identifier
{
	id	fileName;
	id dict;
	
	NSArray *array;
	NSEnumerator *extEnum;
	NSString *ext;
	
	NSFileWrapper *fw;
	
	if( !wrapper ) {
		return nil;
	}
	dict = [wrapper fileWrappers];
	
	array = [IconSetComposer acceptImageExtensions];
	array = [array arrayByAddingObject:@"plist"];
	extEnum = [array objectEnumerator];
	while( ext = [extEnum nextObject] ) {
		fileName = [identifier stringByAppendingPathExtension:ext];
		fw = [dict objectForKey:fileName];
		if( fw ) return fw;
	}
	
	return nil;
}

// path が nil なら identifier を削除。
-(void)setPath:(NSString *)path forIdentifier:(NSString *)identifier
{
	NSData *data;
	NSString *fileName;
	NSFileWrapper *fw;
	
	if( !wrapper ) {
		wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	}
	
	if( path ) {
		data = [NSData dataWithContentsOfFile:path];
		if( !data ) {
			NSLog(@"Not found %@.", path);
			return;
		}		
	}
		
	if( fw = [self fileWrapperForIdentifier:identifier] ) {
		[wrapper removeFileWrapper:fw];
	} else if( !path ) { //　元からないものを削除
		return;
	}
	
	if( path ) {
		id lowerExt = [[path pathExtension] lowercaseString];
		fileName = [identifier stringByAppendingPathExtension:lowerExt];
		[wrapper addRegularFileWithContents:data preferredFilename:fileName];
	}
	
	[self updateChangeCount:NSChangeDone];
}

-(void)setPlist:(id)plist forIdentifier:(NSString *)identifier
{
	NSFileWrapper *fw;
	
	if( !plist && ![plist respondsToSelector:@selector(writeToFile:atomically:)] ) {
		return;
	}
	
	if( !wrapper ) {
		wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	}
	
	if( fw = [self fileWrapperForIdentifier:identifier] ) {
		[wrapper removeFileWrapper:fw];
	}
	
	if( plist ) {
		NSString *fileName = [identifier stringByAppendingPathExtension:@"plist"];
		TemporaryFolder *t = [TemporaryFolder temporaryFolder];
		NSString *path;
		
		path = [[t path] stringByAppendingPathComponent:fileName];
		if( ![plist writeToFile:path atomically:NO] ) {
			return;
		}
		
		[wrapper addFileWithPath:path];
		
		[self updateChangeCount:NSChangeDone];
	}
}

-(id)iconTrays
{
	return iconTrays;
}

-(void)setIconTrays:(id)newIconTrays
{
	id temp = iconTrays;
	iconTrays = [newIconTrays retain];
	[temp release];
}

-(id)colorSet
{
	return colorSet;
}
-(void)setColorSet:(id)set
{
	id temp = colorSet;
	colorSet = [set retain];
	[temp release];
}

#pragma mark-
#pragma mark ## MVC - Controller ##

-(void)setupIconTrays
{
	id newIconTrays;
	NSEnumerator *enums;
	id object;
	
	newIconTrays = [NSMutableDictionary dictionary];
	
	enums = [[[self class] managedImageNames] objectEnumerator];
	while( object = [enums nextObject] ) {
		id dict;
		
		dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			NSLocalizedStringFromTable( object,  @"IconNames", @"Icon Title" ), @"title",
			[IconSetComposer defaultImageForIdentifier:object], @"defaultImage",
			[NSNull null], @"image",
			[NSNull null], @"imgaeFileWrapper",
			nil];
		[newIconTrays setObject:dict forKey:object];
/*		
		[dict addObserver:self
			   forKeyPath:@"image"
				  options:NSKeyValueObservingOptionNew
				  context:nil];
		[self addObserver:dict
			   forKeyPath:@"image"
				  options:NSKeyValueObservingOptionNew
				  context:nil];
*/
	}
	
	[self setIconTrays:newIconTrays];
}
/*
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	NSLog(@"Automatic observe --- key -> %@", key );
	
	return [super automaticallyNotifiesObserversForKey:key];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context
{
	NSLog(@"Chnage!! key -> %@", keyPath);
	
	[super observeValueForKeyPath:keyPath
						 ofObject:object
						   change:change
						  context:context];
}
*/

-(void)updateAll
{
	id keys = [[wrapper fileWrappers] keyEnumerator];
	id identifier;
	
	while( identifier = [keys nextObject] ) {
		identifier = [identifier stringByDeletingPathExtension];
		[self updateForKey:identifier];
	}
}
-(void)updateForKey:(NSString *)key
{
	NSImage *image;
	NSFileWrapper *fw;
	NSData *data;
	NSString *filename;
	
	fw = [self fileWrapperForIdentifier:key];
	if( !fw ) {
//		NSLog(@"can't load image for %@", key);
		return;
	}
	
	data = [fw regularFileContents];
	image = [[[NSImage alloc] initWithData:data] autorelease];
	if( !image ) {
		filename = [fw filename];
		if( !filename ) return;
		
		NSString *path = [[self fileName] stringByAppendingPathComponent:filename];
		[colorSet setPlistPath:path];
	} else {
		/*
		id dict = [[self iconTrays] objectForKey:key];
		if( dict ) {
			[dict setObject:image forKey:@"image"];
		}
		 */
		[[self iconTrays] setValue:fw forKeyPath:[NSString stringWithFormat:@"%@.%@", key, @"imageFileWrapper"]];
	}
}
	
-(void)apply:(id)sender
{
	NSString *bathyScapheResourceFolder = [IconSetComposer bathyScapheResourceFolder];
		
	id dict;
	NSEnumerator *filesEnum;
	NSString *file;
	NSData *data;
	NSString *newPath;
	
	[IconSetComposer deleteImageFilesFromBSAppSptResFolder];
	
	dict = [wrapper fileWrappers];
	filesEnum = [dict keyEnumerator];
	while( file = [filesEnum nextObject] ) {
		if( [file hasSuffix:@"plist"] ) continue;
		
		data = [[dict objectForKey:file] regularFileContents];
		newPath = [bathyScapheResourceFolder stringByAppendingPathComponent:file];
		
		[data writeToFile:newPath atomically:YES];
	}
	
	[colorSet applyColors:self];
}

-(void)applyAndRestartBathyScaphe:(id)sender
{
	NSScriptCommandDescription *desc;
	NSScriptCommand *command;
	
	desc = [[NSScriptSuiteRegistry sharedScriptSuiteRegistry] commandDescriptionWithAppleEventClass:'bSiS'
																				  andAppleEventCode:'bSaP'];
	command = [desc createCommandInstance];
	
	[command setDirectParameter:[self objectSpecifier]];
	
	[command executeCommand];
}

-(void)iconTray:(IconTray *)iconTray didChangeFileOfImage:(NSFileWrapper *)imageFileWrapper
{
	NSFileWrapper *fw;
	NSString *identifier;
	NSString *filename;
	
	identifier = [iconTray identifier];
	filename = [iconTray imageName];
	
	if( ![[filename stringByDeletingPathExtension] isEqualTo:identifier] ) {
		filename = [identifier stringByAppendingPathExtension:[filename pathExtension]];
		[iconTray setImageName:filename];
	}
	
	fw = [self fileWrapperForIdentifier:identifier];
	if( fw ) {
		if( [fw isEqual:[iconTray imageFileWrapper]] ) {
			return;
		}
		[wrapper removeFileWrapper:fw];
	}
	
	filename = [wrapper addFileWrapper:[iconTray imageFileWrapper]];
	NSLog(@"##### filewrapper Key -> %@", filename );
	
	[self updateChangeCount:NSChangeDone];
}

@end


#pragma mark ## Scripting Support ##

@implementation IconSetDocument (IconSetDocumentScriptingSupport)

-(id)handleApplyCommand:(NSScriptCommand*)command
{
	[[IconSetComposer sharedInstance] quitBathyScaphe:self];
	[self apply:self];
	[[IconSetComposer sharedInstance] launchBathyScaphe:self];
	return nil;
}

@end

@implementation BSISApplyCommand
- (id)performDefaultImplementation
{
	return [self commandDescription];
}

@end
