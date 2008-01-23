/* ColorSet */

#import <Cocoa/Cocoa.h>

typedef enum {
	kTypeBoardListColor,
	kTypeThreadsListColor,
	kTypeBoardListInactiveColor,
} ColorType;

@interface ColorSet : NSObject
{
	NSColor *boardListColor;
	NSColor *boardListInactiveColor;
	NSColor *threadsListColor;
	BOOL isIncludeColors;
	BOOL isUseStripe;
	BOOL isContentHeaderTextColorBlack;
	
	id delegate;
		
	IBOutlet id includeSetCheck;
	IBOutlet id useStripeCheck;
    IBOutlet id boardListColorWell;
    IBOutlet id boardListColorText;
	IBOutlet id boardListInactiveColorWell;
	IBOutlet id boardListInactiveColorText;
    IBOutlet id threadsListColorWell;
	IBOutlet id threadListColorText;
	
	IBOutlet id contentHeaderColorButtons;
//	IBOutlet id contentHeaderSample1;
//	IBOutlet id contentHeaderSample2;
//	IBOutlet id contentHeaderSample3;
	
    IBOutlet id view;
}
- (IBAction)applyColors:(id)sender;
- (IBAction)applyOnlyColors:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)revertColor:(id)sender;
- (IBAction)toggleIncludeColorSet:(id)sender;
- (IBAction)toggleUseStripe:(id)sender;
- (IBAction)toggleHeaderColor:(id)sender;

- (IBAction)toggleHeaderColor:(id)sender;

+(NSColor *)defaultBoardListColor;
+(NSColor *)defaultBoardListInactiveColor;
+(NSColor *)defaultThreadsListColor;

+ (NSColor *)getBathyScapheColor:(ColorType)colorType;

- (BOOL)isBoardListColorDefault;
- (BOOL)isBoardListInactiveColorDefault;
- (BOOL)isThreadsListColorDefault;

-(BOOL)setPlistPath:(NSString *)path;
- (id)plist;
- (NSString *)identifier;

-(NSView *)view;
@end

@interface NSObject (ColorSetDelegate)

-(void)didChangeColorSet:(ColorSet *)set;

@end
