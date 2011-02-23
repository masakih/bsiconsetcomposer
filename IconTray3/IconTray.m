//
//  IconTray.m
//  IconTray
//
//  Created by Hori,Masaki on 05/10/09.
//  Copyright __MyCompanyName__ 2005 . All rights reserved.
//

#import "IconTray.h"

NSString *IconTrayImageFileDidChangeNotification = @"IconTrayImageFileDidChangeNotification";

@interface IconTray (IconTrayPrivate)
- (NSImageCell *)imageCell;
-(void)registDraggedTypes;
@end

// static NSString *IconTrayImageKey = @"IconTrayImageKey";
static NSString *IconTrayTitleKey = @"IconTrayTitleKey";
static NSString *IconTrayIdentifierKey = @"IconTrayIdentifierKey";
static NSString *IconTrayImagePositionKey =@"IconTrayImagePositionKey";

// static NSString *IconTrayBindKeypaths =@"IconTrayBindKeypaths";
// static NSString *IconTrayBindControllers =@"IconTrayBindControllers";

@implementation IconTray

+(void)initialize
{
	static BOOL isFirst = YES;
	
	if( isFirst ) {
		isFirst = NO;
		[self exposeBinding:@"image"];
		[self exposeBinding:@"imageFileWrapper"];
		[self exposeBinding:@"title"];
		[self exposeBinding:@"identifier"];
		[self exposeBinding:@"placeholderImage"];
	}
}

+ (Class)cellClass
{
	return [NSImageCell class];
}

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if( self ) {
		
//		imageCell = [[NSImageCell alloc] initImageCell:nil];
		titleCell = [[NSTextFieldCell alloc] initTextCell:@""];
		identifier = [[NSString stringWithString:@""] retain];
		
		bindKeyPathDict = [[NSMutableDictionary dictionaryWithCapacity:6] retain];
		bindControllerDict = [[NSMutableDictionary dictionaryWithCapacity:6] retain];
		
		[self setImageAlignment:NSImageAlignCenter];
		[[self imageCell] setSelectable:YES];
		[self setImagePosition:NSImageAbove];
		[self setAlignment:NSCenterTextAlignment];
		
		if( [self respondsToSelector:@selector(registDraggedTypes)] ) {
			[self registDraggedTypes];
		}
		
		[self bind:@"controlSize"
		  toObject:[self imageCell]
	   withKeyPath:@"controlSize"
		   options:nil];
	}
	
	return self;
}
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	
	if( [decoder allowsKeyedCoding] ) {
		NSImage *i;
		
//		imageCell = [[decoder decodeObjectForKey:IconTrayImageKey] retain];
		titleCell = [[decoder decodeObjectForKey:IconTrayTitleKey] retain];
		identifier = [[decoder decodeObjectForKey:IconTrayIdentifierKey] retain];
		
		bindKeyPathDict = [[NSMutableDictionary dictionaryWithCapacity:6] retain];
		bindControllerDict = [[NSMutableDictionary dictionaryWithCapacity:6] retain];
		
		[self setImagePosition:[decoder decodeIntForKey:IconTrayImagePositionKey]];
		
		// setting other property of image.
		i = [[self imageCell] image];
		[self setImage:i];
	}
	
	if( [self respondsToSelector:@selector(registDraggedTypes)] ) {
		[self registDraggedTypes];
	}
	
	[self bind:@"controlSize"
	  toObject:[self imageCell]
   withKeyPath:@"controlSize"
	   options:nil];
	
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	
	if( [coder allowsKeyedCoding] ) {
		id tmp;
		
		// store other properties.
		tmp = [[[self imageCell] representedObject] retain];
		[[self imageCell] setRepresentedObject:nil];
		
//		[coder encodeObject:imageCell forKey:IconTrayImageKey];
		[coder encodeObject:titleCell forKey:IconTrayTitleKey];
		[coder encodeObject:identifier forKey:IconTrayIdentifierKey];
		[coder encodeInt:imagePosition forKey:IconTrayImagePositionKey];
		
//		[coder encodeObject:bindKeyPathDict forKey:IconTrayBindKeypaths];
//		[coder encodeObject:bindControllerDict forKey:IconTrayBindControllers];
		
		// restore other properties.
		[[self imageCell] setRepresentedObject:[tmp autorelease]];
	}
}

