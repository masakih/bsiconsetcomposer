//
//  IconTrayInspector.h
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>

@interface IconTrayInspector : IBInspector
{
	IBOutlet NSTextField *titleLabel;
	IBOutlet NSTextField *identifierLabel;
	IBOutlet NSTextField *tagLabel;
	
	IBOutlet NSMatrix *textAlignment;
	IBOutlet NSMatrix *imageAlignment;
	IBOutlet NSMatrix *imageScaling;
	IBOutlet NSMatrix *imagePosition;
	
	IBOutlet NSPopUpButton *fontSizeBotton;
	
}

@end
