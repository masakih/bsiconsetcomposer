#import "ColorSet.h"

#import "IconSetComposer.h"

#import "BSCSUserDefaults.h"
#import "NSAppleEventDescriptor-Extensions.h"

static NSString *ColorSetIdentifier = @"ColorSet";
static NSString *BoardListColorKey = @"BoardListColor";
static NSString *ThreadsListColorKey = @"ThreadsListColor";
static NSString *IncludeColorsKey = @"IncludeColors";
static NSString *UseStripeKey = @"UseStripe";
static NSString *ContentHeaderTextColorIsBlackKey = @"ContentHeaderTextColorIsBlackKey";

static int BoardListColorTag = 1;
static int ThreadsListColorTag = 2;

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
	
	[super dealloc];
}

- (void)syncContentHeaderTextColor
{
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
}

-(void)updateUI
{
	NSColor *textColor;
	
	if( isIncludeColors ) {
		textColor = [NSColor controlTextColor];
	} else {
		textColor = [NSColor disabledControlTextColor];
	}
	[boardListColorText setTextColor:textColor];
	[threadListColorText setTextColor:textColor];
	
	[self syncContentHeaderTextColor];
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
- (BOOL)isThreadsListColorDefault
{
	if(![self threadsListColor]) return YES;
	return [[self threadsListColor] isEqual:[[self class] defaultThreadsListColor]];
}

typedef enum {
	kTypeBoardListColor,
	kTypeThreadsListColor,
} ColorType;
-(void)sendingSetColor:(ColorType)colorType
{
	NSString *bsBundleID;
	OSType type;
	id targetColor;
	id tempColor;
	float red, green, blue, alpha;
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
	
	[self sendingSetColor:kTypeBoardListColor];
	[self sendingSetColor:kTypeThreadsListColor];
}
- (IBAction)applyOnlyColors:(id)sender
{
	
	[self sendingSetColor:kTypeBoardListColor];
	[self sendingSetColor:kTypeThreadsListColor];
	
	[[IconSetComposer sharedInstance] quitBathyScaphe:self];
	
	[self applyColors:sender];
	
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	
	[[IconSetComposer sharedInstance] launchBathyScaphe:self];
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
	
	[delegate didChangeColorSet:self];
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
