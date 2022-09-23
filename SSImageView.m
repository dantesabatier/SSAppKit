//
//  SSImageView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/14/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSImageView.h"
#if TARGET_OS_IPHONE
#import <graphics/SSColor.h>
#import <graphics/SSContext.h>
#import <graphics/SSUtilities.h>
#import <graphics/SSImage.h>
#import <graphics/SSPath.h>
#else
#import <SSGraphics/SSColor.h>
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSUtilities.h>
#import <SSGraphics/SSImage.h>
#import <SSGraphics/SSPath.h>
#import "NSImage+SSAdditions.h"
#endif

@interface SSImageView ()

@end

@implementation SSImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _maximumImageSize = CGSizeZero;
        _imageResizingMethod = SSRectResizingMethodScale;
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#endif
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.imageResizingMethod = [coder decodeIntegerForKey:@"imageResizingMethod"];
#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#else
        self.maximumImageSize = [coder decodeSizeForKey:@"maximumImageSize"];
        self.doubleClickOpensImageEditPanel = [coder decodeBoolForKey:@"doubleClickOpensImageEditPanel"];
#endif
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.imageResizingMethod forKey:@"imageResizingMethod"];
#if !TARGET_OS_IPHONE
    [coder encodeSize:self.maximumImageSize forKey:@"maximumImageSize"];
    [coder encodeBool:self.doubleClickOpensImageEditPanel forKey:@"doubleClickOpensImageEditPanel"];
#endif
}

- (void)dealloc {
    _delegate = nil;
    _target = nil;
    _action = NULL;
    
    [_imageProperties release];
    
    CGImageRelease(_image);
    
    [super ss_dealloc];
}

#pragma mark actions

- (void)copy:(id)sender {
    if (_image) {
#if TARGET_OS_IPHONE
        UIImage *image = [UIImage imageWithCGImage:_image];
        if (image) {
            [[UIPasteboard generalPasteboard] setData:UIImagePNGRepresentation(image) forPasteboardType:(__bridge NSString *)kUTTypePNG];
        }
#else
        NSImage *image = [NSImage imageWithCGImage:_image];
        if (image) {
            NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
            [pasteboard clearContents];
            [pasteboard writeObjects:@[image]];
        }
#endif
    }
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    _maximumImageSize = CGSizeZero;
    _imageResizingMethod = SSRectResizingMethodScale;
}

#endif

#pragma mark drawing

- (void)drawImage:(CGImageRef)image rect:(CGRect)rect context:(CGContextRef)ctx {
    if (image) {
        CGRect imageBounds = rect;
        if (1) {
            CGSize imageSize = SSImageGetSize(image);
            if ((imageSize.width < imageBounds.size.width) || (imageSize.height < imageBounds.size.height)) {
                imageBounds = SSRectMakeWithAspectRatioInsideRect(imageBounds, SSRectCenteredSize(imageBounds, imageSize), SSRectResizingMethodScale);
            }
        }
        CGSize maximumImageSize = CGSizeMake(FLOOR(_maximumImageSize.width), FLOOR(_maximumImageSize.height));
        CGSize boundingSize = maximumImageSize;
        if (!CGSizeEqualToSize(boundingSize, CGSizeZero)) {
            if ((boundingSize.width > imageBounds.size.width) || (boundingSize.height > imageBounds.size.height)) {
                boundingSize = SSSizeMakeWithAspectRatioInsideSize(boundingSize, imageBounds.size, SSRectResizingMethodScale);
                image = SSAutorelease(SSImageCreateCopyWithSize(image, maximumImageSize, _imageResizingMethod));
                image = SSAutorelease(SSImageCreateCopyWithSize(image, boundingSize, SSRectResizingMethodScale));
                boundingSize = SSImageGetSize(image);
            }
            imageBounds = SSRectCenteredSize(imageBounds, boundingSize);
        }
        
        imageBounds = CGRectIntegral(imageBounds);
        
        CGContextSaveGState(ctx);
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        SSContextDrawImage(ctx, image, imageBounds, _imageResizingMethod);
        CGContextRestoreGState(ctx);
    }
}

- (void)drawInRect:(CGRect)rect context:(CGContextRef)ctx {
    [self drawImage:self.image rect:rect context:ctx];
}

- (void)drawRect:(CGRect)dirtyRect {
    CGContextRef ctx = SSContextGetCurrent();
    CGContextSaveGState(ctx);
    
    BOOL isDrawingToScreen = YES;
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
    isDrawingToScreen = [NSGraphicsContext currentContext].drawingToScreen;
#endif
    if (isDrawingToScreen) {
        [super drawRect:dirtyRect];
    }
    
    CGFloat scale = self.scale;
    CGFloat inset = _borderWidth*scale;
    CGRect bounds = CGRectIntegral(CGRectInset(self.bounds, inset, inset));
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(ctx, 1.0, -1.0);
    
    [self drawInRect:bounds context:ctx];
    
    CGContextRestoreGState(ctx);
}

