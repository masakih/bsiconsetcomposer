#import "ColorSet.h"

#import "IconSetComposer.h"

#import "BSCSUserDefaults.h"
#import "NSAppleEventDescriptor-Extensions.h"

static NSString *ColorSetIdentifier = @"ColorSet";
static NSString *ThreadsListColorKey = @"ThreadsListColor";
static NSString *IncludeColorsKey = @"IncludeColors";
static NSString *UseStripeKey = @"UseStripe";
static NSString *ContentHeaderTextColorIsBlackKey = @"ContentHeaderTextColorIsBlackKey";

enum {
	ThreadsListColorTag = 2,
};

@interface NSColor(ColorSetSupport)
- (id)plist;
+ (NSColor *)colorWithPlist:(id)plist;
@end

@implementation ColorSet
@synthesize useStripe = isUseStripe;
@synthesize includeColors = isIncludeColors;

+ (NSColor *)defaultThreadsListColor
{
	return [NSColor colorWithCalibratedRed:1
									 green:1
									  blue:1
									 alpha:1];
}

- (void)dealloc
{
	[threadsListColor release];
	
	[super dealloc];
}

- (void)updateUI
{
	NSColor *textColor;
	
	if( isIncludeColors ) {
		textColor = [NSColor controlTextColor];
	} else if( isIncludeColors && !isUseStripe) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	[threadListColorText setTextColor:textColor];
	
}

- (id)plist
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if( threadsListColor ) {
		[dict setObject:[threadsListColor plist] forKey:ThreadsListColorKey];
	}
	[dict setObject:[NSNumber numberWithBool:isIncludeColors] forKey:IncludeColorsKey];
	[dict setObject:[NSNumber numberWithBool:isUseStripe] forKey:UseStripeKey];
	
	
	return dict;
}
- (NSColor *)threadsListColor
{
	return threadsListColor;
}
- (void)setThreadsListColor:(NSColor *)color
{
	if(delegate && [delegate respondsToSelector:@selector(willChangeColorSet:)]) {
		[delegate willChangeColorSet:self];
	}
	
	id temp = threadsListColor;
	threadsListColor = [color retain];
	[temp release];
	
	if( !color ) {
		color = [[self class] defaultThreadsListColor];
	}
	[threadsListColorWell setColor:color];
	
	if(delegate && [delegate respondsToSelector:@selector(didChangeColorSet:)]) {
		[delegate didChangeColorSet:self];
	}
}
- (void)setIncludeColors:(BOOL)flag
{
	if(delegate && [delegate respondsToSelector:@selector(willChangeColorSet:)]) {
		[delegate willChangeColorSet:self];
	}
	
	isIncludeColors = flag;
	[includeSetCheck setState: flag ? NSOnState : NSOffState];
	[self updateUI];
	
	if(delegate && [delegate respondsToSelector:@selector(didChangeColorSet:)]) {
		[delegate didChangeColorSet:self];
	}
}
- (void)setUseStripe:(BOOL)flag
{
	if(delegate && [delegate respondsToSelector:@selector(willChangeColorSet:)]) {
		[delegate willChangeColorSet:self];
	}
	
	isUseStripe = flag;
	[useStripeCheck setState: flag ? NSOnState : NSOffState];
	[self updateUI];
	
	if(delegate && [delegate respondsToSelector:@selector(didChangeColorSet:)]) {
		[delegate didChangeColorSet:self];
	}
}

- (BOOL)isThreadsListColorDefault
{
	if(![self threadsListColor]) return YES;
	return [[self threadsListColor] isEqual:[[self class] defaultThreadsListColor]];
}

