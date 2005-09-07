#import "ColorSet.h"

#import "IconSetComposer.h"

static NSString *ColorSetIdentifier = @"ColorSet";
static NSString *BoardListColorKey = @"BoardListColor";
static NSString *ThreadsListColorKey = @"ThreadsListColor";
static NSString *IncludeColorsKey = @"IncludeColors";

static int BoardListColorTag = 1;
static int ThreadsListColorTag = 2;

@interface NSColor(ColorSetSupport)
-(id)plist;
+(NSColor *)colorWithPlist:(id)plist;
@end

@implementation ColorSet

+(NSColor *)defaultBoardListColor
{
	return [NSColor colorWithCalibratedRed:0.898000001907
									 green:0.929400026798
									  blue:0.968599975109
									 alpha:1];
}
+(NSColor *)defaultThreadListColor
{
	return [NSColor whiteColor];
}

-(void)dealloc
{
	[boardListColor release];
	[threadsListColor release];
	
	[super dealloc];
}

-(void)updateUI
{
	BOOL useColor = ([includeSetCheck state] == NSOnState);
	NSColor *textColor;
	
	[applyButton setEnabled:useColor];
    [revertBoardListButton setEnabled:useColor];
    [revertThreadsListButton setEnabled:useColor];
	
	[boardListColorWell setEnabled:useColor];
    [threadsListColorWell setEnabled:useColor];
	
	if( useColor ) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	[boardListColorText setTextColor:textColor];
	[threadListColorText setTextColor:textColor];
}

-(id)plist
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if( boardListColor ) {
		[dict setObject:[boardListColor plist] forKey:BoardListColorKey];
	}
	if( threadsListColor ) {
		[dict setObject:[threadsListColor plist] forKey:ThreadsListColorKey];
	}
	[dict setObject:[NSNumber numberWithBool:isIncludeColors] forKey:IncludeColorsKey];
	
	return dict;
}

-(void)setBoardListColor:(NSColor *)color
{
	id temp = boardListColor;
	boardListColor = [color retain];
	[temp release];
	
	if( !color ) {
		color = [[self class] defaultBoardListColor];
	}
	[boardListColorWell setColor:color];
}
-(void)setThreadsListColor:(NSColor *)color
{
	id temp = threadsListColor;
	threadsListColor = [color retain];
	[temp release];
	
	if( !color ) {
		color = [[self class] defaultThreadListColor];
	}
	[threadsListColorWell setColor:color];
}
-(void)setIsIncludeColors:(BOOL)flag
{
	isIncludeColors = flag;
	[includeSetCheck setState: flag ? NSOnState : NSOffState];
	[self updateUI];
}

typedef enum {
	kTypeBoardListColor,
	kTypeThreadsListColor,
} ColorType;
-(void)sendingSetColor:(ColorType)colorType
{
	NSString *bsBundleID;
	const char *bsBundleIDStr;
	OSType type;
	id targetColor;
	id tempColor;
	float red, green, blue, alpha;
	OSStatus err;
	
	NSAppleEventDescriptor *ae;
	
	NSAppleEventDescriptor *bsDesc;
	
	NSAppleEventDescriptor *propDesc;
	
	NSAppleEventDescriptor *classDesc;
	NSAppleEventDescriptor *formDesc;
	NSAppleEventDescriptor *keyDataDesc;
	
	NSAppleEventDescriptor *colorDesc;
	NSAppleEventDescriptor *redDesc;
	NSAppleEventDescriptor *greenDesc;
	NSAppleEventDescriptor *blueDesc;
	
	switch(colorType) {
		case kTypeBoardListColor:
			type = 'bdCo';
			targetColor = boardListColor;
			break;
		case kTypeThreadsListColor:
			type = 'brCo';
			targetColor = threadsListColor;
			break;
		default:
			return;
	}
	
	/* set up BathyScaphe addr */
	bsBundleID = [[IconSetComposer bathyScapheBundle] bundleIdentifier];
	bsBundleIDStr = [bsBundleID UTF8String];
	bsDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeApplicationBundleID
															bytes:bsBundleIDStr
														   length:strlen(bsBundleIDStr)];
	
	/* Setting color */
	if( targetColor ) {
		tempColor = [targetColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
		
		redDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeShortFloat
																 bytes:&red
																length:sizeof(red)];
		greenDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeShortFloat
																   bytes:&green
																  length:sizeof(green)];
		blueDesc = [NSAppleEventDescriptor descriptorWithDescriptorType:typeShortFloat
																  bytes:&blue
																 length:sizeof(blue)];
		colorDesc = [NSAppleEventDescriptor listDescriptor];
		[colorDesc insertDescriptor:redDesc atIndex:1];
		[colorDesc insertDescriptor:greenDesc atIndex:2];
		[colorDesc insertDescriptor:blueDesc atIndex:3];
	} else {
		// 
		colorDesc = [NSAppleEventDescriptor listDescriptor];
	}
	
	/* create typeObjectSpecifier Descriptor */
	propDesc = [NSAppleEventDescriptor recordDescriptor];
	
	classDesc = [NSAppleEventDescriptor descriptorWithTypeCode:formPropertyID];
	[propDesc setDescriptor:classDesc forKeyword:keyAEDesiredClass];
	
	formDesc = [NSAppleEventDescriptor descriptorWithTypeCode:formPropertyID];
	[propDesc setDescriptor:formDesc forKeyword:keyAEKeyForm];
	
	keyDataDesc = [NSAppleEventDescriptor descriptorWithTypeCode:type];
	[propDesc setDescriptor:keyDataDesc forKeyword:keyAEKeyData];
	
	[propDesc setDescriptor:[NSAppleEventDescriptor nullDescriptor] forKeyword:keyAEContainer];
	
	propDesc = [propDesc coerceToDescriptorType:typeObjectSpecifier];
	
	/* create AppleEvent */
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kAECoreSuite
												  eventID:kAESetData
										 targetDescriptor:bsDesc
												 returnID:kAutoGenerateReturnID
											transactionID:kAnyTransactionID];
	
	[ae setParamDescriptor:colorDesc forKeyword:keyAEData];
	[ae setParamDescriptor:propDesc forKeyword:keyDirectObject];

