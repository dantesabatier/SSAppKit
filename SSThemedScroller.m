//
//  SSThemedScroller.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSThemedScroller.h"
#import "NSScroller+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import "NSView+SSAdditions.h"

@implementation SSThemedScroller

+ (BOOL)isCompatibleWithOverlayScrollers {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_theme release];
    
    CGColorRelease(_backgroundColor);
    
    [super ss_dealloc];
}

- (void)drawKnobSlotInRect:(CGRect)slotRect highlight:(BOOL)flag {
    CGColorRef backgroundColor = self.backgroundColor;
    if (!self.isThemed || !backgroundColor) {
        [super drawKnobSlotInRect:slotRect highlight:flag];
        return;
    }
    
    if (![NSGraphicsContext currentContext].drawingToScreen) {
        return;
    }
    
    BOOL isVertical = self.isVertical;
    BOOL isOverlaid = self.isOverlaid;
    BOOL isOutsideControl = self.isOutsideControl;
    
    CGRect bounds = slotRect;
    if (isOutsideControl && !isVertical && !isOverlaid) {
        bounds.origin.y += 1.0;
        bounds.size.height -= 2.0;
    }
    
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = SSPathCreateWithRoundedRect(bounds, MIN(bounds.size.width, bounds.size.height)*(CGFloat)0.5, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            if (!isOutsideControl && !isOverlaid) {
                CGContextSetFillColorWithColor(ctx, backgroundColor);
                CGContextFillRect(ctx, self.bounds);
            }
#if 0
            CGContextAddPath(ctx, path);
            CGContextClip(ctx);
            
            CGContextSetFillColorWithColor(ctx, backgroundColor);
            CGContextFillRect(ctx, bounds);
#endif
        }
        CGContextRestoreGState(ctx);
        
        CGSize shadowOffset = isVertical ? CGSizeMake(1, 0) : CGSizeMake(0, -1);
        CGContextSaveGState(ctx);
        {
            const CGFloat dropShadowComponents[4] = {0.91, 0.91, 0.91, 0.16};
            CGColorRef dropShadowColor = CGColorCreate(colorSpace, dropShadowComponents);
            CGContextSetShadowWithColor(ctx, shadowOffset, 0, dropShadowColor);
			CGColorRelease(dropShadowColor);
            
            CGContextBeginTransparencyLayer(ctx, NULL);
            {
                CGContextAddPath(ctx, path);
                CGContextClip(ctx);
                
                const CGFloat backgroundGradientComponents[8] = {0, 0, 0, 0.33, 0, 0, 0, 0};
                CGFloat backgroundGradientLocations[2] = {1, 0};
                CGGradientRef backgroundGradient = CGGradientCreateWithColorComponents(colorSpace, backgroundGradientComponents, backgroundGradientLocations, 2);
                const CGFloat shadowColorComponents[4] = {0.16, 0.16, 0.16, 0.16};
                CGColorRef shadowColor = CGColorCreate(colorSpace, shadowColorComponents);
                
                CGContextSaveGState(ctx);
                {
                    CGContextSetFillColorWithColor(ctx, shadowColor);
                    CGContextFillRect(ctx, bounds);
                    CGPoint startPoint = isVertical ? CGPointMake(CGRectGetMaxX(bounds), 0) : CGPointMake(0, CGRectGetMaxY(bounds));
                    CGPoint endPoint = CGPointZero;
#if TARGET_INTERFACE_BUILDER
                    if (!isVertical) {
                        SWAP(startPoint, endPoint);
                    }
#else
                    // FIXME: commented because it does not work on 10.12
                    if (/*kSSUsesOldGeometry && */!isVertical) {
                        SWAP(startPoint, endPoint);
                    }
#endif
                    CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
					CGContextDrawLinearGradient(ctx, backgroundGradient, startPoint, endPoint, 0);
                }
                CGContextRestoreGState(ctx);
				CGColorRelease(shadowColor);
				CGGradientRelease(backgroundGradient);
            }
            CGContextEndTransparencyLayer(ctx);
        }
        CGContextRestoreGState(ctx);
		
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {0, 0, 0, 1.0};
            CGColorRef holderInnerShadowColor = CGColorCreate(colorSpace, innerShadowComponents); 
            SSContextDrawInnerShadowWithColor(ctx, path, holderInnerShadowColor, shadowOffset, 3);
            CGColorRelease(holderInnerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawKnob {
    CGColorRef backgroundColor = self.backgroundColor;
    if (!self.isThemed || !backgroundColor) {
        [super drawKnob];
        return;
    }
    
    if (![NSGraphicsContext currentContext].drawingToScreen || (self.usableParts != NSAllScrollerParts)) {
        return;
    }
    
    BOOL isOutsideControl = self.isOutsideControl;
    if (isOutsideControl && (self.knobProportion >= 1.0)) {
        return;
    }
    
    BOOL isVertical = self.isVertical;
    BOOL isOverlaid = self.isOverlaid;
    
	CGRect bounds = CGRectInset([self rectForPart:NSScrollerKnob], 1.0, 1.0);
    if (isOutsideControl) {
        if (!isVertical) {
            bounds.origin.y += 1.0;
            bounds.size.height -= 2.0;
        }
    } else if (!isOverlaid) {
        bounds = CGRectInset(bounds, 1.0, 1.0);
    }
    
    CGFloat scale = self.scale;
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = SSPathCreateWithRoundedRect(bounds, MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))*(CGFloat)0.5, NULL);
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat strokeComponents[4] = {0.306, 0.306, 0.306, 0.6};
            CGColorRef strokeColor = CGColorCreate(colorSpace, strokeComponents);
            CGContextSetStrokeColorWithColor(ctx, strokeColor);
            CGContextSetLineWidth(ctx, 1.0*scale);
            CGContextStrokePath(ctx);
            CGColorRelease(strokeColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGRect boundingBox = CGPathGetBoundingBox(path);
        
        CGContextSetFillColorWithColor(ctx, backgroundColor);
        CGContextFillRect(ctx, boundingBox);
       
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
            CGColorRef glowColor = CGColorCreate(colorSpace, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 1.0*scale);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {0.92, 0.92, 0.92, 0.86};
            CGColorRef innerShadowColor = CGColorCreate(colorSpace, innerShadowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, isVertical ? CGSizeMake(1, 0) : CGSizeMake(0, -1), 0);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
    CGColorSpaceRelease(colorSpace);
	CGPathRelease(path);
}

- (void)drawRect:(CGRect)rect {
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [super drawRect:rect];
    } else if (!self.isThemed) {
        [super drawRect:rect];
    } else if (self.knobProportion < 1.0) {
        [self drawKnobSlotInRect:[self rectForPart:NSScrollerKnobSlot] highlight:NO];
        [self drawKnob];
    }
}

