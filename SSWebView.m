//
//  SSWebView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 08/09/14.
//
//

#import "SSWebView.h"
#if TARGET_OS_IPHONE
#import <base/SSGeometry.h>
#import <graphics/SSColor.h>
#import <foundation/NSTimer+SSAdditions.h>
#import <foundation/NSObject+SSAdditions.h>
#import "UIColor+SSAdditions.h"
#import "UIView+SSAdditions.h"
#else
#import <SSBase/SSGeometry.h>
#import <SSGraphics/SSColor.h>
#import <SSFoundation/NSTimer+SSAdditions.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import "NSColor+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import "NSView+SSAdditions.h"
#endif

@interface SSWebView ()

@property (nonatomic, strong) CALayer *contentLayer;

@end

@implementation SSWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#if TARGET_OS_IPHONE
        CALayer *backingLayer = self.makeBackingLayer;
        CALayer *layer = self.layer;
        layer.opaque = backingLayer.isOpaque;
        layer.backgroundColor = backingLayer.backgroundColor;
        layer.actions = backingLayer.actions;
        layer.sublayers = [[backingLayer.sublayers copy] autorelease];
#endif
    }
    return self;
}

- (void)dealloc
{
    [_cachedCells release];
    [_contentLayer release];
    [_content release];
    [_selectedObjects release];
    
    [super ss_dealloc];
}

- (void)drawRect:(CGRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)layout
{
    [self sizeToFit];
    
    for (id obj in _content) {
        CGRect frame = [obj frame];
        CALayer *cell = [self reusableCellForObject:obj];
        cell.bounds = frame;
        cell.position = frame.origin;
        
        [_contentLayer addSublayer:cell];
    }
    
    [super layout];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize contentSize = self.enclosingScrollView.frame.size;
    if (SSSizeIsEmpty(contentSize))
        contentSize = self.bounds.size;
    
    for (id obj in _content) {
        contentSize.width = MAX(contentSize.width, FLOOR(CGRectGetMaxX([obj frame])*(CGFloat)1.1));
        contentSize.height = MAX(contentSize.height, FLOOR(CGRectGetMaxY([obj frame])*(CGFloat)1.1));
    }
    
    return contentSize;
}

