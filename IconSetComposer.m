#import "IconSetComposer.h"

#import "IconSetDocument.h"

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
	NSMutableArray *decrementalImages = [NSMutableArray array];
	
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
		NSString *name = [bsResources objectAtIndex:i];
		
		if( [[self class] isAcceptImageExtension:[name pathExtension]] ) {
			if( [knownBSSystemImages containsObject:[name stringByDeletingPathExtension]] ) {
				continue;
			}
			if( ![managedImages containsObject:[name stringByDeletingPathExtension]] ) {
				status |= kBSHaveUnknownImage;
				[incrementalImages addObject:name];
				continue;
			}
			bsResourceImageNum++;
		}
	}
	if( managedImageNum > bsResourceImageNum ) {
		status |= kIconsHaveIncreased;
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
	
	NSArray *managed = [IconSetDocument managedImageNames];
	
	while( file = [filesEnum nextObject] ) {
		NSString *filetype;
		NSString *extention;
		
		fullPath = [bathyScapheSupportFolder stringByAppendingPathComponent:file];
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
