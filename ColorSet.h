/* ColorSet */

#import <Cocoa/Cocoa.h>

@interface ColorSet : NSObject
{
	NSColor *boardListColor;
	NSColor *threadsListColor;
	BOOL isIncludeColors;
	
	id delegate;
	
	IBOutlet id includeSetCheck;
    IBOutlet id applyButton;
    IBOutlet id boardListColorWell;
    IBOutlet id boardListColorText;
    IBOutlet id revertBoardListButton;
    IBOutlet id revertThreadsListButton;
    IBOutlet id threadListColorText;
    IBOutlet id threadsListColorWell;
    IBOutlet id view;
}
- (IBAction)applyColors:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)revertColor:(id)sender;
- (IBAction)toggleIncludeColorSet:(id)sender;

+(NSColor *)defaultBoardListColor;
+(NSColor *)defaultThreadListColor;

-(BOOL)setPlistPath:(NSString *)path;

-(NSView *)view;
@end

@interface NSObject (ColorSetDelegate)

-(void)setPlist:(id)plist forIdentifier:(NSString *)key;

@end
