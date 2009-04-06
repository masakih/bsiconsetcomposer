#import "IconSetComposer.h"

#import "IconSetDocument.h"
#import "ColorSet.h"

#import "NSAppleEventDescriptor-Extensions.h"

static NSString *sBSIdentifer = @"jp.tsawada2.BathyScaphe";

static IconSetComposer *_instance = nil;

@implementation IconSetComposer

+(id)sharedInstance
{
	if( !_instance ) {
		_instance = [[[super class] alloc] init];
	}
	
	return _instance;
}
-(oneway void)release {}
-(id)retain { return self; }
-(unsigned)retainCount { return UINT_MAX; }

-(BOOL)askContinuesWithStatus:(int)status
			  andIncrementals:(NSArray *)incrementalImages
			  andDecrementals:(NSArray *)decrementalImages
{
	int result;
	//
	NSString *title = NSLocalizedString( @"Caution!", @"Caution!" );
	NSString *message;
	NSString *defaultCaption = NSLocalizedString( @"Quit", @"Quit" );
	NSString *alternateCaption = NSLocalizedString( @"Continue", @"Continue" );
//	NSString *otherCaption;
	
	NSString *tmpString;
	NSString *inc = nil;
	NSString *dec = nil;
	
	if( status & kBSHaveUnknownImage ) {
		tmpString = NSLocalizedString( @"Message001", @"images have incremented.");
		inc = [NSString stringWithFormat:tmpString, incrementalImages];
	}
	if( status & kIconsHaveIncreased ) {
		tmpString = NSLocalizedString( @"Message002", @"images have decremented.");
		dec = [NSString stringWithFormat:tmpString, decrementalImages];
	}
	
	if( inc && dec ) {
		tmpString = NSLocalizedString( @"%@ And %@", @"Both alert" );
		message = [NSString stringWithFormat:tmpString, inc, dec];
	} else if( inc ) {
		message = [NSString stringWithFormat:inc, incrementalImages];
	} else if( dec ) {
		message = [NSString stringWithFormat:dec, decrementalImages];
	} else {
		return YES;
	}
	
	tmpString = NSLocalizedString( @"Do you continue?", @"Do you continue?" );
	message = [message stringByAppendingString:tmpString];
	
	result = NSRunCriticalAlertPanel( title, message, defaultCaption, alternateCaption, nil);
	
	return (result != NSOKButton);
}
-(BOOL)isSupportedBathyScaphe
{
	NSBundle *bsBundle;
	NSString *bsResourcesPath;
	NSArray *bsResources;
	NSArray *knownBSSystemImages;
	NSArray *managedImages;
	unsigned managedImageNum;
	unsigned i, count;
	unsigned bsResourceImageNum = 0;
	id fm;
	int status = 0;
	NSMutableArray *incrementalImages = [NSMutableArray array];
	NSMutableArray *decrementalImages = nil;
	NSMutableArray *containsImages = [NSMutableArray array];
	
	bsBundle = [[self class] bathyScapheBundle];
	if( !bsBundle ) {
		return NO;
	}
	
	fm = [NSFileManager defaultManager];
	bsResourcesPath = [bsBundle resourcePath];
	bsResources = [fm directoryContentsAtPath:bsResourcesPath];
	
	managedImages = [IconSetDocument managedImageNames];
	managedImageNum = [managedImages count];
	
	knownBSSystemImages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BathyScapheSystemImages"
																						   ofType:@"plist"]];
	
	count = [bsResources count];
	for( i = 0; i < count; i++ ) {
		NSString *filename = [bsResources objectAtIndex:i];
		
		if( [[self class] isAcceptImageExtension:[filename pathExtension]] ) {
			NSString *name = [filename stringByDeletingPathExtension];
			if( [knownBSSystemImages containsObject:name] ) {
				continue;
			}
			if( ![managedImages containsObject:name] ) {
				status |= kBSHaveUnknownImage;
				[incrementalImages addObject:name];
				continue;
			}
			bsResourceImageNum++;
			[containsImages addObject:name];
		}
	}
	if( managedImageNum > bsResourceImageNum ) {
		status |= kIconsHaveIncreased;
		decrementalImages = [[managedImages mutableCopy] autorelease];
		[decrementalImages removeObjectsInArray:containsImages];
	}
	
	if( status ) {
		return [self askContinuesWithStatus:status
							andIncrementals:incrementalImages
							andDecrementals:decrementalImages];
	}
	
	return YES;
}

