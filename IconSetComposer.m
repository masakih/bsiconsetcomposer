#import "IconSetComposer.h"

static NSString *sSupportedBSLeastVersion = @"1.0.2";
static NSString *sSupportedBSGreatestVersion = @"1.0.2";
static float sSuppoeredBSLeastBundleVersion = 60;
static float sSuppoeredBSGreatestBundleVersion = 69;
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

-(int)majorVersionFromShortVersionString:(NSString *)version
{
	NSArray *versions;
	NSString *majorVersionString;
	int result = 0;
		
	versions = [version componentsSeparatedByString:@"."];
	
	if( [versions count] > 0 ) {
		majorVersionString = [versions objectAtIndex:0];
		result = [majorVersionString intValue];
	}
	
	return result;
}

-(int)minorVersionFromShortVersionString:(NSString *)version
{
	NSArray *versions;
	NSString *minorVersionString;
	int result = 0;
		
	versions = [version componentsSeparatedByString:@"."];
	
	if( [versions count] > 1 ) {
		minorVersionString = [versions objectAtIndex:1];
		result = [minorVersionString intValue];
	}
	
	return result;
}

-(int)buildNumberFromShortVersionString:(NSString *)version
{
	NSArray *versions;
	NSString *buildNumberString;
	int result = 0;
	
	versions = [version componentsSeparatedByString:@"."];
	
	if( [versions count] > 2 ) {
		buildNumberString = [versions objectAtIndex:2];
		result = [buildNumberString intValue];
	}
	
	return result;
}

