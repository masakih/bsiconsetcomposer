//
//  BSCSUserDefaults.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 07/03/12.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BSCSUserDefaults.h"

NSString *const DefaultsCmd = @"/usr/bin/defaults";

@implementation BSCSUserDefaults

- (id)initWithKey:(NSString *)inKey
{
	if(self = [super init]) {
		key = [inKey copy];
	}
	
	return self;
}
- (void)dealloc
{
	[key release];
	
	[super dealloc];
}

- (NSString *)selfDomain
{
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *identifier = [bundle bundleIdentifier];
	
	if(!identifier) {
		[NSException raise:@"BSCSNotFoundSelfIdentifierException"
					format:@"Can not find my bundle identifier."];
		
	}
	
	return identifier;
}

	// do not over write thease method.
- (BOOL)writeWithDomain:(NSString *)domain value:(id)value
{
	NSMutableArray *arguments;
	
	if(!domain) {
		domain = [self selfDomain];
	}
	
	NSTask *defaultsTask = [[[NSTask alloc] init] autorelease];
	[defaultsTask setLaunchPath:DefaultsCmd];
	
	arguments = [NSMutableArray arrayWithObjects:@"write", domain, nil];
	[arguments addObjectsFromArray:[self writeArgumentWithValue:value]];
	[defaultsTask setArguments:arguments];
	
	[defaultsTask launch];
	[defaultsTask waitUntilExit];
	
	if([defaultsTask terminationStatus] != 0) {
		return NO;
	}
	
	return YES;
}
- (BOOL)writeWithValue:(id)value;
{
	return [self writeWithDomain:nil value:value];
}

- (id)currentValue
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

	// returns, for example, @"key -type value".
- (NSArray *)writeArgumentWithValue:(id)value
{
	NSLog(@"Should implementation in subclass.");
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

@implementation BSCSBoolUserDefault

- (NSArray *)writeArgumentWithValue:(id)value
{
	NSArray *result;
	NSString *theValue = nil;
		
	if(!value || ![value isKindOfClass:[NSNumber class]]) {
		return nil;
	}
	
	if([value boolValue]) {
		theValue = @"YES";
	} else {
		theValue = @"NO";
	}
	
	result = [NSArray arrayWithObjects:key, @"-bool", theValue, nil];
	
	return result;
}
@end

@implementation BSCSDictUserDefault
- (id)initWithKey:(NSString *)inKey subKey:(BSCSUserDefaults *)inSubkey
{
	if(self = [super initWithKey:inKey]) {
		subKey = [inSubkey retain];
	}
	
	return self;
}
- (void)dealloc
{
	[subKey release];
	
	[super dealloc];
}
- (NSArray *)writeArgumentWithValue:(id)value
{
	NSArray *args;
	NSMutableArray *result;
		
	args = [subKey writeArgumentWithValue:value];
	if(!args) {
		return nil;
	}
		
	result = [NSMutableArray arrayWithObjects:key, @"-dict-add", nil];
	[result addObjectsFromArray:args];
		
	return result;
}
@end