-(void)dealloc
{
	[self unregisterDraggedTypes];
	
//	[imageCell setRepresentedObject:nil];
//	[imageCell release];
	[titleCell setRepresentedObject:nil];
	[titleCell release];
	[identifier release];
	[placeholderImage release];
	
	[bindKeyPathDict release];
	[bindControllerDict release];
	
	[super dealloc];
}

#ifdef DEBUG
-(id)retain
{
	return [super retain];
}
-(oneway void)release
{
	return [super release];
}
#endif

#pragma mark-
#pragma mark## Drawing ##

const float kTopMargin = 0;
const float kBottomMargin = 0;
const float kSideMargin = 0;
const float kSeparateSpace = 4;

-(NSRect)titleRect
{
	NSRect bounds = [self bounds];
	NSRect titleRect = NSZeroRect;
	NSSize titleSize;
	
	titleSize = [titleCell cellSize];
	
	if( ![self isFlipped] ) {
		bounds.size.height -= kTopMargin;
		
		bounds.size.height -= kBottomMargin;
		bounds.origin.y += kBottomMargin;
		
		bounds.size.width -= kSideMargin * 2;
		bounds.origin.x += kSideMargin;
		
		titleRect = bounds;
		titleRect.size.height = titleSize.height;
	}
	
	if( [self imagePosition] == NSImageBelow ) {
		titleRect.origin.y += bounds.size.height - titleRect.size.height;
	}
	
	return titleRect;
}
-(NSRect)imageRect
{
	NSRect bounds = [self bounds];
	NSRect imageRect = NSZeroRect;
	NSSize titleSize;
	
	titleSize = [titleCell cellSize];
	
	if( ![self isFlipped] ) {
		bounds.size.height -= kTopMargin;
		
		bounds.size.height -= kBottomMargin;
		bounds.origin.y += kBottomMargin;
		
		bounds.size.width -= kSideMargin * 2;
		bounds.origin.x += kSideMargin;
		
		imageRect = bounds;
		imageRect.origin.y += titleSize.height + kSeparateSpace;
		imageRect.size.height -= titleSize.height + kSeparateSpace;
	}
	
	if( [self imagePosition] == NSImageBelow ) {
		imageRect.origin.y = bounds.origin.y;
	}
	
	return imageRect;
}

- (void)drawRect:(NSRect)rect
{
	NSRect cellRect;
	
#ifdef DEBUG
	// draw outline.
	{
		NSFrameRect( [self visibleRect] );
	}
#endif
	
//	[super drawRect:rect];
	
	cellRect = [self titleRect];
	[titleCell drawInteriorWithFrame:cellRect inView:self];
	
	cellRect = [self imageRect];
	if( [[self imageCell] isHighlighted] && [[self window] isKeyWindow] ) {
		[NSGraphicsContext saveGraphicsState];
		NSSetFocusRingStyle(NSFocusRingAbove);
		[[NSColor selectedControlColor] set];
		
		[[self imageCell] drawInteriorWithFrame:cellRect inView:self];
		
		[NSGraphicsContext restoreGraphicsState];
	} else {
		[[self imageCell] drawInteriorWithFrame:cellRect inView:self];
	}
	if( [self respondsToSelector:@selector(drawInPalette)] ) {
		[self performSelector:@selector(drawInPalette)];
	}
	
	if( [self isHighlighted] ) {
		[NSGraphicsContext saveGraphicsState];
		
		[[NSColor selectedControlColor] set];
		NSFrameRectWithWidth( [self visibleRect], 2 );
		
		[NSGraphicsContext restoreGraphicsState];
	}
}