#pragma mark getters & setters

- (CGColorRef)backgroundColor {
    if (!_backgroundColor) {
        id <SSTheme> theme = self.theme;
        if (theme) {
            id scrollerBackgroundImage = theme.scrollerBackgroundImage;
            if (scrollerBackgroundImage) {
                CGImageRef backgroundImage = SSImageGetCGImage(scrollerBackgroundImage);
                CGImageRef image = NULL;
                if (self.isVertical) {
                    image = SSImageCreateRotatedClockwiseByAngle(backgroundImage, 90);
                } else {
                    image = CGImageCreateCopy(backgroundImage);
                }
                
                if (image) {
                    _backgroundColor = SSColorCreateWithPatternImage(image, self.scale);
                }
            }
        }
    }
    return _backgroundColor;
}

- (void)setBackgroundColor:(CGColorRef)backgroundColor {
    SSRetainedTypeSet(_backgroundColor, backgroundColor);
    
    [self setNeedsDisplay];
}

- (id<SSTheme>)theme {
    if (!_theme) {
        NSView *view = self.superview;
        if ([view isKindOfClass:[NSScrollView class]])
            view = ((NSScrollView *)view).documentView;
        if ([view conformsToProtocol:@protocol(SSThemedView)])
            _theme = [((id <SSThemedView>)view).theme ss_retain];
    }
    return _theme;
}

- (void)setTheme:(id<SSTheme>)theme {
    if ([_theme isEqual:theme])
        return;
    
    SSNonAtomicRetainedSet(_theme, theme);
    
    self.backgroundColor = NULL;
}

- (BOOL)isThemed {
#if 1
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        return YES;
#endif
    return self.isOverlaid || self.isOutsideControl;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
