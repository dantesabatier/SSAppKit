//
//  SSGradientButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientButtonCell.h"
#import "NSColor+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSGradientButtonCell

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {	
	[NSGraphicsContext saveGraphicsState];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.91 alpha:0.16];
    shadow.shadowOffset = CGSizeMake(-1.0, -1.0);
    shadow.shadowBlurRadius = 0.0;
    [shadow set];
	
	CGRect bounds = CGRectInset(cellFrame, 1.0, 1.0);
    
    if (self.isBordered) {
        [self drawBezelWithFrame:bounds inView:controlView];
    }
        
	[super drawWithFrame:bounds inView:controlView];
    [self drawImage:self.image withFrame:[self imageRectForBounds:bounds] inView:controlView];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawBezelWithFrame:(CGRect)frame inView:(NSView *)controlView {
    CGRect bounds = CGRectInset(frame, 1.0, 1.0);
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = SSPathCreateWithRoundedRect(CGRectIntegral(bounds), self.cornerRadius, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGContextSetStrokeColorWithColor(ctx, self.borderColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        CGRect boundingBox = CGPathGetBoundingBox(path);
        
        CGColorRef backgroundColor = self.backgroundColor;
        if (backgroundColor) {
            CGContextSetFillColorWithColor(ctx, backgroundColor);
            CGContextFillRect(ctx, boundingBox);
        }
        
        CGGradientRef backgroundGradient = self.backgroundGradient;
        if (backgroundGradient) {
            CGPoint startPoint = CGPointZero;
            CGPoint endPoint = CGPointMake(0, CGRectGetMaxY(boundingBox));
            
            CGContextDrawLinearGradient(ctx, backgroundGradient, startPoint, endPoint, 0);
        }
        
        const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
        CGColorRef glowColor = CGColorCreate(space, glowComponents);
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextStrokePath(ctx);
        }
        CGContextRestoreGState(ctx);
        CGColorRelease(glowColor);
        
        const CGFloat innerShadowComponents[4] = {0.92, 0.92, 0.92, 0.91};
        CGColorRef innerShadowColor = CGColorCreate(space, innerShadowComponents);
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, CGSizeMake(0, -1), 0);
        }
        CGContextRestoreGState(ctx);
        CGColorRelease(innerShadowColor);
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
	CGColorSpaceRelease(space);
}

- (void)drawInteriorWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    NSString *title = self.title;
    if (!title.length) {
        return;
    }
    
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	[[NSGraphicsContext currentContext] saveGraphicsState];
    
    CGContextRef ctx = SSContextGetCurrent();
    if (!self.isEnabled) {
        CGContextSetAlpha(ctx, 0.5);
    }
    
	NSDictionary *titleAttributes = self.titleAttributes;
    CGRect baseRect = [self titleRectForBounds:cellFrame];
	CGRect titleRect = baseRect;
	titleRect.size = [title sizeWithAttributes:titleAttributes];
	titleRect.size.width = MIN(CGRectGetWidth(titleRect), MAX(CGRectGetMaxX(baseRect) - CGRectGetMinX(titleRect), 0));
	titleRect.origin.y = FLOOR(CGRectGetMidY(baseRect) - (CGRectGetHeight(titleRect)*(CGFloat)0.5));
    if (self.imagePosition == NSNoImage) {
        titleRect.origin.x = FLOOR(NSMidX(baseRect) - (CGRectGetWidth(titleRect)*(CGFloat)0.5));
    }
    
	[title drawInRect:titleRect withAttributes:titleAttributes];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

#pragma mark getters & setters

- (CGColorRef)borderColor {
    return self.controlView.effectiveAppearanceIsDark ? CGColorGetConstantColor(kCGColorBlack) : SSAutorelease(CGColorCreateGenericRGB(0.336, 0.336, 0.336, 0.9));
}

- (CGColorRef)backgroundColor {
    return NULL;
}

- (CGGradientRef)backgroundGradient {
    NSGradient *backgroundGradient = nil;
    if (self.controlView.effectiveAppearanceIsDark) {
        if (self.isHighlighted) {
            backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
        } else if (self.wantsBlueGradient) {
            backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000] endingColor:[NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]] autorelease];
        } else {
            backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.220 alpha:1.000] endingColor:[NSColor colorWithCalibratedWhite:0.150 alpha:1.000]] autorelease];
        }
    } else {
        if (self.controlView.window.isActive) {
            switch (self.bezelStyle) {
                case NSTexturedRoundedBezelStyle:
                case NSTexturedSquareBezelStyle: {
                    if (self.isHighlighted) {
                        backgroundGradient = [[[NSGradient alloc] initWithColors:@[[NSColor colorWithCalibratedWhite:0.670 alpha:1.0], [NSColor colorWithCalibratedWhite:1.0 alpha:1.0]]] autorelease];
                    } else {
                        backgroundGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.933 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.886 alpha:1.0], 0.3, [NSColor colorWithCalibratedWhite:0.729 alpha:1.0], 0.6, [NSColor colorWithCalibratedWhite:0.627 alpha:1.0], 1.0, nil] autorelease];
                    }
                }
                    break;
                default:
                    backgroundGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.988235 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.988235 alpha:1.0], 0.3, [NSColor colorWithCalibratedWhite:0.980392 alpha:1.0], 0.6, [NSColor colorWithCalibratedWhite:0.901961 alpha:1.0], 1.0, nil] autorelease];
                    break;
            }
        } else {
            backgroundGradient = [[[NSGradient alloc] initWithColors:@[[NSColor colorWithCalibratedWhite:0.965 alpha:1.0], [NSColor colorWithCalibratedWhite:0.855 alpha:1.0]]] autorelease];
        }
    }
    
    return backgroundGradient.CGGradient;
}

- (NSDictionary *)titleAttributes {
    BOOL effectiveAppearanceIsDark = self.controlView.effectiveAppearanceIsDark;
	NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = effectiveAppearanceIsDark ? [NSColor blackColor] : [NSColor whiteColor];
    titleShadow.shadowOffset = CGSizeMake(0, -1.0);
    titleShadow.shadowBlurRadius = 1.0;
	
	NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        titleAttributes[NSForegroundColorAttributeName] = [NSColor labelColor];
    }
#else
    titleAttributes[NSForegroundColorAttributeName] = [NSColor texturedHeaderTextColor];
#endif
	titleAttributes[NSFontAttributeName] = self.font ? self.font : [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:self.controlSize]];
	titleAttributes[NSShadowAttributeName] = titleShadow;
	
	[titleShadow release];
	
	return titleAttributes;
}

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
}

- (BOOL)wantsBlueGradient {
    BOOL ok = NO;
    NSButtonType buttonType = SSButtonCellGetType(self);
    switch (buttonType) {
        case NSSwitchButton: {
            switch (self.state) {
                case NSOnState:
                case NSMixedState:
                    ok = YES;
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            ok = [self.keyEquivalent isEqualToString:@"\r"];
            break;
    }
    return ok;
}

@end

NSButtonType SSButtonCellGetType(NSButtonCell *self) {
    return (NSButtonType)[[self valueForKey:@"buttonType"] unsignedIntegerValue];
}
