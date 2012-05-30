/* ColorSet */

#import <Cocoa/Cocoa.h>

typedef enum {
	kTypeThreadsListColor,
} ColorType;

@interface ColorSet : NSObject
{
	NSColor *threadsListColor;
	BOOL isIncludeColors;
	BOOL isUseStripe;
	
	id delegate;
		
	IBOutlet id includeSetCheck;
	IBOutlet id useStripeCheck;
    IBOutlet id threadsListColorWell;
	IBOutlet id threadListColorText;
	
    IBOutlet id view;
}

@property (retain, nonatomic) NSColor *threadsListColor;
@property (nonatomic, getter = isIncludeColors) BOOL includeColors;
@property (nonatomic, getter = isUseStripe) BOOL useStripe;

- (IBAction)applyColors:(id)sender;
- (IBAction)applyOnlyColors:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)revertColor:(id)sender;
- (IBAction)toggleIncludeColorSet:(id)sender;
- (IBAction)toggleUseStripe:(id)sender;

+ (NSColor *)defaultThreadsListColor;

+ (NSColor *)getBathyScapheColor:(ColorType)colorType;

- (BOOL)isThreadsListColorDefault;

- (BOOL)setPlistPath:(NSString *)path DEPRECATED_IN_MAC_OS_X_VERSION_10_4_AND_LATER;
- (BOOL)setPlistURL:(NSURL *)url;
- (id)plist;
- (NSString *)identifier;

- (NSView *)view;
@end

@interface NSObject (ColorSetDelegate)

- (void)willChangeColorSet:(ColorSet *)set;
- (void)didChangeColorSet:(ColorSet *)set;

@end
