//
//  SSDropZoneView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/05/14.
//
//

#import "SSDropZoneView.h"
#import "SSAppKitUtilities.h"
#if TARGET_OS_IPHONE
#import <graphics/SSContext.h>
#import <graphics/SSColor.h>
#import <graphics/SSUtilities.h>
#import <graphics/SSPath.h>
#else
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSColor.h>
#import <SSGraphics/SSUtilities.h>
#import <SSGraphics/SSPath.h>
#endif

@implementation SSDropZoneView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dropZoneSize = CGSizeZero;
#if TARGET_OS_IPHONE
        
#else
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            _fillColor = SSColorCreateDeviceGray(0.909804, 1.0);
            _strokeColor = SSColorCreateDeviceGray(0.860, 1.0);
            _labelColor = SSColorCreateDeviceGray(0.760, 1.0);
            _shadowColor = SSColorCreateDeviceGray(1.0, 1.0);
        } else {
            _fillColor = SSColorCreateDeviceGray(0.8, 1.0);
            _strokeColor = SSColorCreateDeviceGray(0.760, 1.0);
            _labelColor = SSColorCreateDeviceGray(0.5, 0.9);
            _shadowColor = SSColorCreateDeviceGray(0.9, 0.9);
        }
#endif
    }
    return self;
}

- (void)dealloc {
    [_label release];
    
    CGColorRelease(_shadowColor);
    CGColorRelease(_strokeColor);
    CGColorRelease(_labelColor);
    
    [super ss_dealloc];
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    _dropZoneSize = CGSizeZero;
#if TARGET_OS_IPHONE
    
#else
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        _fillColor = SSColorCreateDeviceGray(0.909804, 1.0);
        _strokeColor = SSColorCreateDeviceGray(0.860, 1.0);
        _labelColor = SSColorCreateDeviceGray(0.760, 1.0);
        _shadowColor = SSColorCreateDeviceGray(1.0, 1.0);
    } else {
        _fillColor = SSColorCreateDeviceGray(0.8, 1.0);
        _strokeColor = SSColorCreateDeviceGray(0.760, 1.0);
        _labelColor = SSColorCreateDeviceGray(0.5, 0.9);
        _shadowColor = SSColorCreateDeviceGray(0.9, 0.9);
    }
#endif
}

#endif

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.image)
        return;
    
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
    if (![NSGraphicsContext currentContext].drawingToScreen)
        return;
#endif
    
    CGContextRef ctx = SSContextGetCurrent();
    CGSize dropZoneSize = _dropZoneSize;
    BOOL dropZoneIsEmpty = SSSizeIsEmpty(dropZoneSize);
    CGRect bounds = self.bounds;
    CGRect boundingBox = CGRectInset(bounds, CGRectGetWidth(bounds)*0.05, CGRectGetHeight(bounds)*0.05);
    CGFloat lineWidth = 6.0*(CGFloat)self.scale;
    CGFloat lineDash = FLOOR(lineWidth*(CGFloat)3.0);
    CGRect dropAreaRect;
    CGRect titleRect;
    if (_label && _labelColor) {
        CGRect temporaryRect = boundingBox;
        if (!dropZoneIsEmpty) {
            temporaryRect = SSRectCenteredSquare(bounds, MIN(dropZoneSize.height*(CGFloat)1.25, CGRectGetHeight(boundingBox)));
        }
        CGRectDivide(temporaryRect, &titleRect, &dropAreaRect, CGRectGetHeight(temporaryRect)*(CGFloat)0.2, CGRectMinYEdge);
    } else {
        dropAreaRect = boundingBox;
    }
    
    CGRect dropAreaBounds = dropAreaRect;
    if (!dropZoneIsEmpty) {
        if ((dropZoneSize.width > dropAreaRect.size.width) || (dropZoneSize.height > dropAreaRect.size.height)) {
            dropZoneSize = SSSizeMakeWithAspectRatioInsideSize(dropZoneSize, dropAreaRect.size, SSRectResizingMethodScale);
        }
        
        dropAreaBounds = SSRectCenteredSize(dropAreaRect, dropZoneSize);
    }
    
    CGRect interiorBounds = CGRectInset(dropAreaBounds, lineDash, lineDash);
    CGPathRef path = SSPathCreateWithRoundedRect(CGRectIntegral(SSRectCenteredSize(interiorBounds, SSSizeMakeSquare(MIN(CGRectGetWidth(interiorBounds), CGRectGetHeight(interiorBounds))))), 6.0, NULL);
    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, CGRectGetHeight(bounds));
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetLineDash(ctx, 0.0, (const CGFloat[]){lineDash, lineDash}, 2);
    if (_shadowColor) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, _shadowColor);
    }
        
    if (_strokeColor) {
        CGContextSetStrokeColorWithColor(ctx, _strokeColor);
        CGContextStrokePath(ctx);
    }
    
    if (_label && _labelColor) {
#if TARGET_OS_IPHONE
        UIFont *font = [UIFont boldSystemFontOfSize:16];
#else
        NSFont *font = [NSFont boldSystemFontOfSize:16];
#endif
        CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
        SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)_label, CGRectIntegral(titleRect), kCTTextAlignmentCenter, (__bridge CTFontRef)font, _labelColor);
    }
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
}

#pragma mark getters & setters

- (CGColorRef)strokeColor {
    return _strokeColor;
}

- (void)setStrokeColor:(CGColorRef)strokeColor {
    SSRetainedTypeSet(_strokeColor, strokeColor);
    
    [self setNeedsDisplay];
}

- (CGColorRef)labelColor {
    return _labelColor;
}

- (void)setLabelColor:(CGColorRef)labelColor {
    SSRetainedTypeSet(_labelColor, labelColor);
    
    [self setNeedsDisplay];
}

- (CGColorRef)shadowColor {
    return _shadowColor;
}

- (void)setShadowColor:(CGColorRef)shadowColor {
    SSRetainedTypeSet(_shadowColor, shadowColor);
    
    [self setNeedsDisplay];
}

- (NSString *)label {
    return _label;
}

- (void)setLabel:(NSString *)label {
    SSNonAtomicCopiedSet(_label, label);
    
    [self setNeedsDisplay];
}

- (CGSize)dropZoneSize {
    return _dropZoneSize;
}

- (void)setDropZoneSize:(CGSize)dropZoneSize {
    _dropZoneSize = dropZoneSize;
    
    [self setNeedsDisplay];
}

@end
