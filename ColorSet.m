#import "ColorSet.h"

#import "IconSetComposer.h"

#import "BSCSUserDefaults.h"
#import "NSAppleEventDescriptor-Extensions.h"

static NSString *ColorSetIdentifier = @"ColorSet";
static NSString *BoardListColorKey = @"BoardListColor";
static NSString *BoardListInactiveColorKey = @"BoardListInactiveColor";
static NSString *ThreadsListColorKey = @"ThreadsListColor";
static NSString *IncludeColorsKey = @"IncludeColors";
static NSString *UseStripeKey = @"UseStripe";
static NSString *ContentHeaderTextColorIsBlackKey = @"ContentHeaderTextColorIsBlackKey";

enum {
	BoardListColorTag = 1,
	ThreadsListColorTag = 2,
	BoardListInactiveColorTag = 3,
};

@interface NSColor(ColorSetSupport)
-(id)plist;
+(NSColor *)colorWithPlist:(id)plist;
@end

@implementation ColorSet

+(NSColor *)defaultBoardListColor
{
	return [NSColor colorWithCalibratedRed:0.898
									 green:0.9294
									  blue:0.9686
									 alpha:1];
}
+(NSColor *)defaultBoardListInactiveColor
{
	return [NSColor colorWithCalibratedRed:0.90625
									 green:0.90625
									  blue:0.90625
									 alpha:1];
}
+(NSColor *)defaultThreadsListColor
{
	return [NSColor colorWithCalibratedRed:1
									 green:1
									  blue:1
									 alpha:1];
}

-(void)dealloc
{
	[boardListColor release];
	[threadsListColor release];
	[boardListInactiveColor release];
	
	[super dealloc];
}

//- (void)syncContentHeaderTextColor
//{
//	NSColor *currentColor = nil;
//	NSShadow *shadow_;
//	NSString *te = [contentHeaderSample1 stringValue];
//	id dict;
//	
//	if(isContentHeaderTextColorBlack) {
//		currentColor = [[NSColor blackColor] retain];
//	} else {
//		currentColor = [[NSColor whiteColor] retain];
//	}
//	
//	shadow_ = [[NSShadow alloc] init];
//	[shadow_ setShadowOffset     : NSMakeSize(1.5, -1.5)];
//	[shadow_ setShadowBlurRadius : 0.3];
//	
//	dict = [NSDictionary dictionaryWithObjectsAndKeys :
//		[NSFont boldSystemFontOfSize : 12.0], NSFontAttributeName,
//		currentColor, NSForegroundColorAttributeName,
//		shadow_, NSShadowAttributeName,
//		nil];
//	
//	id m = [[[NSAttributedString alloc] initWithString:te
//											attributes:dict] autorelease];
//	
//	[contentHeaderSample1 setAttributedStringValue:m];
//	[contentHeaderSample2 setAttributedStringValue:m];
//	[contentHeaderSample3 setAttributedStringValue:m];
//}

-(void)updateUI
{
	NSColor *textColor;
	
	if( isIncludeColors ) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	[boardListColorText setTextColor:textColor];
	[boardListInactiveColorText setTextColor:textColor];
	
	if( isIncludeColors && !isUseStripe) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	[threadListColorText setTextColor:textColor];
	
//	[self syncContentHeaderTextColor];
}

-(id)plist
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if( boardListColor ) {
		[dict setObject:[boardListColor plist] forKey:BoardListColorKey];
	}
	if( boardListInactiveColor ) {
		[dict setObject:[boardListInactiveColor plist] forKey:BoardListInactiveColorKey];
	}
	if( threadsListColor ) {
		[dict setObject:[threadsListColor plist] forKey:ThreadsListColorKey];
	}
	[dict setObject:[NSNumber numberWithBool:isIncludeColors] forKey:IncludeColorsKey];
	[dict setObject:[NSNumber numberWithBool:isUseStripe] forKey:UseStripeKey];
	
	if(isContentHeaderTextColorBlack) {
		[dict setObject:[NSNumber numberWithBool:isContentHeaderTextColorBlack]
				 forKey:ContentHeaderTextColorIsBlackKey];
	}
	
	return dict;
}

