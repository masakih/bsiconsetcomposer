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

#import "BSCSIcons.h"

#import "BSCSLastUpdatePreview.h"


NSString *const BSCIPlistExtension = @"plist";

NSString *const BSCIImageListPlistName = @"ImageList";
NSString *const BSCIImageListToolbarKey = @"Toolbar";
NSString *const BSCIImageListThreadKey = @"Thread";
NSString *const BSCIImageListBoardListKey = @"BoardList";
NSString *const BSCIImageListThreadListKey = @"ThreadList";
NSString *const BSCIImageListImageNameKey = @"imageName";

NSString *const BSCIIdentifierKey = @"identifier";
NSString *const BSCIImageFileWrapperKey = @"imageFileWrapper";

NSString *const BSCITemporaryPlistFileName = @"temp.plist";

// Tabview Item identifier.
NSString *const BSCIToolbarTabIdentifier = @"Toolbar";
NSString *const BSCIBoardListTabIdentifier = @"BoardList";
NSString *const BSCIThreadListTabIdentifier = @"ThreadList";
NSString *const BSCIThreadTabIdentifier = @"Thread";
NSString *const BSCIColorsTabIdentifier = @"Colors";

@interface BSISApplyCommand : NSScriptCommand
@end

@interface IconSetDocument(Private)
-(void)setupIconTrays;
-(void)changeFileOfImage:(NSFileWrapper *)imageFileWrapper forIdentifier:(NSString *)identifier;
@end

@implementation IconSetDocument

static NSArray *sToolbarIdentifiers;
static NSArray *sBoardListIdentifiers;
static NSArray *sThreadListIdentifiers;
static NSArray *sThreadIdentifiers;


+(NSArray *)arrayForImageName:(NSArray *)plist
{
	NSMutableArray *result = [NSMutableArray array];
	
	for(NSDictionary *key in plist) {
		[result addObject:[key objectForKey:BSCIImageListImageNameKey]];
	}
	
	return result; 
}
+(void)initialize
{
	NSString *imageListPath = [[NSBundle mainBundle] pathForResource:BSCIImageListPlistName ofType:BSCIPlistExtension];
	NSDictionary *imageList = [NSDictionary dictionaryWithContentsOfFile:imageListPath];
	
	sToolbarIdentifiers = [[self arrayForImageName:[imageList objectForKey:BSCIImageListToolbarKey]] retain];
	sThreadIdentifiers = [[self arrayForImageName:[imageList objectForKey:BSCIImageListThreadKey]] retain];
	sBoardListIdentifiers = [[self arrayForImageName:[imageList objectForKey:BSCIImageListBoardListKey]] retain];
	sThreadListIdentifiers = [[self arrayForImageName:[imageList objectForKey:BSCIImageListThreadListKey]] retain];
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
+(NSArray *)deprecatedImageNames
{
	static NSArray *result = nil;
	
	if(!result) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"DeprecatedImageList"
														  ofType:@"plist"];
		result = [[NSArray alloc] initWithContentsOfFile:path];
	}
	
	return result;
}
- (NSArray *)deprecatedImageNames
{
	return [[self class] deprecatedImageNames];
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

- (id)init
{
	self = [super init];
	[self setupIconTrays];
	
	return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	nobinobi.defaultImage = [self valueForKeyPath:@"lastUpdatedHeader.defaultImage"];
	[nobinobi bind:@"singleImage" toObject:self withKeyPath:@"lastUpdatedHeader.image" options:nil];
	[nobinobi bind:@"leftImage" toObject:self withKeyPath:@"lastUpdatedHeaderLeft.image" options:nil];
	[nobinobi bind:@"middleImage" toObject:self withKeyPath:@"lastUpdatedHeaderMiddle.image" options:nil];
	[nobinobi bind:@"rightImage" toObject:self withKeyPath:@"lastUpdatedHeaderRight.image" options:nil];
	
	[colorSet addObserver:self forKeyPath:@"threadsListColor" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:colorSet];
	[colorSet addObserver:self forKeyPath:@"includeColors" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:colorSet];
	[colorSet addObserver:self forKeyPath:@"useStripe" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:colorSet];
	
	if( !wrapper ) {
		wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	}
	
	[tab selectLastTabViewItem:self];
	[tab selectFirstTabViewItem:self];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	id temp = wrapper;
	wrapper = [fileWrapper retain];
	[temp release];
	
	[self updateAll];
		
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
	
	if( [[tabViewItem identifier] isEqualTo:BSCIToolbarTabIdentifier] ) {
		view = toolbarIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:BSCIBoardListTabIdentifier] ) {
		view = boardListIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:BSCIThreadListTabIdentifier] ) {
		view = threadListIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:BSCIThreadTabIdentifier] ) {
		view = threadIconSetView;
	} else if( [[tabViewItem identifier] isEqualTo:BSCIColorsTabIdentifier] ) {
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
	if( !wrapper ) {
		return nil;
	}
	
	id dict = [wrapper fileWrappers];
	NSArray *array = [IconSetComposer acceptImageExtensions];
	array = [array arrayByAddingObject:BSCIPlistExtension];
	for(NSString *ext in array) {
		id	fileName = [identifier stringByAppendingPathExtension:ext];
		NSFileWrapper *fw = [dict objectForKey:fileName];
		if( fw ) return fw;
	}
	
	return nil;
}