-(int)isSupportedBathyScaphe
{
	NSBundle *bsBundle;
	NSString *bsVersionString, *bsBundleVersString;
	int bsMajorVersion, bsMinorVersion, bsBuildNumber;
	float bsBundleVers;
	int greatestMajorVersion, greatestMinorVersion, greatestBuldNumber;
	int leastMajorVersion, leastMinorVersion, leastBuldNumber;
			
	bsBundle = [[self class] bathyScapheBundle];
	if( !bsBundle ) {
		return NO;
	}
		
	bsVersionString = [bsBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	bsBundleVersString = [bsBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
	bsMajorVersion = [self majorVersionFromShortVersionString:bsVersionString];
	bsMinorVersion = [self minorVersionFromShortVersionString:bsVersionString];
	bsBuildNumber = [self buildNumberFromShortVersionString:bsVersionString];
	bsBundleVers = [bsBundleVersString floatValue];
	
	greatestMajorVersion = [self majorVersionFromShortVersionString:sSupportedBSGreatestVersion];
	greatestMinorVersion = [self minorVersionFromShortVersionString:sSupportedBSGreatestVersion];
	greatestBuldNumber = [self buildNumberFromShortVersionString:sSupportedBSGreatestVersion];
	
	leastMajorVersion = [self majorVersionFromShortVersionString:sSupportedBSLeastVersion];
	leastMinorVersion = [self minorVersionFromShortVersionString:sSupportedBSLeastVersion];
	leastBuldNumber = [self buildNumberFromShortVersionString:sSupportedBSLeastVersion];
	
	
	if( bsMajorVersion > greatestMajorVersion ) {
		return kGreaterVersion;
	} else if( bsMajorVersion < leastMajorVersion ) {
		return kLeastVersion;
	}
	
	if( bsMinorVersion > greatestMinorVersion )  {
		return kGreaterVersion;
	} else if( bsMinorVersion < leastMinorVersion ) {
		return kLeastVersion;
	}

	if( bsBuildNumber > greatestBuldNumber )  {
		return kGreaterVersion;
	} else if( bsBuildNumber < leastBuldNumber ) {
		return kLeastVersion;
	}
	
	if( bsBundleVers > sSuppoeredBSGreatestBundleVersion )  {
		return kGreaterVersion;
	} else if( bsBundleVers < sSuppoeredBSLeastBundleVersion ) {
		return kLeastVersion;
	}
	
	return kSupportedVersion;
}

+(NSBundle *)bathyScapheBundle
{
	NSString *bsPath;
	NSBundle *bsBundle;
	
	bsPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:sBSIdentifer];
	bsBundle = [NSBundle bundleWithPath:bsPath];
	
	return bsBundle;
}
+(NSString *)bathyScapheSupportFolder
{
	static NSString *result = nil;
	
	if(  !result ) {
		NSArray *dirs = NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES );
		
		if( !dirs || [dirs count] == 0 ) return NSHomeDirectory();
		
		result = [dirs objectAtIndex:0];
		result = [result stringByAppendingPathComponent:@"Application Support"];
		result = [result stringByAppendingPathComponent:@"BathyScaphe"];
		result = [result stringByAppendingPathComponent:@"Resources"];
		[result retain];
		
		if( ![[NSFileManager defaultManager] fileExistsAtPath:result] ) {
			[[NSFileManager defaultManager] createDirectoryAtPath:result attributes:nil];
		}
	}
	
	return result;
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
	NSString *bathyScapheSupportFolder = [IconSetComposer bathyScapheSupportFolder];
	NSArray *imageFileType = [NSImage imageFileTypes];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray *files = [fm directoryContentsAtPath:bathyScapheSupportFolder];
	NSEnumerator *filesEnum = [files objectEnumerator];
	NSString *file;
	NSString *fullPath;
	
	while( file = [filesEnum nextObject] ) {
		NSString *filetype;
		NSString *extention;
		
		fullPath = [bathyScapheSupportFolder stringByAppendingPathComponent:file];
		filetype = NSHFSTypeOfFile( fullPath );
		extention = [file pathExtension];
		
		if( [imageFileType containsObject:filetype]
			|| [imageFileType containsObject:extention] ) {
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
	
	NSString *sbPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:sBSIdentifer];
	
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
	return [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:sBSIdentifer
																options:NSWorkspaceLaunchAllowingClassicStartup
										 additionalEventParamDescriptor:nil
													   launchIdentifier:nil];
}
-(long)quitBS
{
	NSString *bsBundleID;
	const char *bsBundleIDStr;
	OSStatus err;
	
	NSAppleEventDescriptor *ae;
	
	NSAppleEventDescriptor *bsDesc;
	
	/* set up BathyScaphe addr */
	bsBundleID = [[[self class] bathyScapheBundle] bundleIdentifier];
	bsBundleIDStr = [bsBundleID UTF8String];
	bsDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID
															bytes:bsBundleIDStr
														   length:strlen(bsBundleIDStr)];
	
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass
												  eventID:kAEQuitApplication
										 targetDescriptor:bsDesc
												 returnID:kAutoGenerateReturnID
											transactionID:kAnyTransactionID];
	
	err = AESendMessage( [ae aeDesc], NULL, kAECanInteract, kAEDefaultTimeout );
	
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

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	int result;
	
	if( ![[self class] bathyScapheBundle] ) {
		NSRunCriticalAlertPanel(@"Sorry!",
								@"BSIconSetComposer can NOT find BathyScaphe.",
								@"Quit", nil, nil,
								nil);
		[NSApp terminate:self];
		return;
	}
	
	result = [self isSupportedBathyScaphe];
	if( result == kLeastVersion ) {
		NSRunCriticalAlertPanel(@"Sorry!",
								@"This version's BSIconSetComposer not support current version BathyScaphe.",
								@"Quit", nil, nil,
								nil);
		[NSApp terminate:self];
		return;
	} else if( result == kGreaterVersion ) {
		result = NSRunCriticalAlertPanel(@"Oops!",
										 @"Current BathyScaphe version is greater than supported version.\nThe icons might have been deleted or appended.\nDo you continue?",
										 @"Quit", @"Continue", nil,
										 nil);
		if( result != NSCancelButton ) {
			[NSApp terminate:self];
			return;
		}
	}
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

@end