- (id)newCellForObject:(id)object
{
    static CATransform3D const transform = {1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, -1.0/800.0, 0, 0, 0, 1};
    id contents = [object contents];
    CGColorRef backgroundColor = [[object backgroundColor] CGColor];
    CGFloat cornerRadius = [object cornerRadius];
    CGFloat borderWidth = [object borderWidth];
    CGColorRef borderColor = [(__bridge id)[object borderColor] CGColor];
    CGColorRef shadowColor = [(__bridge id)[object shadowColor] CGColor];
    float shadowOpacity = [object shadowOpacity];
    CGSize shadowOffset = [object shadowOffset];
    CGFloat shadowRadius = [object shadowRadius];
    
    CALayer *cell = [[CALayer alloc] init];
    cell.name = @"cell";
    cell.delegate = self;
    cell.needsDisplayOnBoundsChange = NO;
#if !TARGET_OS_IPHONE
    cell.layoutManager = self;
#endif
    cell.anchorPoint = CGPointZero;
    cell.sublayerTransform = transform;
    
    CALayer *containerLayer = [CALayer layer];
    containerLayer.name = @"containerLayer";
    containerLayer.delegate = self;
    containerLayer.needsDisplayOnBoundsChange = NO;
    if (kSSUsesOldGeometry)
        containerLayer.anchorPoint = SSPointTopLeft;
    else {
        containerLayer.anchorPoint = CGPointZero;
        containerLayer.transform = transform;
    }
    containerLayer.cornerRadius = cornerRadius;
    containerLayer.borderWidth = borderWidth;
    containerLayer.borderColor = borderColor;
    containerLayer.shadowColor = shadowColor;
    containerLayer.shadowOpacity = shadowOpacity;
    containerLayer.shadowOffset = shadowOffset;
    containerLayer.shadowRadius = shadowRadius;
    containerLayer.backgroundColor = backgroundColor;
    
    Class imageClass = NULL;
#if TARGET_OS_IPHONE
    imageClass = [UIImage class];
#else
    imageClass = [NSImage class];
#endif
    
    if ([contents isKindOfClass:imageClass]) {
        CALayer *imageLayer = [CALayer layer];
        imageLayer.name = @"imageLayer";
        imageLayer.delegate = self;
        imageLayer.needsDisplayOnBoundsChange = NO;
        imageLayer.anchorPoint = CGPointZero;
        imageLayer.contentsGravity = kCAGravityResizeAspect;
        imageLayer.masksToBounds = YES;
        imageLayer.contents = (__bridge id)[contents CGImage];
        
        [containerLayer addSublayer:imageLayer];
    } else if ([contents isKindOfClass:[NSString class]] || [contents isKindOfClass:[NSAttributedString class]]) {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.name = @"textLayer";
        textLayer.delegate = self;
        textLayer.wrapped = YES;
        textLayer.anchorPoint = CGPointZero;
#if defined(__MAC_10_7) || ((TARGET_OS_EMBEDDED || TARGET_OS_IPHONE) && defined(__IPHONE_5_0))
        if ([textLayer respondsToSelector:@selector(setContentsScale:)]) {
#if TARGET_OS_IPHONE
            textLayer.contentsScale = [[UIScreen mainScreen] scale];
#else
            textLayer.contentsScale = CGRectGetWidth([self convertRectToBacking:self.bounds])/CGRectGetWidth(self.bounds);
#endif
        }
        if ([textLayer respondsToSelector:@selector(setShouldRasterize:)])
            textLayer.shouldRasterize = YES;
        if ([textLayer respondsToSelector:@selector(setRasterizationScale:)])
            textLayer.rasterizationScale = textLayer.contentsScale;
#endif
        textLayer.string = contents;
        if ([contents isKindOfClass:[NSString class]]) {
            if ([object respondsToSelector:@selector(fontName)])
                textLayer.font = [object fontName];
            else
                textLayer.font = @"Helvetica";
            if ([object respondsToSelector:@selector(fontSize)])
                textLayer.fontSize = [object fontSize];
            else
                textLayer.fontSize = 13.0;
            
            if ([object respondsToSelector:@selector(textColor)])
                textLayer.foregroundColor = [[object textColor] CGColor];
            else
                textLayer.foregroundColor = SSColorGetBlackColor();
        }
        
        [containerLayer addSublayer:textLayer];
    }
    
    [cell addSublayer:containerLayer];
    
    return cell;
}

- (id)reusableCellForObject:(id)object
{
    NSString *identifier = [object identifier];
    if (!identifier)
        return nil;
    
    CALayer *cell = _cachedCells[identifier];
    if (!cell) {
        cell = [[self newCellForObject:object] autorelease];
        if (!_cachedCells)
            _cachedCells = [[NSMutableDictionary alloc] init];
        _cachedCells[identifier] = cell;
    }
    return cell;
}

#pragma mark CALayer delegate

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    if (![layer.name isEqualToString:@"cell"])
        return;
    
    CGRect bounds = layer.bounds;
    CALayer *containerLayer = (layer.sublayers)[0];
    containerLayer.bounds = bounds;
    containerLayer.position = bounds.origin;
    
    for (CALayer *sublayer in containerLayer.sublayers) {
        if ([sublayer isKindOfClass:[CATextLayer class]]) {
            sublayer.frame = bounds;
        } else {
            sublayer.bounds = bounds;
            sublayer.position = bounds.origin;
        }
    }
}

#pragma mark actions

#if TARGET_OS_IPHONE
- (void)delete:(id)sender;
#else
- (IBAction)delete:(id)sender;
#endif
{
    if (!self.canDelete) {
        NSBeep();
    }
    
    [_delegate webViewRemove:self];
}

#if TARGET_OS_IPHONE
- (void)selectAll:(id)sender;
#else
- (IBAction)selectAll:(id)sender;
#endif
{
    self.selectedObjects = _content;
}

- (IBAction)deselectAll:(id)sender
{
    self.selectedObjects = @[];
}