#ifdef DEBUG
	{
		Handle h = NewHandle( sizeof(char*) );
		err = AEPrintDescToHandle( [ae aeDesc], &h );
		NSLog(@"Desc -> %s", **(char ***)&h );
		DisposeHandle( h );
	}
#endif
	
	err = AESendMessage( [ae aeDesc], NULL, kAECanInteract, kAEDefaultTimeout );
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %d", err );
	}
}

-(void)awakeFromNib
{
//	[includeSetCheck setState:NSOffState];
	
	[self updateUI];
}

- (IBAction)applyColors:(id)sender
{
	if( isIncludeColors ) {
		[self sendingSetColor:kTypeBoardListColor];
		[self sendingSetColor:kTypeThreadsListColor];
	}
}

- (IBAction)changeColor:(id)sender
{
	int tag;
	
	if( ![sender respondsToSelector:@selector(tag)]
		&& ![sender respondsToSelector:@selector(color)] ) {
		return;
	}
	
	tag = [sender tag];
	
	if( tag == BoardListColorTag ) {
		[self setBoardListColor:[sender color]];
	} else if( tag == ThreadsListColorTag ) {
		[self setThreadsListColor:[sender color]];
	} else {
		return;
	}
	
	[delegate setPlist:[self plist] forIdentifier:ColorSetIdentifier];
}

- (IBAction)revertColor:(id)sender
{
	int tag;
	
	if( ![sender respondsToSelector:@selector(tag)] ) {
		return;
	}
	
	tag = [sender tag];
	
	if( tag == BoardListColorTag ) {
		[self setBoardListColor:nil];
	} else if( tag == ThreadsListColorTag ) {
		[self setThreadsListColor:nil];
	} else {
		return;
	}
	
	[delegate setPlist:[self plist] forIdentifier:ColorSetIdentifier];
}

- (IBAction)toggleIncludeColorSet:(id)sender
{
	isIncludeColors = ([sender state] == NSOnState);
	[self updateUI];
	
	[delegate setPlist:[self plist] forIdentifier:ColorSetIdentifier];
}

-(BOOL)setPlistPath:(NSString *)path
{
	NSDictionary *dict;
	NSColor *color;
	
	dict = [NSDictionary dictionaryWithContentsOfFile:path];
	if( !dict ) {
		return NO;
	}
	
	color = [NSColor colorWithPlist:[dict objectForKey:BoardListColorKey]];
	[self setBoardListColor:color];
	
	color = [NSColor colorWithPlist:[dict objectForKey:ThreadsListColorKey]];
	[self setThreadsListColor:color];
	
	[self setIsIncludeColors:[[dict objectForKey:IncludeColorsKey] boolValue]];
	
	return YES;
}

-(NSView *)view
{
	return view;
}

@end

@implementation NSColor(ColorSetSupport)
static NSString *RedKey = @"Red";
static NSString *GreenKey = @"Green";
static NSString *BlueKey = @"Blue";
static NSString *AlphaKey = @"Alpha";

-(id)plist
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	float red, green, blue, alpha;
	
	self = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	[self getRed:&red green:&green blue:&blue alpha:&alpha];
	
	[dict setObject:[NSNumber numberWithFloat:red] forKey:RedKey];
	[dict setObject:[NSNumber numberWithFloat:green] forKey:GreenKey];
	[dict setObject:[NSNumber numberWithFloat:blue] forKey:BlueKey];
	[dict setObject:[NSNumber numberWithFloat:alpha] forKey:AlphaKey];
	
	return dict;
}
+(NSColor *)colorWithPlist:(id)plist
{
	id red, green, blue, alpha;
	
	if( ![plist respondsToSelector:@selector(objectForKey:)] ) return nil;
	
	red = [plist objectForKey:RedKey];
	green = [plist objectForKey:GreenKey];
	blue = [plist objectForKey:BlueKey];
	alpha = [plist objectForKey:AlphaKey];
	
	if( !red || !green || !blue || !alpha ) return nil;
	
	return [self colorWithCalibratedRed:[red floatValue]
							 green:[green floatValue]
							   blue:[blue floatValue]
							   alpha:[alpha floatValue]];
}
	
@end