const float kFocusRingOffset = -4;
-(void)updateCell:(NSCell *)cell
{
	NSView *superview = [self superview];
	
	if( superview ) {
		NSRect updateRect = NSInsetRect( [self frame], kFocusRingOffset, kFocusRingOffset );
		[superview setNeedsDisplayInRect:updateRect];
	} else {
		[self setNeedsDisplay:YES];
	}
}

#pragma mark-
#pragma mark## Notifiaction ##

-(void)postNotificationWithName:name
{
	NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
	NSDictionary *dict = nil;
	
	if( [IconTrayImageFileDidChangeNotification isEqualTo:name] ) {
		//
	}
	
	[nf postNotificationName:name object:self userInfo:dict];
}

#pragma mark-
#pragma mark## Bindings ##

// - (NSArray *)exposedBindings;
- (Class)valueClassForBinding:(NSString *)binding
{
	if( [binding isEqualTo:@"image"]
		|| [binding isEqualTo:@"placeholderImage"] ) {
		return [NSImage class];
	} else if( [binding isEqualTo:@"title"]
			   || [binding isEqualTo:@"identifier"] ) {
		return [NSString class];
	} else if( [binding isEqualTo:@"imageFileWrapper"] ) {
		return [NSFileWrapper class];
	}
	
	return Nil;
}
- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[bindKeyPathDict setObject:keyPath forKey:binding];
	[bindControllerDict setObject:observable forKey:binding];
	
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}		
- (void)unbind:(NSString *)binding
{
	[bindKeyPathDict removeObjectForKey:binding];
	[bindControllerDict removeObjectForKey:binding];
	
	[super unbind:binding];
}


#pragma mark-
#pragma mark## Accessor ##

-(id)delegate
{
	return delegate;
}
- (NSImageCell *)imageCell
{
	return [self cell];
}
-(void)setDelegate:(id)newDelegate
{
	delegate = newDelegate;
}

