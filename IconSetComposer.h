/* IconSetComposer */

#import <Cocoa/Cocoa.h>

enum {
	kBSHaveUnknownImage = 1,
	kIconsHaveIncreased = 1 << 1,
};

@interface IconSetComposer : NSObject
{
}

+(id)sharedInstance;

+(NSBundle *)bathyScapheBundle;
+(NSString *)bathyScapheSupportFolder;

+(NSImage *)defaultImageForIdentifier:(NSString *)identifier;
+(void)deleteImageFilesFromBSAppSptResFolder;

+(BOOL)isAcceptImageExtension:(NSString *)ext;
+(NSArray *)acceptImageExtensions;


-(IBAction)restartBathyScaphe:(id)sender;

@end
