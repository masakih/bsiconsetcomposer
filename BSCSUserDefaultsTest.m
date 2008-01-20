//
//  BSCSUserDefaultsTest.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 07/03/13.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BSCSUserDefaultsTest.h"

@implementation BSCSUserDefaultsTest

- (void)testBoolUserDefault
{
	NSString *aKey = @"aKey";
	NSString *aValue = @"theValue";
	BOOL theValue = YES;
	NSString *theValueString = @"YES";
	
	NSArray *arguments;
	
	userDefault = [[[BSCSBoolUserDefault alloc] initWithKey:aKey] autorelease];
	STAssertNotNil(userDefault, @"BSCSBoolUserDefault can NOT cretate.");
	
	arguments = [userDefault writeArgumentWithValue:aValue];
	STAssertTrue(arguments == nil, @"BSCSBoolUserDefault accept not BOOL value");
	
	arguments = [userDefault writeArgumentWithValue:nil];
	STAssertTrue(arguments == nil, @"BSCSBoolUserDefault accept nil value");
	
	arguments = [userDefault writeArgumentWithValue:[NSNumber numberWithBool:theValue]];
	STAssertNotNil(arguments, @"BSCSBoolUserDefault NOT accept BOOL value");
	
	STAssertEquals([arguments count], 3u, @"Missmutch argument number.");
	
	STAssertTrue([[arguments objectAtIndex:0] isEqualTo:aKey], @"Missmutch 1st argument.");
	STAssertTrue([[arguments objectAtIndex:1] isEqualTo:@"-bool"], @"Missmutch 2nd argument.");
	STAssertTrue([[arguments objectAtIndex:2] isEqualTo:theValueString], @"Missmutch 3rd argument.");
}

- (void)testDictUserDefault
{
	NSString *aKey = @"Preferences - BackgroundColors";
	NSString *subKey = @"ThreadsList Draws Striped";
	NSString *aValue = @"theValue";
	BOOL theValue = NO;
	NSString *theValueString = @"NO";
	
	NSArray *arguments;
	
	BSCSBoolUserDefault *sub = [[[BSCSBoolUserDefault alloc] initWithKey:subKey] autorelease];
	STAssertNotNil(sub, @"BSCSBoolUserDefault can NOT cretate.");
		
	userDefault = [[[BSCSDictUserDefault alloc] initWithKey:aKey subKey:sub] autorelease];
	STAssertNotNil(userDefault, @"BSCSDictUserDefault can NOT cretate.");
	
	arguments = [userDefault writeArgumentWithValue:nil];
	STAssertTrue(arguments == nil, @"BSCSBoolUserDefault accept nil value");
	
	arguments = [userDefault writeArgumentWithValue:aValue];
	STAssertTrue(arguments == nil, @"BSCSBoolUserDefault accept not BOOL value");
	
	arguments = [userDefault writeArgumentWithValue:[NSNumber numberWithBool:theValue]];
	STAssertNotNil(arguments, @"BSCSBoolUserDefault NOT accept BOOL value");
	
	STAssertEquals([arguments count], 5u, @"Missmutch argument number.");
	
	STAssertTrue([[arguments objectAtIndex:0] isEqualTo:aKey], @"Missmutch 1st argument.");
	STAssertTrue([[arguments objectAtIndex:1] isEqualTo:@"-dict-add"], @"Missmutch 2nd argument.");
	STAssertTrue([[arguments objectAtIndex:2] isEqualTo:subKey], @"Missmutch 3rd argument.");
	STAssertTrue([[arguments objectAtIndex:3] isEqualTo:@"-bool"], @"Missmutch 4th argument.");
	STAssertTrue([[arguments objectAtIndex:4] isEqualTo:theValueString], @"Missmutch 5th argument.");
	
	[userDefault writeWithDomain:@"jp.tsawada2.BathyScaphe"
						   value:[NSNumber numberWithBool:theValue]];
}

@end
