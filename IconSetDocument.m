//
//  IconSetDocument.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 05/07/10.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconSetDocument.h"

#import "IconSetComposer.h"
#import "TemporaryFolder.h"

@interface BSISApplyCommand : NSScriptCommand
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
	
	[tab selectLastTabViewItem:self];
	[tab selectFirstTabViewItem:self];
	[self setupDefault];
	[self updateAll];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	wrapper = [fileWrapper retain];
	
	[self updateAll];
	
	return YES;
}

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
	return wrapper;
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
		view = [toolbarIconSet view];
	} else if( [[tabViewItem identifier] isEqualTo:@"BoardList"] ) {
		view = [boardListIconSet view];
	} else if( [[tabViewItem identifier] isEqualTo:@"ThreadList"] ) {
		view = [threadListIconSet view];
	} else if( [[tabViewItem identifier] isEqualTo:@"Thread"] ) {
		view = [threadIconSet view];
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
	}
	
	[self updateChangeCount:NSChangeDone];
}

#pragma mark-
#pragma mark ## MVC - Controller ##

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
	
	NSArray *array;
	NSEnumerator *extEnum;
	NSString *ext;
	
	array = [IconSetComposer acceptImageExtensions];
	array = [array arrayByAddingObject:@"plist"];
	extEnum = [array objectEnumerator];
	while( ext = [extEnum nextObject] ) {
		filename = [key stringByAppendingPathExtension:ext];
		fw = [[wrapper fileWrappers] objectForKey:filename];
		if( fw ) break;
	}
	if( !fw ) {
//		NSLog(@"can't load image for %@", key);
		return;
	}
	
	data = [fw regularFileContents];
	image = [[[NSImage alloc] initWithData:data] autorelease];
	if( !image ) {
		
		NSString *path = [[self fileName] stringByAppendingPathComponent:filename];
		[colorSet setPlistPath:path];
		return;
	}
	
	if( [sToolbarIdentifiers containsObject:key] ) {
		[toolbarIconSet setImage:image forKey:key];
	} else if( [sBoardListIdentifiers containsObject:key] ) {
		[boardListIconSet setImage:image forKey:key];
	} else if( [sThreadListIdentifiers containsObject:key] ) {
		[threadListIconSet setImage:image forKey:key];
	} else if( [sThreadIdentifiers containsObject:key] ) {
		[threadIconSet setImage:image forKey:key];
	} else {
		return;
	}
}
	
-(void)apply:(id)sender
{
	NSString *bathyScapheSupportFolder = [IconSetComposer bathyScapheSupportFolder];
		
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
		newPath = [bathyScapheSupportFolder stringByAppendingPathComponent:file];
		
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

-(void)iconSet:(AbstractIconSet *)iconSet didChangeImageFilePath:(NSString *)path forKey:(NSString *)identifier
{
	[self setPath:path forIdentifier:identifier];
	[self updateForKey:identifier];
}

#pragma mark-

-(void)setupDefault
{
	NSString *identifier;
	NSImage *image;
	NSEnumerator *identifierEnum;
	
	identifierEnum = [sToolbarIdentifiers objectEnumerator];
	while( identifier = [identifierEnum nextObject] ) {
		image = [IconSetComposer defaultImageForIdentifier:identifier];
		[toolbarIconSet setImage:image forKey:identifier];
	}
	
	identifierEnum = [sBoardListIdentifiers objectEnumerator];
	while( identifier = [identifierEnum nextObject] ) {
		image = [IconSetComposer defaultImageForIdentifier:identifier];
		[boardListIconSet setImage:image forKey:identifier];
	}
	
	identifierEnum = [sThreadListIdentifiers objectEnumerator];
	while( identifier = [identifierEnum nextObject] ) {
		image = [IconSetComposer defaultImageForIdentifier:identifier];
		[threadListIconSet setImage:image forKey:identifier];
	}
	
	identifierEnum = [sThreadIdentifiers objectEnumerator];
	while( identifier = [identifierEnum nextObject] ) {
		image = [IconSetComposer defaultImageForIdentifier:identifier];
		[threadIconSet setImage:image forKey:identifier];
	}
}

@end


#pragma mark ## Scripting Support ##

@implementation IconSetDocument (IconSetDocumentScriptingSupport)

-(id)handleApplyCommand:(NSScriptCommand*)command
{
	
	/*
	[self applyAndRestartBathyScaphe:nil];
	 */
	[self apply:self];
	[[IconSetComposer sharedInstance] restartBathyScaphe:self];
	return nil;
}

@end

@implementation BSISApplyCommand
- (id)performDefaultImplementation
{
	return [self commandDescription];
}

@end
