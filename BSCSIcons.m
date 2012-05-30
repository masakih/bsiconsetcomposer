//
//  BSCSIcons.m
//  IconSetComposer
//
//  Created by Hori,Masaki on 07/03/11.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BSCSIcons.h"

#import "IconSetComposer.h"


@implementation BSCSIcons
@synthesize image, imageFileWrapper, placeholder;
@synthesize title, identifier;

- (id)copyWithZone:(NSZone *)zone
{
	BSCSIcons *result = [[[self class] allocWithZone:zone] init];
	result.image = self.image;
	result.imageFileWrapper = self.imageFileWrapper;
	result.placeholder = self.placeholder;
	result.title = self.title;
	result.identifier = self.identifier;
	
	return result;
}

- (NSImage *)defaultImage
{
	return self.placeholder;
}
- (void)setDefaultImage:(NSImage *)anImage
{
	self.placeholder = anImage;
}

//- (BOOL)validateValue:(id *)ioValue forKey:(NSString *)inKey error:(NSError **)outError
//{
//	NSLog(@"Enterd########");
//	return YES;
//}

-(BOOL)validateImageFileWrapper:(id *)ioValue error:(NSError **)error
{
	if(*ioValue == nil) {
		return YES;
	}
	
	NSString *ext = [[*ioValue preferredFilename] pathExtension];
	if([IconSetComposer isAcceptImageExtension:ext]) {
		return YES;
	}
	
	if(![*ioValue isRegularFile]) {
		return NO;
	}
	
	NSData *data = [*ioValue regularFileContents];
	NSImage *aImage = [[[NSImage alloc] initWithData:data] autorelease];
	if(!aImage) {
		return NO;
	}
	
	NSData *tiffData = [aImage TIFFRepresentation];
	if(!tiffData) {
		return NO;
	}
	NSString *tiffImageName = [[*ioValue preferredFilename] lastPathComponent];
	tiffImageName = [tiffImageName stringByDeletingPathExtension];
	tiffImageName = [tiffImageName stringByAppendingPathExtension:@"tiff"];	
	
	*ioValue = [[NSFileWrapper alloc] initRegularFileWithContents:tiffData];
	[*ioValue setPreferredFilename:tiffImageName];
	
	return YES;
}
@end
