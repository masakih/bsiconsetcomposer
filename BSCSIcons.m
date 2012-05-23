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

- (void)setImage:(NSImage *)new
{
	if(image == new) return;
	
	id temp = image;
	image = [new retain];
	[temp release];
}
- (NSImage *)image
{
	return image;
}
- (void)setImageFileWrapper:(NSFileWrapper *)new
{
	if(imageFileWrapper == new) return;
	
	id temp = imageFileWrapper;
	imageFileWrapper = [new retain];
	[temp release];
}
- (NSFileWrapper *)imageFileWrapper
{
	return imageFileWrapper;
}
- (void)setPlaceholder:(NSImage *)new
{
	if(placeholder == new) return;
	
	id temp = placeholder;
	placeholder = [new retain];
	[temp release];
}
- (NSImage *)placeholder
{
	return placeholder;
}
- (void)setDefaultImage:(NSImage *)new
{
	if(placeholder == new) return;
	
	id temp = placeholder;
	placeholder = [new retain];
	[temp release];
}
- (NSImage *)defaultImage
{
	return placeholder;
}
- (void)setTitle:(NSString *)new
{
	if(title == new) return;
	
	id temp = title;
	title = [new copy];
	[temp release];
}
- (NSString *)title
{
	return title;
}
- (void)setIdentifier:(NSString *)new
{
	if(identifier == new) return;
	
	id temp = identifier;
	identifier = [new copy];
	[temp release];
}
- (NSString *)identifier
{
	return identifier;
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