- (NSColor *)boardListColor
{
	return boardListColor;
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
- (NSColor *)boardListInactiveColor
{
	return boardListInactiveColor;
}
-(void)setBoardListInactiveColor:(NSColor *)color
{
	id temp = boardListInactiveColor;
	boardListInactiveColor = [color retain];
	[temp release];
	
	if( !color ) {
		color = [[self class] defaultBoardListInactiveColor];
	}
	[boardListInactiveColorWell setColor:color];
}
- (NSColor *)threadsListColor
{
	return threadsListColor;
}
-(void)setThreadsListColor:(NSColor *)color
{
	id temp = threadsListColor;
	threadsListColor = [color retain];
	[temp release];
	
	if( !color ) {
		color = [[self class] defaultThreadsListColor];
	}
	[threadsListColorWell setColor:color];
}
-(void)setIncludeColors:(BOOL)flag
{
	isIncludeColors = flag;
	[includeSetCheck setState: flag ? NSOnState : NSOffState];
	[self updateUI];
	
	[delegate didChangeColorSet:self];
}
-(void)setUseStripe:(BOOL)flag
{
	isUseStripe = flag;
	[useStripeCheck setState: flag ? NSOnState : NSOffState];
	[self updateUI];
	
	[delegate didChangeColorSet:self];
}
- (void)setContentHeaderTextColorBlack:(BOOL)flag
{
	isContentHeaderTextColorBlack = flag;
	int newSelectedTag = isContentHeaderTextColorBlack ? 1 : 0;
	[contentHeaderColorButtons selectCellWithTag:newSelectedTag];
	[self updateUI];
	
	[delegate didChangeColorSet:self];
}

- (BOOL)isBoardListColorDefault
{
	if(![self boardListColor]) return YES;
	
	return [[self boardListColor] isEqual:[[self class] defaultBoardListColor]];
}
- (BOOL)isBoardListInactiveColorDefault
{
	if(![self boardListInactiveColor]) return YES;
	
	return [[self boardListInactiveColor] isEqual:[[self class] defaultBoardListInactiveColor]];
}
- (BOOL)isThreadsListColorDefault
{
	if(![self threadsListColor]) return YES;
	return [[self threadsListColor] isEqual:[[self class] defaultThreadsListColor]];
}

-(void)sendingSetColor:(ColorType)colorType
{
	NSString *bsBundleID;
	OSType type;
	id targetColor;
	id tempColor;
	CGFloat red, green, blue, alpha;
	OSStatus err;
	
	NSAppleEventDescriptor *ae;
	
	NSAppleEventDescriptor *bsDesc;
	
	NSAppleEventDescriptor *propDesc;
	
	NSAppleEventDescriptor *keyDataDesc;
	
	NSAppleEventDescriptor *colorDesc;
	NSAppleEventDescriptor *redDesc;
	NSAppleEventDescriptor *greenDesc;
	NSAppleEventDescriptor *blueDesc;
	
	switch(colorType) {
		case kTypeBoardListColor:
			type = 'bdCo';
			targetColor = boardListColor;
			if([self isBoardListColorDefault]) {
				targetColor = nil;
			}
			break;
		case kTypeThreadsListColor:
			type = 'brCo';
			targetColor = threadsListColor;
			if([self isThreadsListColorDefault]) {
				targetColor = nil;
			}
			break;
		case kTypeBoardListInactiveColor:
			type = 'bnCo';
			targetColor = boardListInactiveColor;
			if([self isBoardListInactiveColorDefault]) {
				targetColor = nil;
			}
			break;
		default:
			return;
	}
	
	/* set up BathyScaphe addr */
	bsBundleID = [[IconSetComposer bathyScapheBundle] bundleIdentifier];
	bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:bsBundleID];
	
	/* Setting color */
	if( targetColor ) {
		tempColor = [targetColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[tempColor getRed:&red green:&green blue:&blue alpha:&alpha];
		
		redDesc = [NSAppleEventDescriptor descriptorWithFloat:red];
		greenDesc = [NSAppleEventDescriptor descriptorWithFloat:green];
		blueDesc = [NSAppleEventDescriptor descriptorWithFloat:blue];
		
		colorDesc = [NSAppleEventDescriptor listDescriptor];
		[colorDesc insertDescriptor:redDesc atIndex:1];
		[colorDesc insertDescriptor:greenDesc atIndex:2];
		[colorDesc insertDescriptor:blueDesc atIndex:3];
	} else {
		// 
		colorDesc = [NSAppleEventDescriptor listDescriptor];
	}
	
	/* create typeObjectSpecifier Descriptor */
	keyDataDesc = [NSAppleEventDescriptor descriptorWithTypeCode:type];	
	propDesc = [NSAppleEventDescriptor objectSpecifierWithDesiredClass:cProperty
															 container:nil
															   keyForm:formPropertyID
															   keyData:keyDataDesc];
	
	/* create AppleEvent */
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kAECoreSuite
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
		NSLog(@"AESendMessage Error. ErrorID ---> %d", err );
	}
}
+ (NSColor *)getBathyScapheColor:(ColorType)colorType
{
	NSString *bsBundleID;
	OSType type;
	id result = nil;
	float red, green, blue;
	OSStatus err;
	
	[[IconSetComposer sharedInstance] launchBS];
	
	NSAppleEventDescriptor *replyDesc;
	NSAppleEventDescriptor *colorComponentsDesc;
	NSAppleEventDescriptor *colorComponentDesc;
	
	NSAppleEventDescriptor *ae;
	NSAppleEventDescriptor *bsDesc;
	NSAppleEventDescriptor *propDesc;
	NSAppleEventDescriptor *keyDataDesc;
	
	switch(colorType) {
		case kTypeBoardListColor:
			type = 'bdCo';
			break;
		case kTypeThreadsListColor:
			type = 'brCo';
			break;
		case kTypeBoardListInactiveColor:
			type = 'bnCo';
			break;
		default:
			return nil;
	}
	
	/* set up BathyScaphe addr */
	bsBundleID = [[IconSetComposer bathyScapheBundle] bundleIdentifier];
	bsDesc = [NSAppleEventDescriptor targetDescriptorWithApplicationIdentifier:bsBundleID];
	
	
	/* create typeObjectSpecifier Descriptor */
	keyDataDesc = [NSAppleEventDescriptor descriptorWithTypeCode:type];	
	propDesc = [NSAppleEventDescriptor objectSpecifierWithDesiredClass:cProperty
															 container:nil
															   keyForm:formPropertyID
															   keyData:keyDataDesc];
	
	/* create AppleEvent */
	ae = [NSAppleEventDescriptor appleEventWithEventClass:kAECoreSuite
												  eventID:kAEGetData
										 targetDescriptor:bsDesc
												 returnID:kAutoGenerateReturnID
											transactionID:kAnyTransactionID];
	
	[ae setParamDescriptor:propDesc forKeyword:keyDirectObject];
	
#ifdef DEBUG
	NSLog(@"%@", ae);
#endif
	
	//	err = AESendMessage( [ae aeDesc], &reply, kAECanInteract + kAEWaitReply, kAEDefaultTimeout );
	err = [ae sendAppleEventWithMode:kAECanInteract + kAEWaitReply
					  timeOutInTicks:kAEDefaultTimeout
							   reply:&replyDesc];
	
	if( err != noErr ) {
		NSLog(@"AESendMessage Error. ErrorID ---> %d", err );
		return nil;
	}
	
#ifdef DEBUG
	NSLog(@"%@", replyDesc);
#endif
	
	colorComponentsDesc = [replyDesc paramDescriptorForKeyword:keyDirectObject];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:1];
	red = [[colorComponentDesc stringValue] floatValue];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:2];
	green = [[colorComponentDesc stringValue] floatValue];
	colorComponentDesc = [colorComponentsDesc descriptorAtIndex:3];
	blue = [[colorComponentDesc stringValue] floatValue];
	
	result = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1];
	
	return result;
}