-(NSImage *)placeholderImage
{
	return placeholderImage;
}
-(void)setPlaceholderImage:(NSImage *)placeholder
{
	if(placeholderImage == placeholder) return;
	
	id temp = placeholderImage;
	placeholderImage = [placeholder retain];
	[temp release];
	
	if( ![self image] ) {
		[[self imageCell] setImage:placeholderImage];
		[self updateCell:[self imageCell]];
	}
	
	// binding
	id bindKeyPath = [bindKeyPathDict objectForKey:@"placeholderImage"];
	id controller = [bindControllerDict objectForKey:@"placeholderImage"];
	if(bindKeyPath && controller) {
		id value = placeholder;
		NSError *error = nil;
		if(![controller validateValue:&value forKeyPath:bindKeyPath error:&error]) {
			[NSException raise:NSGenericException format:@"KVC validation error"];
		}
		[controller setValue:value forKeyPath:bindKeyPath];
	}
}
-(BOOL)setImageName:(NSString *)newName
{
	if([[[self imageCell] representedObject] preferredFilename] == newName) return YES;
	
	NSFileWrapper *fileWrapper = [[self imageCell] representedObject];
	
	if( !fileWrapper ) return NO;
	
	[fileWrapper setPreferredFilename:newName];
	
	return YES;
}
// primitive method.
-(BOOL)setImage:(NSImage *)inImage fileWrapper:(NSFileWrapper *)wrapper
{
	if([[self imageCell] representedObject] == wrapper
		&& [[[self imageCell] image] isEqual:image]) return YES;
	
	NSImage *aImage = inImage;
	
	if( inImage && ![inImage isKindOfClass:[NSImage class]] ) return NO;
	
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:willChangeFileOfImage:)]
		&& ![delegate iconTray:self willChangeFileOfImage:wrapper] ) {
		return NO;
	}
	
	id temp = image;
	image = [inImage retain];
	[temp release];
	
	if( !inImage && placeholderImage ) {
		aImage = placeholderImage;
		wrapper = nil;
	}
	[[self imageCell] setImage:aImage];
	[[self imageCell] setRepresentedObject:wrapper];
	
	// binding
	id bindKeyPath = [bindKeyPathDict objectForKey:@"image"];
	id controller = [bindControllerDict objectForKey:@"image"];
	if(bindKeyPath && controller) {
		id value = inImage;
		NSError *error = nil;
		if(![controller validateValue:&value forKeyPath:bindKeyPath error:&error]) {
			[NSException raise:NSGenericException format:@"KVC validation error"];
		}
		[controller setValue:value forKeyPath:bindKeyPath];
	}
	
	bindKeyPath = [bindKeyPathDict objectForKey:@"imageFileWrapper"];
	controller = [bindControllerDict objectForKey:@"imageFileWrapper"];
	if(bindKeyPath && controller) {
		id value = wrapper;
		NSError *error = nil;
		if(![controller validateValue:&value forKeyPath:bindKeyPath error:&error]) {
			[NSException raise:NSGenericException format:@"KVC validation error"];
		}
		[controller setValue:value forKeyPath:bindKeyPath];
	}
	
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:didChangeFileOfImage:)] ) {
		
		[delegate iconTray:self didChangeFileOfImage:wrapper];
	}
	[self postNotificationWithName:IconTrayImageFileDidChangeNotification];
	
	[self updateCell:[self imageCell]];
	
	return YES;
}
-(BOOL)setImageFileWrapper:(NSFileWrapper *)imageFileWrapper
{
	NSImage *img;
	
	if([[self imageCell] representedObject] == imageFileWrapper) return YES;
	
	img = [[[NSImage alloc] initWithData:[imageFileWrapper regularFileContents]] autorelease];
	if( !img ) return NO;
	
	return [self setImage:img fileWrapper:imageFileWrapper];
}
-(BOOL)setImageFilePath:(NSString *)imageFilePath
{
	NSFileWrapper *fileWrapper;
	
	fileWrapper = [[[NSFileWrapper alloc] initWithPath:imageFilePath] autorelease];
	
	return [self setImageFileWrapper:fileWrapper];
}
inline BOOL createImageFileWapper( NSImage *inImage, NSString *inImageName, NSFileWrapper **outFileWrapper )
{
	NSData *imageData;
	
	if( !outFileWrapper ) return NO;
	if( !inImage || ![inImage isKindOfClass:[NSImage class]] ) {
		*outFileWrapper = nil;
		return NO;
	}
	if( !inImageName ) {
		*outFileWrapper = nil;
		return NO;
	}
	
	imageData = [inImage TIFFRepresentation];
	
	*outFileWrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:imageData] autorelease];
	if( !*outFileWrapper ) {
		return NO;
	}
	[*outFileWrapper setPreferredFilename:inImageName];
	
	return YES;
}
-(BOOL)setImage:(NSImage *)inImage withName:(NSString *)imageName
{
	NSFileWrapper *fileWrapper;
	
	if( !imageName ) {
		imageName = @"temp.tiff";
	}
	
	if( !createImageFileWapper( inImage, imageName, &fileWrapper ) ) {
		fileWrapper = nil;
	}
	
	return [self setImage:inImage fileWrapper:fileWrapper];
}	
-(BOOL)setImageFromPasteboard:(NSPasteboard *)pasteboard
{
	NSArray *paths = nil;
	NSString *imagePath;
	NSString *imageName = nil;
	NSImage *aImage = nil;
	NSArray *pbTypes;
	
	pbTypes = [pasteboard types];
	
	if( [pbTypes containsObject:NSFilenamesPboardType] ) {
		paths = [pasteboard propertyListForType:NSFilenamesPboardType];
		imagePath = [paths objectAtIndex:0];
		
		return [self setImageFilePath:imagePath];
		
	} else if( [pbTypes containsObject:NSTIFFPboardType] ) {
		NSData *data;		
		
		data = [pasteboard dataForType:NSTIFFPboardType];
		aImage = [[[NSImage alloc] initWithData:data] autorelease];
	} else if( [pbTypes containsObject:NSURLPboardType] ) {
		NSURL *pathURL;
		NSString *lowerExtension;
		NSData *data;
		
		paths = [pasteboard propertyListForType:NSURLPboardType];
		if( ![paths isKindOfClass:[NSArray class]] ) return NO;
		
		pathURL = [NSURL URLWithString:[paths objectAtIndex:0]];
		if( !pathURL ) return NO;
		
		imageName = [[pathURL path] lastPathComponent];
		lowerExtension = [[imageName pathExtension] lowercaseString];
		if( ![[NSImage imageFileTypes] containsObject:lowerExtension] ) return NO;
		
		NSURLRequest *req = [NSURLRequest requestWithURL:pathURL];
		data = [NSURLConnection sendSynchronousRequest:req returningResponse:NULL error:NULL];
//		data = [pathURL resourceDataUsingCache:YES];
		aImage = [[[NSImage alloc] initWithData:data] autorelease];
	}
	
	if( aImage ) {
		return [self setImage:aImage withName:imageName];
	}
	
	return NO;
}

