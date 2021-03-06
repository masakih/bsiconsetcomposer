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
-(NSUInteger)retainCount { return UINT_MAX; }

-(BOOL)askContinuesWithStatus:(int)status
			  andIncrementals:(NSArray *)incrementalImages
			  andDecrementals:(NSArray *)decrementalImages
{
	int result;
	
	NSString *title = NSLocalizedString( @"Caution!", @"Caution!" );
	NSString *message = @"";
	NSString *defaultCaption = NSLocalizedString( @"Quit", @"Quit" );
	NSString *alternateCaption = NSLocalizedString( @"Continue", @"Continue" );
	
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
	NSBundle *bsBundle = [[self class] bathyScapheBundle];
	if( !bsBundle ) {
		return NO;
	}
	
	NSUInteger bsResourceImageNum = 0;
	NSInteger status = 0;
	NSMutableArray *incrementalImages = [NSMutableArray array];
	NSMutableArray *decrementalImages = nil;
	NSMutableArray *containsImages = [NSMutableArray array];
	id fm = [NSFileManager defaultManager];
	NSString *bsResourcesPath = [bsBundle resourcePath];
	NSArray *bsResources = [fm directoryContentsAtPath:bsResourcesPath];
	
	NSArray *managedImages = [IconSetDocument managedImageNames];
	NSUInteger managedImageNum = [managedImages count];
	
	NSArray *knownBSSystemImages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BathyScapheSystemImages"
																									ofType:@"plist"]];
	
	for(NSString *filename in bsResources) {		
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
		NSArray *deprecatedImages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DeprecatedImageList"
																									 ofType:@"plist"]];
		NSArray *notHaveDefault = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NotHaveDefaultImageList"
																									 ofType:@"plist"]];
		
		decrementalImages = [[managedImages mutableCopy] autorelease];
		[decrementalImages removeObjectsInArray:containsImages];
		[decrementalImages removeObjectsInArray:deprecatedImages];
		[decrementalImages removeObjectsInArray:notHaveDefault];
		if([decrementalImages count] > 0) {
			status |= kIconsHaveIncreased;
		}
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
	NSString *bsPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[self bathyScapheIdentifier]];
	NSBundle *bsBundle = [NSBundle bundleWithPath:bsPath];
	
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
	
	if( !result ) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains( NSApplicationSupportDirectory, NSUserDomainMask, YES );
		NSString *tmp;
		
		if( !dirs || [dirs count] == 0 ) return NSHomeDirectory();
		
		result = [dirs objectAtIndex:0];
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
	
	if( !result ) {
		NSString *tmp;
		
		result = [self bathyScapheSupportFolder];
		result = [result stringByAppendingPathComponent:@"Resources"];
		tmp = resolveAlias( result );
		if( tmp ) result = tmp;
		[result retain];
		
		NSError *error = NULL;
		if( ![[NSFileManager defaultManager] fileExistsAtPath:result] ) {
			[[NSFileManager defaultManager] createDirectoryAtPath:result
									  withIntermediateDirectories:YES
													   attributes:nil
															error:&error];
			if(!error) {
				NSLog(@"%@", error);
			}
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
	NSString *path = [bsBundle pathForImageResource:identifier];
	NSImage *image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	
	return image;
}

+(void)deleteImageFilesFromBSAppSptResFolder
{
	NSString *bathyScapheResourceFolder = [IconSetComposer bathyScapheResourceFolder];
	NSArray *imageFileType = [NSImage imageFileTypes];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *files = [fm contentsOfDirectoryAtPath:bathyScapheResourceFolder error:NULL];
	NSString *fullPath;
	
	NSArray *managed = [IconSetDocument managedImageNames];
	
	for(NSString *file in files) {
		NSString *filetype;
		NSString *extention;
		
		fullPath = [bathyScapheResourceFolder stringByAppendingPathComponent:file];
		filetype = NSHFSTypeOfFile( fullPath );
		extention = [file pathExtension];
		
		if( [managed containsObject:[file stringByDeletingPathExtension]] &&
			([imageFileType containsObject:filetype]
			 || [imageFileType containsObject:extention]) ) {
			[fm removeItemAtPath:fullPath error:NULL];
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
		array = [[NSArray arrayWithObjects:@"png", @"tiff", @"tif", @"pdf", nil] retain];
	}
	
	return array;
}


- (NSImage *)dropToMeImage
{
	return [NSImage imageNamed:@"DropToMe"];
}

-(BOOL)isRunningBS
{
	NSString *sbPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:[self bathyScapheIdentifier]];
	
	NSArray *array = [[NSWorkspace sharedWorkspace] launchedApplications];
	for(NSDictionary *dict in array) {
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
	
	/* set up BathyScaphe addr */
	NSAppleEventDescriptor *bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:[self bathyScapheIdentifier]];
	
	NSAppleEventDescriptor *ae = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass
																		  eventID:kAEQuitApplication
																 targetDescriptor:bsDesc
																		 returnID:kAutoGenerateReturnID
																	transactionID:kAnyTransactionID];
	
	err = [ae sendAppleEventWithMode:kAECanInteract | kAEWaitReply
					  timeOutInTicks:kAEDefaultTimeout
							   reply:NULL];
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %ld", (long)err );
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
	NSArray *imageNames = [IconSetDocument managedImageNames];
	NSString *bsSupPath = [[self class] bathyScapheSupportFolder];
	NSBundle *bsSupBundle = [NSBundle bundleWithPath:bsSupPath];
	
	if(!imageNames || !bsSupBundle) {
		NSLog(@"HOGE!!");
		NSBeep();
		return;
	}
	
	IconSetDocument *newDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentOfType:@"IconSetType"
																									   display:NO];
	if(!newDocument) {
		NSLog(@"Can not create new document.");
		NSBeep();
		return;
	}
	
	for(NSString *imageName in imageNames) {
		NSString *imagePath = [bsSupBundle pathForImageResource:imageName];
		[newDocument setPath:imagePath forIdentifier:imageName];
	}
	
	NSColor *tlColor = [ColorSet getBathyScapheColor:kTypeThreadsListColor];
	NSNumber *isIncludeColor;
	id set;
	
	if(![[ColorSet defaultThreadsListColor] isEqual:tlColor]) {
		isIncludeColor = [NSNumber numberWithBool:YES];
	} else {
		isIncludeColor = [NSNumber numberWithBool:NO];
	}
	
	[newDocument windowForSheet];	// load nib.
	set = [newDocument valueForKey:@"colorSet"];
	[set setValue:tlColor forKey:@"threadsListColor"];
	[set setValue:isIncludeColor forKey:@"isIncludeColors"];
	
	[newDocument updateChangeCount:NSChangeCleared];
	
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
