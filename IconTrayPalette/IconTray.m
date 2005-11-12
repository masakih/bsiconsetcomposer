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
-(void)registDraggedTypes;
@end

static NSString *IconTrayImageKey = @"IconTrayImageKey";
static NSString *IconTrayTitleKey = @"IconTrayTitleKey";
static NSString *IconTrayIdentifierKey = @"IconTrayIdentifierKey";
static NSString *IconTrayImagePositionKey =@"IconTrayImagePositionKey";

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

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	if( self ) {
		
		image = [[NSImageCell alloc] initImageCell:nil];
		title = [[NSTextFieldCell alloc] initTextCell:@""];
		identifier = [[NSString stringWithString:@""] retain];
		
		[self setImageAlignment:NSImageAlignCenter];
		[image setSelectable:YES];
		[self setImagePosition:NSImageAbove];
		[self setAlignment:NSCenterTextAlignment];
		
		if( [self respondsToSelector:@selector(registDraggedTypes)] ) {
			[self registDraggedTypes];
		}
	}
	
	return self;
}
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	
	if( [decoder allowsKeyedCoding] ) {
		NSImage *i;
		
		image = [[decoder decodeObjectForKey:IconTrayImageKey] retain];
		title = [[decoder decodeObjectForKey:IconTrayTitleKey] retain];
		identifier = [[decoder decodeObjectForKey:IconTrayIdentifierKey] retain];
		
		[self setImagePosition:[decoder decodeIntForKey:IconTrayImagePositionKey]];
		
		// setting other property of image.
		i = [image image];
		[self setImage:i];
	}
	
	if( [self respondsToSelector:@selector(registDraggedTypes)] ) {
		[self registDraggedTypes];
	}
	
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	
	if( [coder allowsKeyedCoding] ) {
		id tmp;
		
		// store other properties.
		tmp = [[image representedObject] retain];
		[image setRepresentedObject:nil];
		
		[coder encodeObject:image forKey:IconTrayImageKey];
		[coder encodeObject:title forKey:IconTrayTitleKey];
		[coder encodeObject:identifier forKey:IconTrayIdentifierKey];
		[coder encodeInt:imagePosition forKey:IconTrayImagePositionKey];
		
		// restore other properties.
		[image setRepresentedObject:[tmp autorelease]];
	}
}

-(void)dealloc
{
	[self unregisterDraggedTypes];
	
	[image setRepresentedObject:nil];
	[image release];
	[title setRepresentedObject:nil];
	[title release];
	[identifier release];
	[placeholderImage release];
	
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
	
	titleSize = [title cellSize];
	
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
	
	titleSize = [title cellSize];
	
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
	
	[super drawRect:rect];
	
	cellRect = [self titleRect];
	[title drawInteriorWithFrame:cellRect inView:self];
	
	cellRect = [self imageRect];
	if( [self respondsToSelector:@selector(drawInPalette)] ) {
		[self performSelector:@selector(drawInPalette)];
	} else {
		if( [image isHighlighted] && [[self window] isKeyWindow] ) {
			[NSGraphicsContext saveGraphicsState];
			NSSetFocusRingStyle(NSFocusRingAbove);
			[[NSColor selectedControlColor] set];
			
			[image drawInteriorWithFrame:cellRect inView:self];
			
			[NSGraphicsContext restoreGraphicsState];
		} else {
			[image drawInteriorWithFrame:cellRect inView:self];
		}
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
// - (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options;
// - (void)unbind:(NSString *)binding;


#pragma mark-
#pragma mark## Accessor ##

-(id)delegate
{
	return delegate;
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
	id temp = placeholderImage;
	placeholderImage = [placeholder retain];
	[temp release];
	
	if( ![image image] ) {
		[image setImage:placeholderImage];
		[self updateCell:image];
	}
}
-(BOOL)setImageName:(NSString *)newName
{
	NSFileWrapper *fileWrapper = [image representedObject];
	
	if( !fileWrapper ) return NO;
	
	[fileWrapper setPreferredFilename:newName];
	
	return YES;
}
// primitive method.
-(BOOL)setImage:(NSImage *)inImage fileWrapper:(NSFileWrapper *)wrapper
{
	if( inImage && ![inImage isKindOfClass:[NSImage class]] ) return NO;
	
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:willChangeFileOfImage:)]
		&& ![delegate iconTray:self willChangeFileOfImage:wrapper] ) {
		return NO;
	}
	
	if( !inImage && placeholderImage ) {
		inImage = placeholderImage;
		wrapper = nil;
	}
	[image setImage:inImage];
	[image setRepresentedObject:wrapper];
	
	if( delegate
		&& [delegate respondsToSelector:@selector(iconTray:didChangeFileOfImage:)] ) {
		
		[delegate iconTray:self didChangeFileOfImage:wrapper];
	}
	[self postNotificationWithName:IconTrayImageFileDidChangeNotification];
	
	[self updateCell:image];
	
	return YES;
}
-(BOOL)setImageFileWrapper:(NSFileWrapper *)imageFileWrapper
{
	NSImage *img;
	
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
		
		data = [pathURL resourceDataUsingCache:YES];
		aImage = [[[NSImage alloc] initWithData:data] autorelease];
	}
	
	if( aImage ) {
		return [self setImage:aImage withName:imageName];
	}
	
	return NO;
}