-(NSImage *)displayedImage
{
	NSImage *result = [[self imageCell] image];
	
	if( placeholderImage && [placeholderImage isEqual:result] ) {
		result = nil;
	}
	
	return result;
}
-(NSFileWrapper *)imageFileWrapper
{
	return [[self imageCell] representedObject];
}
-(NSString *)imageName
{
	return [[self imageFileWrapper] preferredFilename];
}
-(NSImage *)image
{
	return image;
}
-(BOOL)setImage:(NSImage *)inImage
{
	if([[self imageCell] image] == inImage) return YES;
	
	return [self setImage:inImage withName:nil];
}

-(NSString *)title
{
	return [titleCell stringValue];
}
-(void)setTitle:(NSString *)inTitle
{
	if( !inTitle || ![inTitle isKindOfClass:[NSString class]] ) return;
	
	if([titleCell stringValue] == inTitle) return;
	
	[titleCell setStringValue:inTitle];
	[self updateCell:titleCell];
	
	// binding
	id bindKeyPath = [bindKeyPathDict objectForKey:@"title"];
	id controller = [bindControllerDict objectForKey:@"title"];
	if(bindKeyPath && controller) {
		[controller setValue:inTitle forKeyPath:bindKeyPath];
	}
}
- (NSFont *)font
{
	return [titleCell font];
}
- (void)setFont:(NSFont *)fontObj
{
	if([titleCell font] == fontObj) return;
	
	[titleCell setFont:fontObj];
	[self updateCell:titleCell];
}
-(NSString *)identifier
{
	return identifier;
}
-(void)setIdentifier:(NSString *)inIdentifier
{
	if(identifier == inIdentifier) return;
	
	id tmp = identifier;
	identifier = [inIdentifier copy];
	[tmp release];
	
	// binding
	id bindKeyPath = [bindKeyPathDict objectForKey:@"identifier"];
	id controller = [bindControllerDict objectForKey:@"identifier"];
	if(bindKeyPath && controller) {
		[controller setValue:inIdentifier forKeyPath:bindKeyPath];
	}
}

-(BOOL)isHighlighted
{
	return isHighlighted;
}
-(void)setHighlighted:(BOOL)flag
{
	if(isHighlighted == flag) return;
	
	isHighlighted = flag;
	[self setNeedsDisplay:YES];
}

- (NSTextAlignment)alignment
{
	return [titleCell alignment];
}
- (void)setAlignment:(NSTextAlignment)mode
{
	if([titleCell alignment] == mode) return;
	
	[titleCell setAlignment:mode];
	[self updateCell:titleCell];
}

- (NSImageAlignment)imageAlignment
{
	return [[self imageCell] imageAlignment];
}
- (void)setImageAlignment:(NSImageAlignment)newAlign
{
	if([[self imageCell] imageAlignment] == newAlign) return;
	
	[[self imageCell] setImageAlignment:newAlign];
	[self updateCell:[self imageCell]];
}
- (NSImageScaling)imageScaling
{
	return [[self imageCell] imageScaling];
}
- (void)setImageScaling:(NSImageScaling)newScaling
{
	if( [[self imageCell] imageScaling] == newScaling) return;
	
	[[self imageCell] setImageScaling:newScaling];
	[self updateCell:[self imageCell]];
}

