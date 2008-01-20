/* ColorSet */

#import <Cocoa/Cocoa.h>

@interface ColorSet : NSObject
{
	NSColor *boardListColor;
	NSColor *threadsListColor;
	BOOL isIncludeColors;
	BOOL isUseStripe;
	BOOL isContentHeaderTextColorBlack;
	
	id delegate;
		
	IBOutlet id includeSetCheck;
	IBOutlet id useStripeCheck;
    IBOutlet id boardListColorWell;
    IBOutlet id boardListColorText;
    IBOutlet id threadListColorText;
    IBOutlet id threadsListColorWell;
	
	IBOutlet id contentHeaderColorButtons;
	IBOutlet id contentHeaderSample1;
	IBOutlet id contentHeaderSample2;
	IBOutlet id contentHeaderSample3;
	
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
+(NSColor *)defaultThreadsListColor;

- (BOOL)isBoardListColorDefault;
- (BOOL)isThreadsListColorDefault;

-(BOOL)setPlistPath:(NSString *)path;
- (id)plist;
- (NSString *)identifier;

-(NSView *)view;
@end

@interface NSObject (ColorSetDelegate)

-(void)didChangeColorSet:(ColorSet *)set;

@end