#if !TARGET_OS_IPHONE

#pragma mark NSEvents

- (void)mouseDown:(NSEvent *)event
{
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    id object = [[_content filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectContainsPoint([evaluatedObject frame], location);
    }]] firstObject];
    
    if (!object) {
        if (event.modifierFlags & NSControlKeyMask) {
            
        } else {
            [self deselectAll:nil];
        }
        return;
    }
    
    switch (event.clickCount) {
        case 1: {
            NSArray *selectedObjects = self.selectedObjects;
            if ((event.modifierFlags & NSCommandKeyMask) != 0) {
                NSMutableArray *array = [NSMutableArray array];
                [array addObjectsFromArray:selectedObjects];
                
                if ([array containsObject:object]) {
                    [array removeObject:object];
                } else {
                    [array addObject:object];
                }
                
                self.selectedObjects = array;
            } else {
                if ([selectedObjects containsObject:object])
                    [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:0.5 userInfo:@[object] completionHandler:^(NSArray *array) {
                        if (!_flags.draggingObject)
                            self.selectedObjects = array;
                    }] forMode:NSRunLoopCommonModes];
                else
                    self.selectedObjects = @[object];
            }
            
            switch (_selectedObjects.count) {
                case 0:
                    break;
                default:
                    _flags.draggingObject = 1;
                    break;
            }
            
        }
            break;
        default: {
            self.selectedObjects = @[object];
            id contents = [object contents];
            if ([contents isKindOfClass:[NSImage class]]) {
                
            } else if ([contents isKindOfClass:[NSString class]] || [contents isKindOfClass:[NSAttributedString class]]) {
                
            }
        }
            break;
    }
}

- (void)mouseUp:(NSEvent *)event
{
    _flags.draggingObject = 0;
}

- (void)mouseDragged:(NSEvent *)event
{
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (_flags.draggingObject) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            if (_selectedObjects.count) {
                NSMutableArray *draggingItems = [NSMutableArray array];
                for (id object in _selectedObjects) {
                    @autoreleasepool {
                        Class NSPasteboardItemClass = NSClassFromString(@"NSPasteboardItem");
                        id pasteboardItem = [[[NSPasteboardItemClass alloc] init] autorelease];
                        id contents = [object contents];
                        if ([contents isKindOfClass:[NSImage class]]) {
                            [pasteboardItem setData:[contents TIFFRepresentation] forType:(__bridge NSString *)kUTTypeTIFF];
                        } else if ([contents isKindOfClass:[NSAttributedString class]]) {
                            [pasteboardItem setString:[contents string] forType:(__bridge NSString *)kUTTypeUTF8PlainText];
                        }
                        
                        Class NSDraggingItemClass = NSClassFromString(@"NSDraggingItem");
                        id draggingItem = [[[NSDraggingItemClass alloc] initWithPasteboardWriter:pasteboardItem] autorelease];
                        
                        CGRect frame = [object frame];
                        [draggingItem setDraggingFrame:frame contents:(__bridge id)SSAutorelease(SSImageCreate(frame.size, ^(CGContextRef ctx) {
                            CGRect bounds = CGContextGetClipBoundingBox(ctx);
                            NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO];
                            [NSGraphicsContext setCurrentContext:context];
                            [context saveGraphicsState];
                            context.shouldAntialias = YES;
                            context.imageInterpolation = NSImageInterpolationHigh;
                            
                            NSBezierPath *path = nil;
                            CGFloat cornerRadius = [object cornerRadius];
                            if (isgreater(cornerRadius, 0.0))
                                path = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:cornerRadius yRadius:cornerRadius];
                            else
                                path = [NSBezierPath bezierPathWithRect:bounds];
                            
                            NSColor *backgroundColor = [object backgroundColor];
                            if (backgroundColor) {
                                [backgroundColor setFill];
                                [path fill];
                            }
                            
                            float shadowOpacity = [object shadowOpacity];
                            if (isgreater(shadowOpacity, 0.0)) {
                                NSColor *shadowColor = (__bridge NSColor *)[object shadowColor];
                                if (shadowColor) {
                                    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
                                    shadow.shadowColor = shadowColor;
                                    shadow.shadowBlurRadius = [object shadowRadius];
                                    shadow.shadowOffset = [object shadowOffset];
                                    [shadow set];
                                }
                            }
                            
                            if ([contents isKindOfClass:[NSImage class]]) {
                                [(NSImage *)contents drawInRect:bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
                            } else if ([contents isKindOfClass:[NSAttributedString class]]) {
                                [(NSAttributedString *)contents drawInRect:bounds];
                            } else if ([contents isKindOfClass:[NSString class]]) {
                                NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                                if ([object respondsToSelector:@selector(fontName)] && [object fontName] && [object respondsToSelector:@selector(fontSize)] && [object fontSize])
                                    attributes[NSFontAttributeName] = [NSFont fontWithName:[object fontName] size:[object fontSize]];
                                if ([object respondsToSelector:@selector(textColor)])
                                    attributes[NSForegroundColorAttributeName] = [object textColor];
                                
                                [(NSString *)contents drawInRect:bounds withAttributes:attributes];
                            }
                            
                            CGFloat borderWidth = [object borderWidth];
                            if (isgreater(borderWidth, 0.0)) {
                                path.lineWidth = borderWidth;
                                
                                NSColor *borderColor = [object borderColor];
                                if (borderColor) {
                                    [borderColor setStroke];
                                    [path stroke];
                                }
                            }
                            
                            [context restoreGraphicsState];
                        }))];
                        [draggingItems addObject:draggingItem];
                    }
                }
                
                if (draggingItems.count) {
                    id session = [self beginDraggingSessionWithItems:draggingItems event:event source:self];
                    [session setAnimatesToStartingPositionsOnCancelOrFail:YES];
                    [session setDraggingFormation:NSDraggingFormationPile];
                }
            }
        } else {
#if MAC_OS_X_VERSION_MIN_REQUIRED < 1070
            [self dragImage:nil at:location offset:CGSizeZero event:event pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard] source:self slideBack:YES];