+(NSBundle *)bathyScapheBundle
{
	NSString *bsPath;
	NSBundle *bsBundle;
	
	bsPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[self bathyScapheIdentifier]];
	bsBundle = [NSBundle bundleWithPath:bsPath];
	
	return bsBundle;
}
NSString *resolveAlias(NSString *path)
{
	NSString *newPath = nil;

	FSRef	ref;
	char *newPathCString;
	Boolean isDir,  wasAliased;
	OSStatus err;

	err = FSPathMakeRef( (UInt8 *)[path fileSystemRepresentation], &ref, NULL );
	if( err == dirNFErr ) {
		NSString *lastPath = [path lastPathComponent];
		NSString *parent = [path stringByDeletingLastPathComponent];
		NSString *f;
		
		if( [@"/" isEqualTo:parent] ) return nil;
		
		parent = resolveAlias( parent );
		if( !parent ) return nil;

		f = [parent stringByAppendingPathComponent:lastPath];
		
		err = FSPathMakeRef( (UInt8 *)[f fileSystemRepresentation], &ref, NULL );
	}
	if( err != noErr ) {
		return nil;
	}

	err = FSResolveAliasFile( &ref, TRUE, &isDir, &wasAliased );
	if( err != noErr ) {
		return nil;
	}

	newPathCString = (char *)malloc( sizeof(unichar) * 1024 );
	if( !newPathCString ) {
		return nil;
	}

	err = FSRefMakePath( &ref, (UInt8 *)newPathCString, sizeof(unichar) * 1024 );
	if( err != noErr ) {
		goto final;
	}

	newPath = [NSString stringWithUTF8String:newPathCString];

final:
	free( (char *)newPathCString );

	return newPath;
}
+(NSString *)bathyScapheSupportFolder
{
	static NSString *result = nil;
	
	if(  !result ) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES );
		NSString *tmp;
		
		if( !dirs || [dirs count] == 0 ) return NSHomeDirectory();
		
		result = [dirs objectAtIndex:0];
		result = [result stringByAppendingPathComponent:@"Application Support"];
		result = [result stringByAppendingPathComponent:@"BathyScaphe"];
		tmp = resolveAlias( result );
		if( tmp ) result = tmp;
		[result retain];
	}
	
	return result;
}

+(NSString *)bathyScapheResourceFolder
{
	static NSString *result = nil;
	
	if(  !result ) {
		NSString *tmp;
		
		result = [self bathyScapheSupportFolder];
		result = [result stringByAppendingPathComponent:@"Resources"];
		tmp = resolveAlias( result );
		if( tmp ) result = tmp;
		[result retain];
		
		if( ![[NSFileManager defaultManager] fileExistsAtPath:result] ) {
			[[NSFileManager defaultManager] createDirectoryAtPath:result attributes:nil];
		}
	}
	
	return result;
}
+(NSString *)bathyScapheIdentifier
{
	NSString *result = nil;
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	result = [ud stringForKey:@"TargetIdentifier"];
	if(!result) {
		result = sBSIdentifer;
	}
	
	return result;
}
-(NSString *)bathyScapheIdentifier
{
	return [[self class] bathyScapheIdentifier];
}
+(NSImage *)defaultImageForIdentifier:(NSString *)identifier
{
	NSBundle *bsBundle = [self bathyScapheBundle];
	
	NSString *path;
	NSImage *image;
	
	path = [bsBundle pathForImageResource:identifier];
	image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	
	return image;
}

+(void)deleteImageFilesFromBSAppSptResFolder
{
	NSString *bathyScapheResourceFolder = [IconSetComposer bathyScapheResourceFolder];
	NSArray *imageFileType = [NSImage imageFileTypes];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *files = [fm directoryContentsAtPath:bathyScapheResourceFolder];
	NSEnumerator *filesEnum = [files objectEnumerator];
	NSString *file;
	NSString *fullPath;
	
	NSArray *managed = [IconSetDocument managedImageNames];
	
	while( file = [filesEnum nextObject] ) {
		NSString *filetype;
		NSString *extention;
		
		fullPath = [bathyScapheResourceFolder stringByAppendingPathComponent:file];
		filetype = NSHFSTypeOfFile( fullPath );
		extention = [file pathExtension];
		
		if( [managed containsObject:[file stringByDeletingPathExtension]] &&
			([imageFileType containsObject:filetype]
			 || [imageFileType containsObject:extention]) ) {
			[fm removeFileAtPath:fullPath handler:nil];
		}
	}
}

+(BOOL)isAcceptImageExtension:(NSString *)ext
{
	id lower = [ext lowercaseString];
	
	return [[self acceptImageExtensions] containsObject:lower];
}
+(NSArray *)acceptImageExtensions
{
	static NSArray *array = nil;
	
	if( !array ) {
		array = [[NSArray arrayWithObjects:@"png", @"tiff", @"tif", nil] retain];
	}
	
	return array;
}

-(BOOL)isRunningBS
{
	NSArray *array;
	unsigned i, count;
	NSDictionary *dict;
	
	NSString *sbPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[self bathyScapheIdentifier]];
	
	array = [[NSWorkspace sharedWorkspace] launchedApplications];
	count = [array count];
	for( i = 0; i < count; i++ ) {
		dict = [array objectAtIndex:i];
		if( [[dict objectForKey:@"NSApplicationPath"] isEqualTo:sbPath] ) {
			return YES;
		}
	}
	
	return NO;
}

