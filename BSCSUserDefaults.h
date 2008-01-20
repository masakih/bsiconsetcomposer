//
//  BSCSUserDefaults.h
//  IconSetComposer
//
//  Created by Hori,Masaki on 07/03/12.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BSCSUserDefaults : NSObject
{
	id key;
}

- (id)initWithKey:(NSString *)key;

// do not over write thease method.
- (BOOL)writeWithDomain:(NSString *)domain value:(id)value;
- (BOOL)writeWithValue:(id)value;


- (id)currentValue;

// returns, for example, array with elements @"key", @"-type", @"value".
- (NSArray *)writeArgumentWithValue:(id)value;

@end

@interface BSCSStringUserDefault : BSCSUserDefaults
@end
//@interface BSCSArrayUserDefault : BSCSUserDefaults
//@end
@interface BSCSBoolUserDefault : BSCSUserDefaults
@end
@interface BSCSDateUserDefault : BSCSUserDefaults
@end
//@interface BSCSDataUserDefault : BSCSUserDefaults
//@end

@interface BSCSDictUserDefault : BSCSUserDefaults
{
	BSCSUserDefaults *subKey;
}
- (id)initWithKey:(NSString *)key subKey:(BSCSUserDefaults *)subkey;
@end

