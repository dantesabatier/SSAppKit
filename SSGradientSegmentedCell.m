//
//  SSGradientSegmentedCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientSegmentedCell.h"
#import "NSSegmentedCell+SSAdditions.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSGradientSegmentedCell

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	[self drawBackgroundWithFrame:cellFrame inView:controlView];
	[self drawSegmentsWithFrame:cellFrame inView:controlView];
}

- (void)drawBackgroundWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    [[NSColor clearColor] set];
    NSRectFill(cellFrame);
}

- (void)drawSegmentsWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    CGRect segmentRect = NSInsetRect(cellFrame, 1.0, 1.0);
    for (NSInteger segment = 0; segment < self.segmentCount; segment++) {
        segmentRect.size.width = [self widthForSegment:segment];
        
        [self drawSegment:segment inFrame:segmentRect withView:controlView];
        
        segmentRect.origin.x += CGRectGetWidth(segmentRect) + (CGRectGetWidth(segmentRect) ? 1.0 : 0.0);
    }
}

- (void)drawSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
    if (NSIsEmptyRect(frame)) {
        [[NSColor clearColor] set];
        NSRectFill(frame);
        return;
    }
    
    [self drawBackgroundForSegment:segment inFrame:frame withView:controlView];
    [self drawSelectionForSegment:segment inFrame:frame withView:controlView];
    [self drawImageForSegment:segment inFrame:frame withView:controlView];
    [self drawLabelForSegment:segment inFrame:frame withView:controlView];
    [self drawArrowMenuForSegment:segment inFrame:frame withView:controlView];
}

- (void)drawBackgroundForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
    BOOL textured = NO;
    SSRectCorner corners = 0;
    switch (self.segmentStyle) {
        case NSSegmentStyleTexturedRounded:
        case NSSegmentStyleTexturedSquare: {
            if (/*self.segmentCount > 1*//* DISABLES CODE */ (false)) {
                if (segment == 0) {
                    corners = SSRectLeftCorners;
                } else if (segment == (self.segmentCount - 1)) {
                    corners = SSRectRightCorners;
                }
            }
            textured = YES;
        }
            break;
            
        default:
            break;
    }
    
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGPathRef path = SSPathCreateWithRect(frame, corners, 3.0, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat *borderColorComponents = SSColorGetRGBComponents(self.borderColor.CGColor);
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
                if (wantsShadow) {
                    SWAP(startPoint, endPoint);
                }
                
                CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
                
                if (wantsShadow) {
                    CGContextSaveGState(ctx);
                    {
                        CGContextAddPath(ctx, path);
                        CGColorRef holderInnerShadowColor = CGColorCreate(colorSpace, self.controlView.effectiveAppearanceIsDark ? (const CGFloat[]){0.0, 0.0, 0.0, 1.0} : (const CGFloat[]){1.0, 1.0, 1.0, 1.0});
                        SSContextDrawInnerShadowWithColor(ctx, path, holderInnerShadowColor, CGSizeMake(0, -1.0), 3.0);
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
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, CGSizeMake(0, -1), 0);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawSelectionForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
	if (!self.controlView.effectiveAppearanceIsDark && ([self isTrackingForSegment:segment] || [self isSelectedForSegment:segment])) {
		CGRect selectionRect = frame;
		selectionRect.size.width += 2.0;
		selectionRect.size.height += 2.0;
		selectionRect.origin.x -= 1.0;
		selectionRect.origin.y -= 1.0;
		
		NSShadow *interiorShadow = [[[NSShadow alloc] init] autorelease];
        if (controlView.window.isActive) {
            interiorShadow.shadowColor = [NSColor blackColor];
        } else {
            interiorShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
        }
        
		interiorShadow.shadowOffset = CGSizeMake(0, -CGRectGetHeight(selectionRect)/(CGFloat)50.0);
		interiorShadow.shadowBlurRadius = CGRectGetHeight(selectionRect)/(CGFloat)4.0;
		[[NSBezierPath bezierPathWithRect:selectionRect] applyInnerShadow:interiorShadow];
	}
}

- (void)drawImageForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
    NSImage *image = [self imageForSegment:segment];
    if (!image) {
        return;
    }
    
	CGSize imageSize = image.size;
	CGRect imageRect = SSRectCenteredSize(frame, imageSize);
	
	CGRect fromRect = CGRectZero;
	fromRect.size = imageSize;
#if defined(__MAC_10_7)
    [image drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:[self isEnabledForSegment:segment] ? 1.0 : 0.5 respectFlipped:YES hints:nil];
#else
    image.flipped = controlView.isFlipped;
    [image drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:[self isEnabledForSegment:segment] ? 1.0 : 0.5];
#endif
}