#endif
        }
    }
}

#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060

#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    NSDragOperation operation = NSDragOperationCopy;
    if (context == NSDraggingContextWithinApplication)
        operation |= NSDragOperationMove;
    else
        operation |= NSDragOperationDelete;
    return operation;
}

#else

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    NSDragOperation operation = NSDragOperationCopy;
    if (isLocal)
        operation |= NSDragOperationMove;
    else
        operation |= NSDragOperationDelete;
    return operation;
}

#endif

- (void)dragImage:(NSImage *)anImage at:(NSPoint)viewLocation offset:(CGSize)initialOffset event:(NSEvent *)event pasteboard:(NSPasteboard *)pboard source:(id)sourceObj slideBack:(BOOL)slideFlag
{
    NSImage *image = nil;
    
    [super dragImage:image at:viewLocation offset:initialOffset event:event pasteboard:pboard source:sourceObj slideBack:slideFlag];
}

#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if (sender.draggingSource == self)
        return NSDragOperationGeneric;
    if (_flags.delegateRespondsToValidateDrop)
        return [_delegate webView:self validateDrop:sender];
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ((sender.draggingSource == self) && _flags.allowsReordering) {
        CGPoint location = [self convertPoint:sender.draggingLocation fromView:nil];
        for (id object in _selectedObjects) {
            CGRect frame = CGRectIntegral(SSRectCenteredAroundPoint([object frame], location));
            CALayer *layer = [self reusableCellForObject:object];
            layer.position = frame.origin;
            [object setFrame:layer.frame];
        }
        [self layout];
        return YES;
    }
    
    if (_flags.delegateRespondsToAcceptDrop)
        return [self.delegate webView:self acceptDrop:sender];
    return NO;
}

- (BOOL)wantsPeriodicDraggingUpdates
{
    return NO;
}

- (void)updateDraggingItemsForDrag:(id <NSDraggingInfo>)sender
{
    
}

#pragma mark NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item
{
    return YES;
}

