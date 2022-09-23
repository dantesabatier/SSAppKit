//
//  SSDarkSegmentedCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/8/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDarkSegmentedCell.h"
#import "NSSegmentedCell+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSDarkSegmentedCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [NSGraphicsContext saveGraphicsState];
    
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.33 alpha:0.16];
    shadow.shadowOffset = NSMakeSize(0, -1.0);
    shadow.shadowBlurRadius = 0.0;
    [shadow set];
    
    [super drawWithFrame:NSInsetRect(cellFrame, 1.0, 1.0) inView:controlView];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    
}

- (void)drawSegmentsWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSRect segmentRect = cellFrame;
    for (NSInteger segment = 0; segment < self.segmentCount; segment++) {
        segmentRect.size.width = [self widthForSegment:segment];
        
        [self drawSegment:segment inFrame:segmentRect withView:controlView];
        
        segmentRect.origin.x += NSWidth(segmentRect) + (NSWidth(segmentRect) ? 1.0 : 0.0);
    }
}

- (void)drawBackgroundForSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView;
{
    BOOL textured = NO;
    SSRectCorner corners = 0;
    switch (self.segmentStyle) {
        case NSSegmentStyleTexturedRounded:
        case NSSegmentStyleTexturedSquare: {
            if (self.segmentCount > 1) {
                if (segment == 0)
                    corners = SSRectLeftCorners;
                else if (segment == (self.segmentCount - 1))
                    corners = SSRectRightCorners;
            }
            textured = YES;
        }
            break;
            
        default:
            break;
    }
    
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = SSPathCreateWithRect(frame, corners, 3.0, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat borderColorComponents[4] = {0, 0, 0, 1.0};
            CGColorRef borderColor = CGColorCreate(colorSpace, borderColorComponents);
            CGContextSetStrokeColorWithColor(ctx, borderColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(borderColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        CGRect boundingBox = CGPathGetBoundingBox(path);
        
        NSGradient *backgroundGradient = [self backgroundGradientForSegment:segment];
        if (backgroundGradient) {
            CGGradientRef gradient = backgroundGradient.CGGradient;
            if (gradient) {
                CGPoint startPoint = CGPointZero;
                CGPoint endPoint = CGPointMake(0, CGRectGetMaxY(boundingBox));
                BOOL wantsShadow = textured && [self isSelectedForSegment:segment] && ![self isTrackingForSegment:segment];
                if (wantsShadow)
                    SWAP(startPoint, endPoint);
                
                CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
                
                if (wantsShadow) {
                    CGContextSaveGState(ctx);
                    {
                        CGContextAddPath(ctx, path);
                        const CGFloat holderInnerShadowComponents[] = {0.0, 0.0, 0.0, 1.0};
                        CGColorRef holderInnerShadowColor = CGColorCreate(colorSpace, holderInnerShadowComponents);
                        SSContextDrawInnerShadowWithColor(ctx, path, CGSizeMake(0, -1.0), 3.0, holderInnerShadowColor);
                        CGColorRelease(holderInnerShadowColor);
                    }
                    CGContextRestoreGState(ctx);
                }
            }
        }
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
            CGColorRef glowColor = CGColorCreate(colorSpace, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {0.92, 0.92, 0.92, 0.91};
            CGColorRef innerShadowColor = CGColorCreate(colorSpace, innerShadowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, CGSizeMake(0, -1), 0, innerShadowColor);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
	CGColorSpaceRelease(colorSpace);
}

- (void)drawImageForSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView
{
    NSImage *image = [self imageForSegment:segment];
	if (!image)
        return;
	
	NSSize imageSize = image.size;
	NSRect imageRect = CGRectIntegral(SSRectCenteredSize(frame, imageSize));
	
	NSRect fromRect = NSZeroRect;
	fromRect.size = imageSize;
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    context.imageInterpolation = NSImageInterpolationHigh;
    if (image.isTemplate)
        image = [image imageByTintingToColor:[NSColor whiteColor]];
    
    NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
    imageShadow.shadowOffset = NSMakeSize(0, -1.0);
    imageShadow.shadowColor = [NSColor blackColor];
    imageShadow.shadowBlurRadius = 1.0;
    [imageShadow set];
	
    CGFloat fraction = [self isEnabledForSegment:segment] ? 1.0 : 0.5;
    [image drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
    
    [context restoreGraphicsState];
}

- (void)drawSelectionForSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView;
{
    
}

- (NSDictionary *)labelAttributesForSegment:(NSInteger)segment;
{
    NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = [NSColor blackColor];
    titleShadow.shadowOffset = NSMakeSize(0, -1.0);
    titleShadow.shadowBlurRadius = 1.0;
	
	NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
	titleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
	titleAttributes[NSFontAttributeName] = self.font ? self.font : [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:self.controlSize]];
	titleAttributes[NSShadowAttributeName] = titleShadow;
	
	[titleShadow release];
	
	return titleAttributes;
}

- (NSGradient *)backgroundGradientForSegment:(NSInteger)segment
{
    BOOL isSelected = [self isSelectedForSegment:segment];
    NSGradient *backgroundGradient = nil;
    if ([self isTrackingForSegment:segment]) {
        if (isSelected)
            backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000] endingColor:[NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]] autorelease];
        else backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
    }
    else if (isSelected)
        backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
    else backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.220 alpha:1.000] endingColor:[NSColor colorWithCalibratedWhite:0.150 alpha:1.000]] autorelease];
    return backgroundGradient;
}

@end