-(void)awakeFromNib
{
//	[includeSetCheck setState:NSOffState];
	
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
	
	userDefault = [[[BSCSBoolUserDefault alloc] initWithKey:@"ThreadTitleBarTextUsesBlackColor"] autorelease];
	[userDefault writeWithDomain:[IconSetComposer bathyScapheIdentifier]
						   value:[NSNumber numberWithBool:isContentHeaderTextColorBlack]];
	
	
	[[IconSetComposer sharedInstance] launchBS];
	while(![[IconSetComposer sharedInstance] isRunningBS])
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	[self sendingSetColor:kTypeBoardListColor];
	[self sendingSetColor:kTypeBoardListInactiveColor];
	if(!isUseStripe) {
		[self sendingSetColor:kTypeThreadsListColor];
	}
}
- (IBAction)applyOnlyColors:(id)sender
{
	
//	[self sendingSetColor:kTypeBoardListColor];
//	[self sendingSetColor:kTypeThreadsListColor];
	
//	[[IconSetComposer sharedInstance] quitBathyScaphe:self];
	
	[self applyColors:sender];
	
//	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
//	[[IconSetComposer sharedInstance] launchBathyScaphe:self];
}

- (IBAction)changeColor:(id)sender
{
	int tag;
	
	if( ![sender respondsToSelector:@selector(tag)]
		&& ![sender respondsToSelector:@selector(color)] ) {
		return;
	}
	
	tag = [sender tag];
	switch(tag) {
		case BoardListColorTag:
			[self setBoardListColor:[sender color]];
			break;
		case ThreadsListColorTag:
			[self setThreadsListColor:[sender color]];
			break;
		case BoardListInactiveColorTag:
			[self setBoardListInactiveColor:[sender color]];
			break;
		default:
			return;
	}
	
	[delegate didChangeColorSet:self];
}

