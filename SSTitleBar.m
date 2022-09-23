//
//  SSTitleBar.m
//  SSAppKit
//
//  Created by Dante Sabatier on 25/02/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSTitleBar.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import "NSGradient+SSAdditions.h"
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSPath.h>
#import <SSGraphics/SSUtilities.h>

@implementation SSTitleBar

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareForInterfaceBuilder];
    }
    return self;
}

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    
#if !defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        _backgroundImage = [SSAppKitGetImageResourceNamed(@"backgroundPattern") copy];
#endif
    _backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.66 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.878 alpha:1.0], 1.0, nil];
    _alternateBackgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.878 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.976 alpha:1.0], 1.0, nil];
    _cornerRadius = 4.0;
    _rectCorners = SSRectTopCorners;
    [self setBorderColor:[NSColor colorWithCalibratedWhite:0.34117647058824 alpha:1.0] forEdge:NSMinYEdge];
}

- (void)drawRect:(NSRect)dirtyRect;
{
    [super drawRect:dirtyRect];
    
    CGRect bounds = self.bounds;
    bounds.size.height -= 1.0;
    bounds.origin.y += 1.0;
    
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = SSPathCreateWithRect(CGRectIntegral(bounds), self.rectCorners, self.cornerRadius, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat glowComponents[4] = {1.0, 1.0, 1.0, 0.16};
            CGColorRef glowColor = CGColorCreate(space, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {1.0, 1.0, 1.0, 1.0};
            CGColorRef innerShadowColor = CGColorCreate(space, innerShadowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, CGSizeMake(0, -1), 0, innerShadowColor);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
	CGColorSpaceRelease(space);
}

- (NSColor *)borderColorForEdge:(NSRectEdge)edge
{
    NSColor *color = [super borderColorForEdge:edge];
    if (color && !self.window.isActive && self.needsDisplayWhenWindowResignsKey)
        color = [NSColor colorWithCalibratedWhite:0.65490196078431 alpha:1.0];
    return color;
}

@end
