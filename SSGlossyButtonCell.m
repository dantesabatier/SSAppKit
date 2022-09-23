//
//  SSGlossyButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/12.
//
//

#import "SSGlossyButtonCell.h"

#import "CoreGraphics+SSAdditions.h"

@implementation SSGlossyButtonCell

- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    CGContextRef ctx = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGPathRef path = SSPathCreateWithRect(CGRectIntegral(CGRectInset(frame, 1, 1)), NULL, kSSRectAllCorners, self.cornerRadius);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat strokeComponents[4] = {0.1, 0.1, 0.1, 0.06};
            CGColorRef strokeColor = CGColorCreate(colorSpace, strokeComponents);
            CGContextSetStrokeColorWithColor(ctx, strokeColor);
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextStrokePath(ctx);
            CGColorRelease(strokeColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        SSContextDrawGlossGradient(ctx, CGPathGetBoundingBox(path), false);
        
        // Draw glow
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat glowComponents[4] = {0.92f, 0.92f, 0.92f, 0.16f};
            CGColorRef glowColor = CGColorCreate(colorSpace, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        // Draw inner shadow
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {0.92f, 0.92f, 0.92f, 0.86f};
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

- (NSDictionary *)titleAttributes;
{
	NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = [NSColor blackColor];
    titleShadow.shadowOffset = NSMakeSize(0, -1.0);
    titleShadow.shadowBlurRadius = 1.0f;
	
	NSMutableDictionary *titleAttributes = [NSMutableDictionary dictionary];
	[titleAttributes setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	[titleAttributes setValue:self.font ? self.font : [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:self.controlSize]] forKey:NSFontAttributeName];
	[titleAttributes setValue:titleShadow forKey:NSShadowAttributeName];
	
	[titleShadow release];
	
	return titleAttributes;
}

@end