- (IBAction)revertColor:(id)sender
{
	int tag;
	
	if( ![sender respondsToSelector:@selector(tag)] ) {
		return;
	}
	
	tag = [sender tag];
	switch(tag) {
		case BoardListColorTag:
			[self setBoardListColor:nil];
			break;
		case ThreadsListColorTag:
			[self setThreadsListColor:nil];
			break;
		case BoardListInactiveColorTag:
			[self setBoardListInactiveColor:nil];
			break;
		default:
			return;
	}
	
	[delegate didChangeColorSet:self];
}

- (IBAction)toggleIncludeColorSet:(id)sender
{
	[self setIncludeColors:([sender state] == NSOnState)];
}
- (IBAction)toggleUseStripe:(id)sender
{
	[self setUseStripe:([sender state] == NSOnState)];
}

- (IBAction)toggleHeaderColor:(id)sender
{	
	if(![sender respondsToSelector:@selector(selectedCell)]) {
		return;
	}
	
	BOOL isBlack = (BOOL)[[sender selectedCell] tag];
	
	[self setContentHeaderTextColorBlack:isBlack];
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
	
	color = [NSColor colorWithPlist:[dict objectForKey:BoardListInactiveColorKey]];
	[self setBoardListInactiveColor:color];
	
	color = [NSColor colorWithPlist:[dict objectForKey:ThreadsListColorKey]];
	[self setThreadsListColor:color];
	
	[self setIncludeColors:[[dict objectForKey:IncludeColorsKey] boolValue]];
	[self setUseStripe:[[dict objectForKey:UseStripeKey] boolValue]];
	
	if([dict objectForKey:ContentHeaderTextColorIsBlackKey]) {
		[self setContentHeaderTextColorBlack:[[dict objectForKey:ContentHeaderTextColorIsBlackKey] boolValue]];
	}
	
	[delegate didChangeColorSet:self];
	
	return YES;
}

- (NSString *)identifier
{
	return ColorSetIdentifier;
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
