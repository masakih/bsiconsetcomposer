//
//  IconTrayPalette.h
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>
#import "IconTray.h"

@interface IconTrayPalette : IBPalette
{
	IBOutlet IconTray *iconTray;
	IBOutlet NSTextField *editor;
}
@end

@interface IconTray (IconTrayPaletteInspector)
- (NSString *)inspectorClassName;
@end

@interface IconTrayPalette (DraggingDelegate) <IBViewResourceDraggingDelegates>

@end