-(BOOL)launchBS
{
	return [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:[self bathyScapheIdentifier]
																options:NSWorkspaceLaunchWithoutActivation
										 additionalEventParamDescriptor:nil
													   launchIdentifier:nil];
}
-(long)quitBS
{
	OSStatus err;
	NSAppleEventDescriptor *ae;
	NSAppleEventDescriptor *bsDesc;
	
	/* set up BathyScaphe addr */
	bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:[self bathyScapheIdentifier]];
	
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass
												  eventID:kAEQuitApplication
										 targetDescriptor:bsDesc
												 returnID:kAutoGenerateReturnID
											transactionID:kAnyTransactionID];
	
//	err = AESendMessage( [ae aeDesc], NULL, kAECanInteract, kAEDefaultTimeout );
	err = [ae sendAppleEventWithMode:kAECanInteract | kAEWaitReply
					  timeOutInTicks:kAEDefaultTimeout
							   reply:NULL];
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %d", err );
	}
	
	return err;
}

-(void)waitTerminateAndLaunchBS
{
	while( [self isRunningBS] ) ;
	
	if( [self launchBS] ) {
		NSLog(@"OK! BathyScaphe is launched");
	}
}
-(void)restartBathyScaphe_real:(id)sender
{
	[self quitBS];
	[self performSelector:@selector(waitTerminateAndLaunchBS)
			   withObject:nil
			   afterDelay:0.0];
}
-(void)restartBathyScaphe:(id)sender
{
	[self performSelector:@selector(restartBathyScaphe_real:)
			   withObject:sender
			   afterDelay:0.0];
}

#pragma mark## Actions ##
-(IBAction)quitBathyScaphe:(id)sender
{
	[self quitBS];
}
-(IBAction)launchBathyScaphe:(id)sender
{
	[self performSelector:@selector(waitTerminateAndLaunchBS)
			   withObject:nil
			   afterDelay:0.0];
}
-(IBAction)createDocumentFromCurrentSetting:(id)sender
{
	NSString *bsSupPath = [[self class] bathyScapheSupportFolder];
	NSBundle *bsSupBundle;
	NSArray *imageNames = [IconSetDocument managedImageNames];
	NSEnumerator *imageNamesEnum;
	NSString *imageName;
	NSString *imagePath;
	
	IconSetDocument *newDocument;
	
	bsSupBundle = [NSBundle bundleWithPath:bsSupPath];
	
	if(!imageNames || !bsSupBundle) {
		NSLog(@"HOGE!!");
		NSBeep();
		return;
	}
	
	newDocument = [[NSDocumentController sharedDocumentController]
		openUntitledDocumentOfType:@"IconSetType"
						   display:NO];
	if(!newDocument) {
		NSLog(@"Can not create new document.");
		NSBeep();
		return;
	}
	
	imageNamesEnum = [imageNames objectEnumerator];
	while(imageName = [imageNamesEnum nextObject]) {
		imagePath = [bsSupBundle pathForImageResource:imageName];
		[newDocument setPath:imagePath forIdentifier:imageName];
	}
	
	NSColor *blColor = [ColorSet getBathyScapheColor:kTypeBoardListColor];
	NSColor *bliColor = [ColorSet getBathyScapheColor:kTypeBoardListInactiveColor];
	NSColor *tlColor = [ColorSet getBathyScapheColor:kTypeThreadsListColor];
	NSNumber *isIncludeColor;
	id set;
	
	if( ![[ColorSet defaultBoardListColor] isEqual:blColor]
		|| ![[ColorSet defaultBoardListInactiveColor] isEqual:bliColor]
		|| ![[ColorSet defaultThreadsListColor] isEqual:tlColor]) {
		isIncludeColor = [NSNumber numberWithBool:YES];
	} else {
		isIncludeColor = [NSNumber numberWithBool:NO];
	}
	
	[newDocument windowForSheet];	// load nib.
	set = [newDocument valueForKey:@"colorSet"];
	[set setValue:blColor forKey:@"boardListColor"];
	[set setValue:bliColor forKey:@"boardListInactiveColor"];
	[set setValue:tlColor forKey:@"threadsListColor"];
	[set setValue:isIncludeColor forKey:@"isIncludeColors"];
	
	[newDocument showWindows];
}

#pragma mark## Application Delegate ##
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{	
	if( ![[self class] bathyScapheBundle] ) {
		NSRunCriticalAlertPanel( NSLocalizedString( @"Sorry!", @"Sorry!" ), 
								 NSLocalizedString( @"BSIconSetComposer can NOT find BathyScaphe.", @"Can not Find BathyScaphe") ,
								 NSLocalizedString( @"Quit", @"Quit" ), nil, nil,
								 nil);
		[NSApp terminate:self];
		return;
	}
	
	if( ![self isSupportedBathyScaphe] ) {
		[NSApp terminate:self];
		return;
	}
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

@end