-(NSImage *)image
{
	NSImage *result = [image image];
	
	if( placeholderImage && [placeholderImage isEqual:result] ) {
		result = nil;
	}
	
	return result;
}
-(NSFileWrapper *)imageFileWrapper
{
	return [image representedObject];
}
-(NSString *)imageName
{
	return [[self imageFileWrapper] preferredFilename];
}
-(BOOL)setImage:(NSImage *)inImage
{
	return [self setImage:inImage withName:nil];
}
-(NSString *)title
{
	return [title stringValue];
}
-(void)setTitle:(NSString *)inTitle
{
	if( !inTitle || ![inTitle isKindOfClass:[NSString class]] ) return;
	
	[title setStringValue:inTitle];
	[self updateCell:title];
}
- (NSFont *)font
{
	return [title font];
}
- (void)setFont:(NSFont *)fontObj
{
	[title setFont:fontObj];
	[self updateCell:title];
}
-(NSString *)identifier
{
	return identifier;
}
-(void)setIdentifier:(NSString *)inIdentifier
{
	id tmp = identifier;
	identifier = [inIdentifier copy];
	[tmp release];
}

-(BOOL)isHighlighted
{
	return isHighlighted;
}
-(void)setHighlighted:(BOOL)flag
{
	isHighlighted = flag;
	[self setNeedsDisplay:YES];
}

- (NSTextAlignment)alignment
{
	return [title alignment];
}
- (void)setAlignment:(NSTextAlignment)mode
{
	[title setAlignment:mode];
	[self updateCell:title];
}

- (NSImageAlignment)imageAlignment
{
	return [image imageAlignment];
}
- (void)setImageAlignment:(NSImageAlignment)newAlign
{
	[image setImageAlignment:newAlign];
	[self updateCell:image];
}
- (NSImageScaling)imageScaling
{
	return [image imageScaling];
}
- (void)setImageScaling:(NSImageScaling)newScaling
{
	[image setImageScaling:newScaling];
	[self updateCell:image];
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
	
	imagePosition = aPosition;
	[self updateCell:image];
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
#endif
	
	[[self window] makeFirstResponder:self];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}
- (BOOL)becomeFirstResponder
{
	[image setHighlighted:YES];
	[self updateCell:image];
	return YES;
}
- (BOOL)resignFirstResponder
{
	[image setHighlighted:NO];
	[self updateCell:image];
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
-(BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
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
