//
//  SSBackButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 9/3/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSBackButtonCell.h"
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSUtilities.h>
#import <SSGraphics/SSColor.h>
#import "NSView+SSAdditions.h"

@implementation SSBackButtonCell

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	CGRect bounds = CGRectInset(cellFrame, 1.0, 1.0);
    
    if (self.isBordered) {
        [self drawBezelWithFrame:bounds inView:controlView];
    }
        
	[super drawWithFrame:bounds inView:controlView];
    [self drawImage:self.image withFrame:[self imageRectForBounds:bounds] inView:controlView];
}

- (void)drawBezelWithFrame:(CGRect)frame inView:(NSView *)controlView {
    CGRect bounds = CGRectInset(frame, 1.0, 1.0);
    CGFloat cornerRadius = 3.0;
    CGFloat arrowLength = (MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))*(CGFloat)0.5);
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, FLOOR(CGRectGetMinX(bounds) + arrowLength), CGRectGetMaxY(bounds));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    CGPathAddLineToPoint(path, NULL, FLOOR(CGRectGetMinX(bounds) + arrowLength), CGRectGetMinY(bounds));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMinY(bounds) + cornerRadius, cornerRadius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds) + CGRectGetHeight(bounds), CGRectGetMaxX(bounds) - cornerRadius, CGRectGetMinY(bounds) + CGRectGetHeight(bounds), cornerRadius);
    CGPathCloseSubpath(path);
    CGContextSaveGState(ctx);
    {
        CGColorRef shadowColor = NULL;
        if (self.controlView.effectiveAppearanceIsDark) {
            shadowColor = CGColorCreate(space, (const CGFloat[]){0.0, 0.0, 0.0, 0.16});
        } else if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            shadowColor = CGColorCreate(space, (const CGFloat[]){0.91, 0.91, 0.91, 0.16});
        } else {
            shadowColor = CGColorCreate(space, (const CGFloat[]){0.91, 0.91, 0.91, 0.8});
        }
        
        CGContextSetShadowWithColor(ctx, CGSizeMake(-1.0, -1.0), 0, shadowColor);
        CGColorRelease(shadowColor);
        
        CGContextSaveGState(ctx);
        {
            CGColorRef borderColor = NULL;
            if (self.controlView.effectiveAppearanceIsDark) {
                borderColor = CGColorCreate(space, (const CGFloat[]){0.0, 0.0, 0.0, 0.9});
            } else if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                borderColor = CGColorCreate(space, (const CGFloat[]){0.727, 0.727, 0.727, 0.9});
            } else {
                borderColor = CGColorCreate(space, (const CGFloat[]){0.336, 0.336, 0.336, 0.9});
            }
                
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                CGContextSetStrokeColorWithColor(ctx, borderColor);
                CGContextSetLineWidth(ctx, 2.0);
                CGContextStrokePath(ctx);
            }
            CGContextRestoreGState(ctx);
            CGColorRelease(borderColor);
            
            CGContextAddPath(ctx, path);
            CGContextClip(ctx);
            
            CGRect boundingBox = CGPathGetBoundingBox(path);
            CGPoint startPoint = CGPointZero;
            CGPoint endPoint = CGPointMake(0, CGRectGetMaxY(boundingBox));
            
            CGGradientRef backgroundGradient = NULL;
            if (self.controlView.effectiveAppearanceIsDark) {
                 backgroundGradient = CGGradientCreateWithColorComponents(space, self.isHighlighted ? (const CGFloat[]){0.220, 0.220, 0.220, 1.0, 0.240, 0.240, 0.240, 1.0} : (const CGFloat[]){0.200, 0.200, 0.200, 1.0, 0.220, 0.220, 0.220, 1.0}, (const CGFloat[]){1.0, 0.0}, 2);
            } else if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                 backgroundGradient = CGGradientCreateWithColorComponents(space, self.isHighlighted ? (const CGFloat[]){0.9, 0.9, 0.9, 1.0, 0.936, 0.936, 0.936, 1.0} : (const CGFloat[]){0.988235, 0.988235, 0.988235, 1.0, 1.0, 1.0, 1.0, 1.0}, (const CGFloat[]){1.0, 0.0}, 2);
            } else {
                backgroundGradient = CGGradientCreateWithColorComponents(space, self.isHighlighted ? (const CGFloat[]){1.0, 1.0, 1.0, 1.0, 0.670, 0.670, 0.670, 1.0} : (const CGFloat[]){0.727, 0.727, 0.727, 1.0, 0.829, 0.829, 0.829, 1.0, 0.936, 0.936, 0.936, 1.0, 0.983, 0.983, 0.983, 1.0}, self.isHighlighted ? (const CGFloat[]){1.0, 0.0} : (const CGFloat[]){1.0, 0.6, 0.3, 0.0}, self.isHighlighted ? 2 : 4);
            }
                
            CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
            CGContextDrawLinearGradient(ctx, backgroundGradient, startPoint, endPoint, 0);
            CGGradientRelease(backgroundGradient);
            
            const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
            CGColorRef glowColor = CGColorCreate(space, glowComponents);
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
                CGContextSetStrokeColorWithColor(ctx, glowColor);
                CGContextSetLineWidth(ctx, 2.0);
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
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
	CGColorSpaceRelease(space);
}

@end