- (void)drawLabelForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
	NSString *label = [self labelForSegment:segment];
    if (!label) {
        return;
    }
    
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	NSDictionary *labelAttributes = [self labelAttributesForSegment:segment];
	CGRect labelRect = frame;
	labelRect.size = [label sizeWithAttributes:labelAttributes];
	labelRect.size.width = MIN(CGRectGetWidth(labelRect), MAX(CGRectGetMaxX(frame) - CGRectGetMinX(labelRect) - 10.0, 0));
    labelRect.origin = CGPointMake(FLOOR(NSMidX(frame) - (CGRectGetWidth(labelRect)*(CGFloat)0.5)), FLOOR(CGRectGetMidY(frame) - (CGRectGetHeight(labelRect)*(CGFloat)0.5)));
	
    [label drawWithRect:labelRect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:labelAttributes];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawArrowMenuForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
    if (![self menuForSegment:segment]) {
        return;
    }
    
	CGFloat x = CGRectGetMaxX(frame) - 2.0;
	CGFloat z = -3.0, y = CGRectGetMidY(frame);
	
	if (controlView.flipped) {
		y = CEIL(y) + 1.0;
		z = 3.0;
    } else {
        y = FLOOR(y) - 1.0;
    }
	
	NSBezierPath *arrowPath = [NSBezierPath bezierPath];
	[arrowPath moveToPoint:CGPointMake(x, y)];
	[arrowPath relativeLineToPoint:CGPointMake(-5.0, 0.0)];
	[arrowPath relativeLineToPoint:CGPointMake(2.5, z)];
	[arrowPath closePath];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8 * fraction] setFill];
	[arrowPath fill];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSDictionary *)labelAttributesForSegment:(NSInteger)segment {
    BOOL effectiveAppearanceIsDark = self.controlView.effectiveAppearanceIsDark;
	NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = effectiveAppearanceIsDark ? [NSColor blackColor] : [NSColor whiteColor];
    shadow.shadowOffset = CGSizeMake(0, -1.0);
    shadow.shadowBlurRadius = 1.0;
	
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
       attributes[NSForegroundColorAttributeName] = [NSColor labelColor];
    }
#else
    attributes[NSForegroundColorAttributeName] = [NSColor texturedHeaderTextColor];
#endif
	attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11.0];
	attributes[NSShadowAttributeName] = shadow;
	
	[shadow release];
	
	return attributes;
}

- (NSGradient *)backgroundGradientForSegment:(NSInteger)segment {
    if (self.controlView.effectiveAppearanceIsDark) {
        if ([self isTrackingForSegment:segment]) {
            if ([self isSelectedForSegment:segment]) {
                return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000] endingColor:[NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]] autorelease];
            } else {
                return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
            }
        } else if ([self isSelectedForSegment:segment]) {
            return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
        } else {
            return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.220 alpha:1.000] endingColor:[NSColor colorWithCalibratedWhite:0.150 alpha:1.000]] autorelease];
        }
    }
    
    if ([self isTrackingForSegment:segment]) {
        return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.82 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.79 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.73 alpha:1.0], 1.0, nil] autorelease];
    } else if ([self isSelectedForSegment:segment]) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.868235 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.761961 alpha:1.0], 1.0, nil] autorelease];
        } else {
            return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.86 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.86 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.83 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.76 alpha:1.0], 1.0, nil] autorelease];
        }
    }
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.988235 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.988235 alpha:1.0], 0.3, [NSColor colorWithCalibratedWhite:0.980392 alpha:1.0], 0.6, [NSColor colorWithCalibratedWhite:0.901961 alpha:1.0], 1.0, nil] autorelease];
    } else {
        return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.98 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.97 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.93 alpha:1.0], 0.45454, [NSColor colorWithCalibratedWhite:0.94 alpha:1.0], 1.0, nil] autorelease];
    }
}

- (NSColor *)borderColor {
    return self.controlView.effectiveAppearanceIsDark ? [NSColor blackColor] : [NSColor colorWithDeviceWhite:0.62352941176471 alpha:0.9];
}

- (NSColor *)backgroundColor {
    return nil;
}

@end
