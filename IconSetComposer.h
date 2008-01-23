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
+(NSString *)bathyScapheResourceFolder;
+(NSString *)bathyScapheIdentifier;

+(NSImage *)defaultImageForIdentifier:(NSString *)identifier;
+(void)deleteImageFilesFromBSAppSptResFolder;

+(BOOL)isAcceptImageExtension:(NSString *)ext;
+(NSArray *)acceptImageExtensions;

-(BOOL)launchBS;
-(long)quitBS;
-(BOOL)isRunningBS;

-(IBAction)quitBathyScaphe:(id)sender;
-(IBAction)launchBathyScaphe:(id)sender;
-(IBAction)restartBathyScaphe:(id)sender;

-(IBAction)createDocumentFromCurrentSetting:(id)sender;

@end