-(void)sendingSetColor:(ColorType)colorType
{
	OSType type;
	id targetColor;
	OSStatus err;
	
	switch(colorType) {
		case kTypeThreadsListColor:
			type = 'brCo';
			targetColor = threadsListColor;
			if([self isThreadsListColorDefault]) {
				targetColor = nil;
			}
			break;
		default:
			return;
	}
	
	/* set up BathyScaphe addr */
	NSString *bsBundleID = [[IconSetComposer bathyScapheBundle] bundleIdentifier];
	NSAppleEventDescriptor *bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:bsBundleID];
	
	/* Setting color */
	NSAppleEventDescriptor *colorDesc = [NSAppleEventDescriptor listDescriptor];;
	if( targetColor ) {
		CGFloat red, green, blue, alpha;
		id tempColor = [targetColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
		
		NSAppleEventDescriptor *redDesc = [NSAppleEventDescriptor descriptorWithFloat:red];
		NSAppleEventDescriptor *greenDesc = [NSAppleEventDescriptor descriptorWithFloat:green];
		NSAppleEventDescriptor *blueDesc = [NSAppleEventDescriptor descriptorWithFloat:blue];
		
		colorDesc = [NSAppleEventDescriptor listDescriptor];
		[colorDesc insertDescriptor:redDesc atIndex:1];
		[colorDesc insertDescriptor:greenDesc atIndex:2];
		[colorDesc insertDescriptor:blueDesc atIndex:3];
	}
	
	/* create typeObjectSpecifier Descriptor */
	NSAppleEventDescriptor *keyDataDesc = [NSAppleEventDescriptor descriptorWithTypeCode:type];	
	NSAppleEventDescriptor *propDesc = [NSAppleEventDescriptor objectSpecifierWithDesiredClass:cProperty
																					 container:nil
																					   keyForm:formPropertyID
																					   keyData:keyDataDesc];
	
	/* create AppleEvent */
	NSAppleEventDescriptor *ae = [NSAppleEventDescriptor appleEventWithEventClass:kAECoreSuite
																		  eventID:kAESetData
																 targetDescriptor:bsDesc
																		 returnID:kAutoGenerateReturnID
																	transactionID:kAnyTransactionID];
	
	[ae setParamDescriptor:colorDesc forKeyword:keyAEData];
	[ae setParamDescriptor:propDesc forKeyword:keyDirectObject];

#ifdef DEBUG
	NSLog(@"%@", ae);
#endif
	
	err = AESendMessage( [ae aeDesc], NULL, kAECanInteract, kAEDefaultTimeout );
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %ld", (long)err );
	}
}
+ (NSColor *)getBathyScapheColor:(ColorType)colorType
{
	OSType type;
	id result = nil;
	OSStatus err;
	
	[[IconSetComposer sharedInstance] launchBS];
	
	switch(colorType) {
		case kTypeThreadsListColor:
			type = 'brCo';
			break;
		default:
			return nil;
	}
	
	/* set up BathyScaphe addr */
	NSString *bsBundleID = [[IconSetComposer bathyScapheBundle] bundleIdentifier];
	NSAppleEventDescriptor *bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:bsBundleID];
	
	
	/* create typeObjectSpecifier Descriptor */
	NSAppleEventDescriptor *keyDataDesc = [NSAppleEventDescriptor descriptorWithTypeCode:type];	
	NSAppleEventDescriptor *propDesc = [NSAppleEventDescriptor objectSpecifierWithDesiredClass:cProperty
																					 container:nil
																					   keyForm:formPropertyID
																					   keyData:keyDataDesc];
	
	/* create AppleEvent */
	NSAppleEventDescriptor *ae = [NSAppleEventDescriptor appleEventWithEventClass:kAECoreSuite
																		  eventID:kAEGetData
																 targetDescriptor:bsDesc
																		 returnID:kAutoGenerateReturnID
																	transactionID:kAnyTransactionID];
	
	[ae setParamDescriptor:propDesc forKeyword:keyDirectObject];
	
#ifdef DEBUG
	NSLog(@"%@", ae);
#endif
	
	NSAppleEventDescriptor *replyDesc;
	err = [ae sendAppleEventWithMode:kAECanInteract + kAEWaitReply
					  timeOutInTicks:kAEDefaultTimeout
							   reply:&replyDesc];
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %ld", (long)err );
		return nil;
	}
	
