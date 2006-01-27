//
//  NSWorkspace-Extensions.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 06/01/25.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSWorkspace-Extensions.h"

#import "NSAppleEventDescriptor-Extensions.h"

@implementation NSWorkspace(HMCocoaExtention)
-(BOOL)quitApplication:(NSString *)appName
{
    NSAppleEventDescriptor *targetDesc;
    NSAppleEventDescriptor *appleEvent;
	AppleEvent reply;
	NSAppleEventDescriptor *replyDesc;
	NSAppleEventDescriptor *anser;
    OSStatus err;
	
    targetDesc = [NSAppleEventDescriptor targetDescriptorWithAppName:appName];
    if(!targetDesc) return NO;
	
    appleEvent = [NSAppleEventDescriptor appleEventWithEventClass:kCoreEventClass
                                                          eventID:kAEQuitApplication
                                                 targetDescriptor:targetDesc
                                                         returnID:kAutoGenerateReturnID
                                                    transactionID:kAnyTransactionID];
    if(!appleEvent) return NO;
	
    err = AESendMessage( [appleEvent aeDesc], &reply, kAECanInteract + kAEWaitReply , kAEDefaultTimeout );
	if( err == procNotFound) {
		AEDisposeDesc(&reply);
		return YES;
	}
	if(err != noErr) return err;
	
	replyDesc = [[[NSAppleEventDescriptor allocWithZone:[self zone]] initWithAEDescNoCopy:&reply] autorelease];
	anser = [replyDesc paramDescriptorForKeyword:keyErrorNumber];
	err = (OSStatus)[[anser stringValue] floatValue];
	if(err != noErr) {
		anser = [replyDesc paramDescriptorForKeyword:keyErrorString];
		if(anser) NSLog(@"Target returned error. (%@)",[anser stringValue]);
	}
    return err == noErr;
}
@end