- (NSCellImagePosition)imagePosition
{
	return imagePosition;
}
- (void)setImagePosition:(NSCellImagePosition)aPosition
{
	if( aPosition != NSImageBelow && aPosition != NSImageAbove ) {
		NSLog(@"%@ support only NSImageBelow or NSImageAbove", NSStringFromClass([self class]));
		if( imagePosition != NSImageBelow && imagePosition != NSImageAbove ) {
			imagePosition = NSImageAbove;
		}
		return;
	}
	
	if(imagePosition == aPosition) return;
	
	imagePosition = aPosition;
	[self updateCell:[self imageCell]];
}
- (void)setControlSize:(NSControlSize)size
{
	NSFont *newFont = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:size]];
	[titleCell setControlSize:size];
	[self setFont:newFont];
	
//	[self updateCell:titleCell];
}
- (NSControlSize)controlSize
{
	return [titleCell controlSize];
}

#pragma mark-
#pragma mark## Event Handling ##
- (void)mouseDown:(NSEvent *)theEvent
{
#ifdef DEBUG
	NSPoint mouse = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if( NSMouseInRect( mouse, [self imageRect], [self isFlipped] ) ) {
		[self setHighlighted:![self isHighlighted]];
		NSLog(@"##############");
	}
	
	NSLog(@"title->%@\nidentifier->%@\nimage->%@\nplaceholder->%@",
		  [self title], [self identifier], [self image], [self placeholderImage]);
#endif
	
	[[self window] makeFirstResponder:self];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)becomeFirstResponder
{
	[[self imageCell] setHighlighted:YES];
	[self updateCell:[self imageCell]];
	return YES;
}
- (BOOL)resignFirstResponder
{
	[[self imageCell] setHighlighted:NO];
	[self updateCell:[self imageCell]];
	return YES;
}

#pragma mark-
#pragma mark## Actions ##
-(IBAction)copy:(id)sender
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSMutableArray *types = [NSMutableArray array];
	
	if( [self image] ) {
		[types addObject:NSTIFFPboardType];
	}
	
	if( [types count] == 0 ) return;
	
	[pb declareTypes:types owner:nil];
	
	if( [self image] ) {
		NSData *data = [[self image] TIFFRepresentation];
		if( data ) {
			[pb setData:data forType:NSTIFFPboardType];
		}
	}
}

-(IBAction)paste:(id)sender
{
	if( ![self setImageFromPasteboard:[NSPasteboard generalPasteboard]] ) {
		NSBeep();
	}
}
-(IBAction)delete:(id)sender
{
	[self setImage:nil];
}
-(IBAction)cut:(id)sender
{
	[self copy:sender];
	[self delete:sender];
}

-(NSArray *)acceptPasteTypes
{
	return [NSArray arrayWithObjects:
		NSFilenamesPboardType,
		NSFilesPromisePboardType,
		NSURLPboardType,
		NSTIFFPboardType,
		nil];
}
-(BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = [menuItem action];
	
	if( action == @selector(paste:) ) {
		NSPasteboard *pb = [NSPasteboard generalPasteboard];
		NSString *availableType = [pb availableTypeFromArray:[self acceptPasteTypes]];
		
		if( availableType != nil && ![availableType isEqualTo:NSURLPboardType] ) {
			return YES;
		} else if( [availableType isEqualTo:NSURLPboardType] ) {
			NSArray *paths;
			NSString *path;
			NSString *lowerExtension;
			
			paths = [pb propertyListForType:NSURLPboardType];
			if( ![paths isKindOfClass:[NSArray class]] ) return NO;
			
			path = [paths objectAtIndex:0];
			if( !path ) return NO;
			
			lowerExtension = [[[path lastPathComponent] pathExtension] lowercaseString];
			if( ![[NSImage imageFileTypes] containsObject:lowerExtension] ) return NO;
		} else {
			return NO;
		}
	} else if( action == @selector(copy:)
			   || action == @selector(cut:)
			   || action == @selector(delete:) ) {
		return (nil != [self image]);
	}
	
	return YES;
}

@end