#ifdef DEBUG
	NSLog(@"%@", replyDesc);
#endif
	NSAppleEventDescriptor *colorComponentDesc;
	NSAppleEventDescriptor *colorComponentsDesc = [replyDesc paramDescriptorForKeyword:keyDirectObject];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:1];
	CGFloat red = [[colorComponentDesc stringValue] floatValue];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:2];
	CGFloat green = [[colorComponentDesc stringValue] floatValue];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:3];
	CGFloat blue = [[colorComponentDesc stringValue] floatValue];
	
	result = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1];
	
	return result;
}

- (void)awakeFromNib
{
	
	[self updateUI];
}

- (IBAction)applyColors:(id)sender
{
	if(!isIncludeColors) return;
	
	id userDefault;
	id subKey;
	
	[[IconSetComposer sharedInstance] quitBS];
	while([[IconSetComposer sharedInstance] isRunningBS])
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	
	subKey = [[[BSCSBoolUserDefault alloc] initWithKey:@"ThreadsList Draws Striped"] autorelease];
	userDefault = [[[BSCSDictUserDefault alloc] initWithKey:@"Preferences - BackgroundColors"
													 subKey:subKey] autorelease];
	[userDefault writeWithDomain:[IconSetComposer bathyScapheIdentifier]
						   value:[NSNumber numberWithBool:isUseStripe]];
	if([self isThreadsListColorDefault]) {
		subKey = [[[BSCSBoolUserDefault alloc] initWithKey:@"ThreadsList Draws BackgroundColor"] autorelease];
		userDefault = [[[BSCSDictUserDefault alloc] initWithKey:@"Preferences - BackgroundColors"
														 subKey:subKey] autorelease];
		[userDefault writeWithDomain:[IconSetComposer bathyScapheIdentifier]
							   value:[NSNumber numberWithBool:NO]];
	}
	
	[[IconSetComposer sharedInstance] launchBS];
	while(![[IconSetComposer sharedInstance] isRunningBS])
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	if(!isUseStripe) {
		[self sendingSetColor:kTypeThreadsListColor];
	}
}
- (IBAction)applyOnlyColors:(id)sender
{
	[self applyColors:sender];
}

- (IBAction)changeColor:(id)sender
{
	if( ![sender respondsToSelector:@selector(tag)]
		&& ![sender respondsToSelector:@selector(color)] ) {
		return;
	}
	
	switch([sender tag]) {
		case ThreadsListColorTag:
			[self setThreadsListColor:[sender color]];
			break;
		default:
			return;
	}
}

- (IBAction)revertColor:(id)sender
{
	if( ![sender respondsToSelector:@selector(tag)] ) {
		return;
	}
	
	switch([sender tag]) {
		case ThreadsListColorTag:
			[self setThreadsListColor:nil];
			break;
		default:
			return;
	}
}

- (IBAction)toggleIncludeColorSet:(id)sender
{
	[self setIncludeColors:([sender state] == NSOnState)];
}
- (IBAction)toggleUseStripe:(id)sender
{
	[self setUseStripe:([sender state] == NSOnState)];
}
-(BOOL)setPlistPath:(NSString *)path
{
	return [self setPlistURL:[NSURL fileURLWithPath:path]];
}
- (BOOL)setPlistURL:(NSURL *)url
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:url];
	if( !dict ) {
		return NO;
	}
	
	NSColor *color = [NSColor colorWithPlist:[dict objectForKey:ThreadsListColorKey]];
	[self setThreadsListColor:color];
	
	[self setIncludeColors:[[dict objectForKey:IncludeColorsKey] boolValue]];
	[self setUseStripe:[[dict objectForKey:UseStripeKey] boolValue]];
	
	return YES;
}
- (NSString *)identifier
{
	return ColorSetIdentifier;
}

- (NSView *)view
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
	
	CGFloat red, green, blue, alpha;
	
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
