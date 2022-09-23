//
//  SSDarkPopUpButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/28/12.
//
//

#import "SSDarkPopUpButtonCell.h"
#import "NSGradient+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import <SSGraphics/SSUtilities.h>
#import <SSGraphics/SSPath.h>
#import <SSGraphics/SSContext.h>

@implementation SSDarkPopUpButtonCell

- (void)drawTitleWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSString *title = self.title;
	if (!title.length) return;
	
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	[[NSGraphicsContext currentContext] saveGraphicsState];
    
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    if (!self.isEnabled)
        CGContextSetAlpha(ctx, 0.5);
	
	NSShadow *titleShadow = [[[NSShadow alloc] init] autorelease];
    titleShadow.shadowColor = [NSColor blackColor];
    titleShadow.shadowOffset = NSMakeSize(0, 1.0);
    titleShadow.shadowBlurRadius = 1.0;
	
	NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
	titleAttributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
	titleAttributes[NSFontAttributeName] = self.font ? self.font : [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:self.controlSize]];
	titleAttributes[NSShadowAttributeName] = titleShadow;
    
	[title drawWithRect:[self titleRectForBounds:cellFrame] options:NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:titleAttributes];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawBorderAndBackgroundWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    CGRect bounds = CGRectInset(cellFrame, 2.0, 2.0);
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = SSPathCreateWithRoundedRect(CGRectIntegral(bounds), 3.0, NULL);
    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGContextSaveGState(ctx);
    {
        if (!self.isEnabled)
            CGContextSetAlpha(ctx, 0.5);
        if (self.isBordered) {
            const CGFloat shadowComponents[4] = {0.33, 0.33, 0.33, 0.16};
            CGColorRef shadowColor = CGColorCreate(space, shadowComponents);
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, shadowColor);
            CGColorRelease(shadowColor);
            
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
            
            CGGradientRef backgroundGradient = self.backgroundGradient;
            if (backgroundGradient) {
                CGPoint startPoint = CGPointZero;
                CGPoint endPoint = CGPointMake(0, CGRectGetMaxY(boundingBox));
                
                //if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) SWAP(startPoint, endPoint);
                
                CGContextDrawLinearGradient(ctx, backgroundGradient, startPoint, endPoint, 0);
            }
            
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
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
                const CGFloat innerShadowComponents[4] = {0.92, 0.92, 0.92, 0.91};
                CGColorRef innerShadowColor = CGColorCreate(space, innerShadowComponents);
                CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
                SSContextDrawInnerShadowWithColor(ctx, path, CGSizeMake(0, -1), 0, innerShadowColor);
                CGColorRelease(innerShadowColor);
            }
            CGContextRestoreGState(ctx);
        }
        
        if (self.arrowPosition != NSPopUpNoArrow) {
            CGColorRef arrowColor = CGColorCreate(space, (const CGFloat[]){0.92, 0.92, 0.92, 0.91});
            CGColorRef arrowShadowColor = CGColorCreate(space, (const CGFloat[]){0.0, 0.0, 0.0, 1.0});
            if (self.pullsDown) {
                CGRect arrowRect = CGRectZero;
                arrowRect.size = CGSizeMake(8.0, 5.0);
                arrowRect.origin = CGPointMake(FLOOR(CGRectGetMaxX(boundingBox) - (CGRectGetWidth(arrowRect)*(CGFloat)2.0)), FLOOR(CGRectGetMidY(boundingBox) - (CGRectGetHeight(arrowRect)*(CGFloat)0.5)));
                
                CGMutablePathRef arrowPath = CGPathCreateMutable();
                CGPathMoveToPoint(arrowPath, NULL, CGRectGetMidX(arrowRect), CGRectGetMaxY(arrowRect));
                CGPathAddLineToPoint(arrowPath, NULL, CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect));
                CGPathAddLineToPoint(arrowPath, NULL, CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect));
                CGPathCloseSubpath(arrowPath);
                
                CGContextSaveGState(ctx);
                {
                    CGContextAddPath(ctx, arrowPath);
                    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 1.0, arrowShadowColor);
                    CGContextSetFillColorWithColor(ctx, arrowColor);
                    CGContextFillPath(ctx);
                }
                CGContextRestoreGState(ctx);
                CGPathRelease(arrowPath);
            } else {
                CGRect topArrowRect = CGRectZero;
                topArrowRect.size = CGSizeMake(6.0, 4.0);
                topArrowRect.origin = CGPointMake(FLOOR(CGRectGetMaxX(boundingBox) - (CGRectGetWidth(topArrowRect)*(CGFloat)2.0)), FLOOR(CGRectGetMidY(boundingBox) - (CGRectGetHeight(topArrowRect)*(CGFloat)1.5)));
                
                CGMutablePathRef topArrowPath = CGPathCreateMutable();
                CGPathMoveToPoint(topArrowPath, NULL, CGRectGetMidX(topArrowRect), CGRectGetMinY(topArrowRect));
                CGPathAddLineToPoint(topArrowPath, NULL, CGRectGetMinX(topArrowRect), CGRectGetMaxY(topArrowRect));
                CGPathAddLineToPoint(topArrowPath, NULL, CGRectGetMaxX(topArrowRect), CGRectGetMaxY(topArrowRect));
                CGPathCloseSubpath(topArrowPath);
                
                CGContextSaveGState(ctx);
                {
                    CGContextAddPath(ctx, topArrowPath);
                    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 1.0, arrowShadowColor);
                    CGContextSetFillColorWithColor(ctx, arrowColor);
                    CGContextFillPath(ctx);
                }
                CGContextRestoreGState(ctx);
                CGPathRelease(topArrowPath);
                
                CGRect botomArrowRect = topArrowRect;
                botomArrowRect.origin = CGPointMake(FLOOR(CGRectGetMaxX(boundingBox) - (CGRectGetWidth(topArrowRect)*(CGFloat)2.0)), FLOOR(CGRectGetMidY(boundingBox) + (CGRectGetHeight(topArrowRect)*(CGFloat)0.5)));
                
                CGMutablePathRef bottomArrowPath = CGPathCreateMutable();
                CGPathMoveToPoint(bottomArrowPath, NULL, CGRectGetMidX(botomArrowRect), CGRectGetMaxY(botomArrowRect));
                CGPathAddLineToPoint(bottomArrowPath, NULL, CGRectGetMinX(botomArrowRect), CGRectGetMinY(botomArrowRect));
                CGPathAddLineToPoint(bottomArrowPath, NULL, CGRectGetMaxX(botomArrowRect), CGRectGetMinY(botomArrowRect));
                CGPathCloseSubpath(bottomArrowPath);
                
                CGContextSaveGState(ctx);
                {
                    CGContextAddPath(ctx, bottomArrowPath);
                    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 1.0, arrowShadowColor);
                    CGContextSetFillColorWithColor(ctx, arrowColor);
                    CGContextFillPath(ctx);
                }
                CGContextRestoreGState(ctx);
                CGPathRelease(bottomArrowPath);
            }
            
            CGColorRelease(arrowColor);
            CGColorRelease(arrowShadowColor);
        }
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
	CGColorSpaceRelease(space);
}

- (void)drawImageWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
{
    NSImage *image = self.image;
    if (image.isTemplate)
        image = [image imageByTintingToColor:[NSColor whiteColor]];
    
    NSRect bounds = NSInsetRect(cellFrame, 2.0, 2.0);
    NSRect imageRect = [self imageRectForBounds:bounds];
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    context.imageInterpolation = NSImageInterpolationHigh;
    
    NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
    imageShadow.shadowOffset = NSMakeSize(0, - 1.0);
    imageShadow.shadowColor = [NSColor blackColor];
    imageShadow.shadowBlurRadius = 1.0;
    [imageShadow set];
    
    [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:self.isEnabled ? 1.0 : 0.5 respectFlipped:YES hints:nil];
    
    [context restoreGraphicsState];
}

- (CGColorRef)borderColor;
{
    return CGColorGetConstantColor(kCGColorBlack);
}

- (CGGradientRef)backgroundGradient
{
    NSGradient *backgroundGradient = nil;
    if (self.isHighlighted) backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
	else backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.220 alpha:1.000] endingColor:[NSColor colorWithCalibratedWhite:0.150 alpha:1.000]] autorelease];
    
    return backgroundGradient.CGGradient;
}

@end