// path が nil なら identifier を削除。
-(void)setPath:(NSString *)path forIdentifier:(NSString *)identifier
{
	NSData *data;
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
		
	if( (fw = [self fileWrapperForIdentifier:identifier]) ) {
		[wrapper removeFileWrapper:fw];
	} else if( !path ) { //　元からないものを削除
		return;
	}
	
	if( path ) {
		NSFileWrapper *newFw;
		NSString *key;
		
		newFw = [[[NSFileWrapper alloc] initWithPath:path] autorelease];
		key = [wrapper addFileWrapper:newFw];
		
		BSCSIcons *icon = [iconTrays valueForKey:identifier];
		[icon setImageFileWrapper:newFw];
	}
	
	[self updateChangeCount:NSChangeDone];
}

-(void)didChangeColorSet:(ColorSet *)set
{
	NSString *identifier;
	NSDictionary *plist;
	NSFileWrapper *fw;
	NSString *path;
	TemporaryFolder *t = [TemporaryFolder temporaryFolder];
	
	identifier = [set identifier];
	plist = [set plist];
	if( !plist && ![plist respondsToSelector:@selector(writeToFile:atomically:)] ) {
		return;
	}
	
	if( plist ) {
		NSString *fileName = [identifier stringByAppendingPathExtension:BSCIPlistExtension];
		
		path = [[t path] stringByAppendingPathComponent:fileName];
		if( ![plist writeToFile:path atomically:NO] ) {
			return;
		}
	}
	
	if( !wrapper ) {
		wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
	}
	
	if( (fw = [self fileWrapperForIdentifier:identifier]) ) {
		// 現在のものと同じかどうか。
		if(plist && [fw isRegularFile]) {
			id dat = [fw regularFileContents];
			id temp = [[t path] stringByAppendingPathComponent:BSCITemporaryPlistFileName];
			[dat writeToFile:temp atomically:NO];
			
			id currenPlist = [NSDictionary dictionaryWithContentsOfFile:temp];
			if([plist isEqual:currenPlist]) {
				return; // 同じなら終了。
			}
		}
		[wrapper removeFileWrapper:fw];
	}
	
	if( plist ) {
		[wrapper addFileWithPath:path];
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

- (NSImage *)dropToMeImage
{
	return [[IconSetComposer sharedInstance] dropToMeImage];
}
- (void)setDropToMeImage:(NSImage *)h {}

#pragma mark-
#pragma mark ## MVC - Controller ##

-(BOOL)iconTray:(IconTray *)iconTray willChangeFileOfImage:(NSFileWrapper *)imageFileWrapper
{
	NSFileWrapper *oldWrapper = [iconTray imageFileWrapper];
	NSUndoManager *um = [self undoManager];
	
	if(!oldWrapper) {
		[[um prepareWithInvocationTarget:iconTray] setImage:nil];
		return YES;
	}
	
	[[um prepareWithInvocationTarget:iconTray] setImageFileWrapper:oldWrapper];
	return YES;
}

-(void)setupIconTrays
{
	id newIconTrays = [NSMutableDictionary dictionary];
	
	for(id object in [[self class] managedImageNames]) {
		id icons;
		
		icons = [[BSCSIcons alloc] init];
		[icons setTitle:NSLocalizedStringFromTable( object,  @"IconNames", @"Icon Title" )];
		[icons setPlaceholder:[IconSetComposer defaultImageForIdentifier:object]];
		[icons setIdentifier:object];
		[newIconTrays setObject:icons forKey:object];
		[icons addObserver:self
				forKeyPath:BSCIImageFileWrapperKey
				   options:NSKeyValueObservingOptionNew //| NSKeyValueObservingOptionOld
				   context:NULL];
	}
	
	[self setIconTrays:newIconTrays];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(object == colorSet) {
		NSUndoManager *um = [self undoManager];
		if([keyPath isEqualToString:@"threadsListColor"]) {
			id old = [change objectForKey:NSKeyValueChangeOldKey];
			if([old isEqual:[NSNull null]]) old = nil;
			[[um prepareWithInvocationTarget:colorSet] setThreadsListColor:old];
			return;
		}
		
		NSNumber *old = [change objectForKey:NSKeyValueChangeOldKey];
		NSNumber *new = [change objectForKey:NSKeyValueChangeNewKey];
		if([old isEqualToNumber:new]) return;
		
		if([keyPath isEqualToString:@"includeColors"]) {
			[[um prepareWithInvocationTarget:colorSet] setIncludeColors:[old boolValue]];
		} else if([keyPath isEqualToString:@"useStripe"]) {
			[[um prepareWithInvocationTarget:colorSet] setUseStripe:[old boolValue]];
		}
		
		return;
	}
	if(![keyPath isEqual:BSCIImageFileWrapperKey]) return;
	
	NSFileWrapper *imageFileWrapper = [object valueForKey:keyPath];
	NSString *identifier = [object valueForKey:BSCIIdentifierKey];
	
	[self changeFileOfImage:imageFileWrapper forIdentifier:identifier];
}

- (id)valueForUndefinedKey:(NSString *)key
{
	id result;
	
	result = [[self iconTrays] valueForKey:key];
	if(result) {
		return result;
	}
	
	if([[self deprecatedImageNames] containsObject:key]) {
		return nil;
	}
	
	return [super valueForUndefinedKey:key];
}

- (IBAction)debuggingInfo:(id)sender
{
	NSLog(@"iconTrays ->\n%@", [[self iconTrays] valueForKey:@"BoardList"]);
}

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
		NSURL *bundleURL = [self fileURL];
		NSURL *colorSetURL = [bundleURL URLByAppendingPathComponent:filename];
		[colorSet setPlistURL:colorSetURL];
	} else {
		[self setValue:fw forKeyPath:[NSString stringWithFormat:@"%@.%@", key, BSCIImageFileWrapperKey]];
	}
}
	
