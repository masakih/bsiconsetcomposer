//
//  NSWorkspace-Extensions.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 06/01/25.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWorkspace(HMCocoaExtention)
-(BOOL)quitApplication:(NSString *)appName;
@end