#if TARGET_OS_IPHONE

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification {
    [self setNeedsDisplay];
}

#else

#pragma mark NSResponder

- (void)insertTab:(id)sender {
    if (self.window.firstResponder == self) {
        [self.window selectNextKeyView:self];
    }
}

- (void)insertBacktab:(id)sender {
    if (self.window.firstResponder == self) {
        [self.window selectPreviousKeyView:self];
    }
}

#pragma mark NSEvent

- (void)mouseDown:(NSEvent *)event {
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (CGRectContainsPoint(self.imageBounds, location)) {
        _flags.dragging = 1;
    }
    
    if (event.clickCount == 2) {
        if (_action) {
            id target = _target;
            if (!target) {
                target = [NSApp targetForAction:_action];
            }
                
            [target performSelector:_action withObject:self];
        }
    }
}

- (void)mouseUp:(NSEvent *)event {
    _flags.dragging = 0;
}

- (void)mouseDragged:(NSEvent *)event {
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (_flags.dragging) {
        if (_delegate) {
            NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
#if defined(__MAC_10_7)
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
                if (_flags.delegateRespondsToPasteboardWriter) {
                    id writer = [_delegate pasteboardWriterForImageView:self];
                    if (writer) {
                        Class NSDraggingItemClass = NSClassFromString(@"NSDraggingItem");
                        id draggingItem = [[[NSDraggingItemClass alloc] initWithPasteboardWriter:writer] autorelease];
                        [draggingItem setDraggingFrame:self.bounds contents:(__bridge id)SSAutorelease(SSImageCreate(self.bounds.size, ^(CGContextRef ctx) {
                            [self drawInRect:self.bounds context:ctx];
                        }))];
                        
                        id session = [self beginDraggingSessionWithItems:@[draggingItem] event:event source:self];
                        [session setAnimatesToStartingPositionsOnCancelOrFail:YES];
                        [session setDraggingFormation:NSDraggingFormationNone];
                        
                        if (_flags.delegateRespondsToDraggingSessionWillBegin) {
                            [_delegate imageView:self draggingSession:session willBeginAtPoint:location];
                        }
                    }
                } else {
                    if (_flags.delegateRespondsToWriteItem && [_delegate imageView:self writeToPasteboard:pboard]) {
                        [self dragImageAtPoint:location offset:CGSizeZero event:event pasteboard:pboard source:self slideBack:YES];
                    }
                }
            } else {
                if (_flags.delegateRespondsToWriteItem && [_delegate imageView:self writeToPasteboard:pboard]) {
                    [self dragImageAtPoint:location offset:CGSizeZero event:event pasteboard:pboard source:self slideBack:YES];
                }
            }
#else
            if (_flags.delegateRespondsToWriteItem && [_delegate imageView:self writeToPasteboard:pboard]) {
                [self dragImageAtPoint:location offset:CGSizeZero event:event pasteboard:pboard source:self slideBack:YES];
            }
#endif
        }
        
    }
}

#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060

#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    NSDragOperation operation = NSDragOperationCopy;
    if (context == NSDraggingContextWithinApplication) {
        operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
        
    return operation;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(CGPoint)screenPoint operation:(NSDragOperation)operation {
    _flags.dragging = 0;
    
    if (_flags.delegateRespondsToDraggingSessionEnded) {
        [self.delegate imageView:self draggingSession:session endedAtPoint:screenPoint operation:operation];
    }
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
    if (_flags.delegateRespondsToIgnoreModifierKeys) {
        return [self.delegate imageView:self ignoreModifierKeysForDraggingSession:session];
    }
        
    return NO;
}

#else

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSDragOperation operation = NSDragOperationCopy;
    if (isLocal) {
        operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
    return operation;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    _flags.dragging = 0;
}

#endif

- (void)dragImageAtPoint:(CGPoint)point offset:(CGSize)offset event:(NSEvent *)event pasteboard:(NSPasteboard *)pasteboard source:(id)source slideBack:(BOOL)slideBack {
    CGRect imageBounds = self.bounds;
    CGSize imageSize = imageBounds.size;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        imageSize = [self convertSizeToBacking:imageSize];
    }
#endif
    
    CGImageRef imageRef = SSAutorelease(SSImageCreate(imageSize, ^(CGContextRef ctx) {
        CGContextSaveGState(ctx);
        CGContextSetAlpha(ctx, 0.99);
        CGContextBeginTransparencyLayer(ctx, NULL);
        [self drawInRect:SSRectMakeWithSize(imageSize) context:ctx];
        CGContextEndTransparencyLayer(ctx);
        CGContextRestoreGState(ctx);
    }));
    
    NSImage *image = [[[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero] autorelease];
    
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    
    point.x -= location.x - CGRectGetMinX(imageBounds);
    point.y += CGRectGetMaxY(imageBounds) - location.y;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self dragImage:image at:point offset:offset event:event pasteboard:pasteboard source:source slideBack:slideBack];
#pragma clang diagnostic pop
}

