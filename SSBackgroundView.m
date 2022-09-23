//
//  SSBackgroundView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/28/12.
//
//

#import "SSBackgroundView.h"
#if TARGET_OS_IPHONE
#import <graphics/SSColor.h>
#import <graphics/SSPath.h>
#import <graphics/SSContext.h>
#else
#import <SSGraphics/SSColor.h>
#import <SSGraphics/SSPath.h>
#import <SSGraphics/SSContext.h>
#import "NSWindow+SSAdditions.h"
#endif

@interface SSBackgroundView ()

@end

@implementation SSBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidth = 0.0;
        _cornerRadius = 0.0;
        _rectCorners = 0;
        _fillColor = SSColorCreateDeviceGray(0.0, 0.0);
#if TARGET_OS_IPHONE
        self.opaque = NO;
        self.backgroundColor = nil;
#endif
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.borderWidth = [coder decodeFloatForKey:@"borderWidth"];
        self.cornerRadius = [coder decodeFloatForKey:@"cornerRadius"];
        self.rectCorners = (SSRectCorner)[coder decodeInt64ForKey:@"rectCorners"];
#if TARGET_OS_IPHONE
        self.opaque = NO;
        self.backgroundColor = nil;
#endif
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:self.borderWidth forKey:@"borderWidth"];
    [coder encodeFloat:self.cornerRadius forKey:@"cornerRadius"];
    [coder encodeInt64:self.rectCorners forKey:@"rectCorners"];
}

- (void)dealloc {
    CGColorRelease(_fillColor);
    CGColorRelease(_borderColor);
    
    [super ss_dealloc];
}

- (void)drawRect:(CGRect)dirtyRect {
    CGPathRef path = self.path;
    if (path) {
        CGContextRef ctx = SSContextGetCurrent();
        CGContextSaveGState(ctx);
        {
            CGColorRef fillColor = self.fillColor;
            if (fillColor) {
#if 0
                BOOL isActive = YES;
                BOOL needsDisplayWhenWindowResignsKey = YES;
                BOOL allowsVibrancy = NO;
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
                isActive = self.window.isActive;
                needsDisplayWhenWindowResignsKey = self.needsDisplayWhenWindowResignsKey;
#if defined(__MAC_10_10)
                if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                    allowsVibrancy = self.effectiveAppearance.allowsVibrancy;
                } 
#endif
#endif
                if ((needsDisplayWhenWindowResignsKey && !isActive) || (allowsVibrancy && !isActive)) {
                    fillColor = SSAutorelease(SSColorCreateDeviceGray(0.909804, 0.909804));
                }
#endif
                CGContextAddPath(ctx, path);
                CGContextClip(ctx);
                CGContextSetFillColorWithColor(ctx, fillColor);
                CGContextFillRect(ctx, CGPathGetBoundingBox(path));
            }
            
            if (_borderColor && isgreater(_borderWidth, 0.0)) {
                CGContextAddPath(ctx, path);
                CGContextSetStrokeColorWithColor(ctx, _borderColor);
                CGContextSetLineWidth(ctx, _borderWidth*self.scale);
                CGContextStrokePath(ctx);
            }
        }
        CGContextRestoreGState(ctx);
    }
}

#if !TARGET_OS_IPHONE

- (void)viewDidMoveToWindow {
    if (!self.window)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

#endif

#pragma getters & setters

- (CGPathRef)path {
    if (_fillColor || (_borderColor && isgreater(_borderWidth, 0.0)))
        return SSAutorelease(SSPathCreateWithRect(self.bounds, _rectCorners, _cornerRadius*self.scale, NULL));
    return NULL;
}

- (CGColorRef)borderColor {
    return _borderColor;
}

- (void)setBorderColor:(CGColorRef)borderColor {
    SSRetainedTypeSet(_borderColor, borderColor);
    
    [self setNeedsDisplay];
}

- (CGColorRef)fillColor {
    return _fillColor;
}

- (void)setFillColor:(CGColorRef)fillColor {
    SSRetainedTypeSet(_fillColor, fillColor);
    
    [self setNeedsDisplay];
}

- (CGFloat)borderWidth {
    return _borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    
    [self setNeedsDisplay];
}

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    
    [self setNeedsDisplay];
}

- (SSRectCorner)rectCorners {
    return _rectCorners;
}

- (void)setRectCorners:(SSRectCorner)rectCorners {
    if (_rectCorners == rectCorners) {
        return;
    }
    _rectCorners = rectCorners;
    [self setNeedsDisplay];
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