#pragma mark NSView

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    
    if (!self.superview)
        return;
    
    if (!self.wantsLayer)
        self.wantsLayer = YES;
    if (!self.enclosingScrollView.wantsLayer)
        self.enclosingScrollView.wantsLayer = YES;
    self.enclosingScrollView.backgroundColor = [NSColor colorWithCGColor:self.layer.backgroundColor];
    self.superview.layer.backgroundColor = self.layer.backgroundColor;
    self.enclosingScrollView.layer.backgroundColor = self.layer.backgroundColor;
}

- (void)registerForDraggedTypes:(NSArray *)newTypes
{
    NSMutableArray *types = [[newTypes mutableCopy] autorelease];
    if (![types containsObject:(__bridge NSString *)kUTTypeImage])
        [types addObject:(__bridge NSString *)kUTTypeImage];
    if (![types containsObject:(__bridge NSString *)kUTTypeText])
        [types addObject:(__bridge NSString *)kUTTypeText];
    
    [super registerForDraggedTypes:types];
}

#endif

#pragma mark getters & setters

- (CALayer *)makeBackingLayer
{
    CALayer *layer = [CALayer layer];
    layer.opaque = YES;
    layer.backgroundColor = SSColorGetWhiteColor();
    
    CALayer *contentLayer = [CALayer layer];
#if TARGET_OS_IPHONE
    contentLayer.actions = @{};
    contentLayer.frame = self.bounds;
#else
    contentLayer.delegate = self;
    contentLayer.autoresizingMask = kCALayerWidthSizable|kCALayerHeightSizable;
#endif
    if (kSSUsesOldGeometry)
        contentLayer.sublayerTransform = CATransform3DMakeScale(1.0, -1.0, 1.0);
    contentLayer.sublayers = _contentLayer.sublayers;
    
    [layer addSublayer:contentLayer];
    
    self.contentLayer = contentLayer;
    
    return layer;
}

- (CALayer *)contentLayer
{
    return _contentLayer;
}

- (void)setContentLayer:(CALayer *)contentLayer
{
    SSNonAtomicRetainedSet(_contentLayer, contentLayer);
}

- (id<SSWebViewDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<SSWebViewDelegate>)delegate
{
    _delegate = delegate;
    
#if !TARGET_OS_IPHONE
    _flags.delegateRespondsToAcceptDrop = [delegate respondsToSelector:@selector(webView:acceptDrop:)] ? 1 : 0;
#endif
    _flags.delegateRespondsToShouldRemove = [delegate respondsToSelector:@selector(webViewShouldRemoveImage:)] ? 1 : 0;
    _flags.delegateRespondsToRemove = [delegate respondsToSelector:@selector(webViewRemoveImage:)] ? 1 : 0;
}

- (NSArray *)content
{
    return _content;
}

- (void)setContent:(NSArray *)content
{
    if ([_content isEqualToArray:content])
        return;
    
    for (id object in _content) {
        CALayer *cell = [self reusableCellForObject:object];
        [cell removeFromSuperlayer];
        
        if (![content containsObject:object]) {
            [_cachedCells removeObjectForKey:[object identifier]];
        }
    }
    
    _contentLayer.sublayers = @[];
    
    SSNonAtomicRetainedSet(_content, content);
    
    [self layout];
}

- (NSArray *)selectedObjects
{
    return _selectedObjects;
}

- (void)setSelectedObjects:(NSArray *)selectedObjects
{
    SSNonAtomicCopiedSet(_selectedObjects, selectedObjects);
}

- (BOOL)allowsReordering
{
    return _flags.allowsReordering;
}

- (void)setAllowsReordering:(BOOL)allowsReordering
{
    _flags.allowsReordering = allowsReordering;
}

- (BOOL)canDelete
{
    if (_flags.delegateRespondsToShouldRemove)
        return [_delegate webViewShouldRemove:self];
    return _flags.delegateRespondsToRemove;
}

- (BOOL)isFirstResponder
{
    return _flags.isFirstResponder;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    _flags.isFirstResponder = 1;
    return YES;
}

- (BOOL)resignFirstResponder
{
    _flags.isFirstResponder = 0;
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

@end