#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSDragOperation operation = NSDragOperationNone;
    if (sender.draggingSource != self) {
        if (_flags.delegateRespondsToValidateDrop) {
            operation = [self.delegate imageView:self validateDrop:sender];
        }
    }
    return operation;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender {
    
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if (_flags.delegateRespondsToAcceptDrop) {
        return [self.delegate imageView:self acceptDrop:sender];
    }
        
    return NO;
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return NO;
}

- (void)updateDraggingItemsForDrag:(id <NSDraggingInfo>)sender {
    if (sender.draggingSource == self)
        return;
    if (_flags.delegateRespondsToUpdateDraggingItems) {
        [self.delegate imageView:self updateDraggingItemsForDrag:sender];
    }
        
}

#endif

#pragma mark IKImageEditPanelDataSource

- (void)setImage:(CGImageRef)image imageProperties:(NSDictionary *)imageProperties {
    self.image = image;
    if (!self.imageProperties) {
        self.imageProperties = imageProperties;
    }
        
}

- (CGImageRef)thumbnailWithMaximumSize:(CGSize)size {
    return SSAutorelease(SSImageCreate(size, ^(CGContextRef ctx) {
        [self drawInRect:SSRectMakeWithSize(size) context:ctx];
    }));
}

#pragma mark getters & setters

- (id<SSImageViewDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSImageViewDelegate>)delegate {
    _delegate = delegate;
    
#if !TARGET_OS_IPHONE
    _flags.delegateRespondsToPasteboardWriter = [delegate respondsToSelector:@selector(pasteboardWriterForImageView:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingSessionWillBegin = [delegate respondsToSelector:@selector(imageView:draggingSession:willBeginAtPoint:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingSessionEnded = [delegate respondsToSelector:@selector(imageView:draggingSession:endedAtPoint:operation:)] ? 1 : 0;
    _flags.delegateRespondsToIgnoreModifierKeys = [delegate respondsToSelector:@selector(imageView:ignoreModifierKeysForDraggingSession:)] ? 1 : 0;
    _flags.delegateRespondsToUpdateDraggingItems = [delegate respondsToSelector:@selector(imageView:updateDraggingItemsForDrag:)] ? 1 : 0;
    _flags.delegateRespondsToWriteItem = [delegate respondsToSelector:@selector(imageView:writeToPasteboard:)] ? 1 : 0;
    _flags.delegateRespondsToValidateDrop = [delegate respondsToSelector:@selector(imageView:validateDrop:)] ? 1 : 0;
    _flags.delegateRespondsToAcceptDrop = [delegate respondsToSelector:@selector(imageView:acceptDrop:)] ? 1 : 0;
#endif
}

- (id)target {
    return _target;
}

- (void)setTarget:(id)target {
    _target = target;
}

- (SEL)action {
    return _action;
}

- (void)setAction:(SEL)action {
    _action = action;
}

- (CGImageRef)image {
    return _image;
}

- (void)setImage:(CGImageRef)image {
    if (_image == image) {
        return;
    }
    
    SSRetainedTypeSet(_image, image);
    
    self.imageProperties = nil;
    
    [self setNeedsDisplay];
}

- (NSDictionary *)imageProperties {
    return SSAtomicAutoreleasedGet(_imageProperties);
}

- (void)setImageProperties:(NSDictionary *)imageProperties {
    SSAtomicCopiedSet(_imageProperties, imageProperties);
}

- (CGSize)maximumImageSize {
    return _maximumImageSize;
}

- (void)setMaximumImageSize:(CGSize)maximumImageSize {
    if (CGSizeEqualToSize(_maximumImageSize, maximumImageSize)) {
        return;
    }
    
    _maximumImageSize = maximumImageSize;
    
    [self setNeedsDisplay];
}

- (SSRectResizingMethod)imageResizingMethod {
    return _imageResizingMethod;
}

- (void)setImageResizingMethod:(SSRectResizingMethod)imageResizingMethod {
    if (_imageResizingMethod == imageResizingMethod) {
        return;
    }
    
    _imageResizingMethod = imageResizingMethod;
    
    [self setNeedsDisplay];
}

- (BOOL)doubleClickOpensImageEditPanel {
    return _flags.doubleClickOpensImageEditPanel;
}

- (void)setDoubleClickOpensImageEditPanel:(BOOL)doubleClickOpensImageEditPanel {
    _flags.doubleClickOpensImageEditPanel = doubleClickOpensImageEditPanel;
}

- (CGRect)imageBounds {
    return _image ? CGRectIntegral(SSRectCenteredSize(self.bounds, SSSizeMakeWithAspectRatioInsideSize(SSImageGetSize(_image), self.bounds.size, _imageResizingMethod))) : CGRectZero;
}

#if !TARGET_OS_IPHONE

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

#endif

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)allowsVibrancy {
    return NO;
}

@end