-(void)apply:(id)sender
{
	NSString *bathyScapheResourceFolder = [IconSetComposer bathyScapheResourceFolder];
	[IconSetComposer deleteImageFilesFromBSAppSptResFolder];
	
	id dict = [wrapper fileWrappers];
	for(NSString *file in dict) {
		if( [file hasSuffix:BSCIPlistExtension] ) continue;
		
		NSData *data = [[dict objectForKey:file] regularFileContents];
		NSString *newPath = [bathyScapheResourceFolder stringByAppendingPathComponent:file];
		
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

-(void)changeFileOfImage:(NSFileWrapper *)imageFileWrapper forIdentifier:(NSString *)identifier
{
	NSFileWrapper *fw;
	NSString *filename;
	
	filename = [imageFileWrapper preferredFilename];
	
	if(filename && ![[filename stringByDeletingPathExtension] isEqualTo:identifier] ) {
		filename = [identifier stringByAppendingPathExtension:[filename pathExtension]];
		[imageFileWrapper setPreferredFilename:filename];
	}
	
	fw = [self fileWrapperForIdentifier:identifier];
	if( fw ) {
		if( [fw isEqual:imageFileWrapper] ) {
			return;
		}
		[wrapper removeFileWrapper:fw];
	}
	
	if(imageFileWrapper) {
		filename = [wrapper addFileWrapper:imageFileWrapper];
//		NSLog(@"##### filewrapper Key -> %@", filename );
	}
}

- (void)window:(NSWindow *)window willEncodeRestorableState:(NSCoder *)state
{
	[state encodeRect:[window frame] forKey:@"BSICSWindowFrameState"];
}
- (void)window:(NSWindow *)window didDecodeRestorableState:(NSCoder *)state
{
	NSRect r = [state decodeRectForKey:@"BSICSWindowFrameState"];
	if(NSEqualRects(r, NSZeroRect)) {
		NSPoint tl = [window cascadeTopLeftFromPoint:NSMakePoint(0, 0)];
		r = [window frame];
		r.origin = tl;
		r.origin.y -= r.size.height;
	}
	
	[window setFrame:r display:NO];
}

@end

#pragma mark ## Scripting Support ##

@implementation IconSetDocument (IconSetDocumentScriptingSupport)

-(id)handleApplyCommand:(NSScriptCommand*)command
{
	[[IconSetComposer sharedInstance] quitBS];
	while([[IconSetComposer sharedInstance] isRunningBS])
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	[self apply:self];
	
	[[IconSetComposer sharedInstance] launchBS];
	while(![[IconSetComposer sharedInstance] isRunningBS])
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	return nil;
}

@end

@implementation BSISApplyCommand
- (id)performDefaultImplementation
{
	return [self commandDescription];
}

@end
