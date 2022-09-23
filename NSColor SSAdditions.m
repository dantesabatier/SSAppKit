//
//  NSColor+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSColor+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <SSGraphics/SSImage.h>
#import <SSGraphics/SSColor.h>
#import <objc/objc-sync.h>

@implementation NSColor(SSAdditions)

+ (instancetype)sourceListViewBackgroundColor {
	return [NSColor colorWithCalibratedRed:0.839216 green:0.866667 blue:0.898039 alpha:1.0];
}

+ (instancetype)defaultAlternateSelectedControlColor {
    return [NSColor colorWithCalibratedRed:0.929 green:0.953 blue:0.996 alpha:1.0];
}

+ (instancetype)texturedHeaderTextColor {
    return [NSColor colorWithCalibratedRed:0.16 green:0.17 blue:0.18 alpha:1.0];
}

+ (instancetype)colorWithString:(NSString *)representation {
    CGColorRef CGColor = SSAutorelease(SSColorCreateWithString(representation));
    if (CGColor) {
        return [NSColor colorWithCGColor:CGColor];
    }
    return nil;
}

- (NSString *)stringRepresentation {
	return SSColorGetStringRepresentation(self.CGColor);
}

#if !DEBUG && (MAC_OS_X_VERSION_MIN_REQUIRED < 1080)

+ (instancetype)colorWithCGColor:(CGColorRef)cgColor {
    return [NSColor colorWithCIColor:[CIColor colorWithCGColor:cgColor]];
}

- (CGColorRef)CGColor {
    return SSColorGetCGColor(self);
}

#endif

- (NSString *)hexadecimalStringValue {
	return SSColorGetHexadecimalStringRepresentation(self.CGColor);
}

- (instancetype)contrastingLabelColor {
    NSColor *color = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (color) {
        return (((color.redComponent + color.greenComponent + color.blueComponent)/(CGFloat)3.0) >= 0.5) ? [NSColor blackColor] : [NSColor whiteColor];
    }
    return [NSColor blackColor];
}

//  Use this method to draw 1 px wide lines independent of scale factor. Handy for resolution independent drawing. Still needs some work - there are issues with drawing at the edges of views.
- (void)drawPixelThickLineAtPosition:(int)posInPixels withInset:(int)insetInPixels inRect:(CGRect)aRect inView:(NSView *)view horizontal:(BOOL)isHorizontal flip:(BOOL)shouldFlip {
	// Convert the given rectangle from points to pixels
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        aRect = [view convertRectToBacking:aRect];
    }
#else
    aRect = [view convertRectToBase:aRect];
#endif
	
	// Round up the rect's values to integers
	aRect = CGRectIntegral(aRect);
	
	// Add or subtract 0.5 so the lines are drawn within pixel bounds 
	if (isHorizontal) {
        if (view.flipped) {
            aRect.origin.y -= 0.5;
        } else {
            aRect.origin.y += 0.5;
        }
			
	} else {
		aRect.origin.x += 0.5;
	}
	
	CGSize sizeInPixels = aRect.size;
	
	// Convert the rect back to points for drawing
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        aRect = [view convertRectFromBacking:aRect];
    }
#else
    aRect = [view convertRectFromBase:aRect];
#endif
	
	// Flip the position so it's at the other side of the rect
	if (shouldFlip) {
        if (isHorizontal) {
            posInPixels = sizeInPixels.height - posInPixels - 1;
        } else {
            posInPixels = sizeInPixels.width - posInPixels - 1;
        }
	}
    
    CGFloat scale = view.scale;
	CGFloat posInPoints = posInPixels / scale;
	CGFloat insetInPoints = insetInPixels / scale;
	
	// Calculate line start and end points
	CGFloat startX, startY, endX, endY;
	
	if (isHorizontal) {
		startX = aRect.origin.x + insetInPoints;
		startY = aRect.origin.y + posInPoints;
		endX   = aRect.origin.x + aRect.size.width - insetInPoints;
		endY   = aRect.origin.y + posInPoints;
	} else {
		startX = aRect.origin.x + posInPoints;
		startY = aRect.origin.y + insetInPoints;
		endX   = aRect.origin.x + posInPoints;
		endY   = aRect.origin.y + aRect.size.height - insetInPoints;
	}
	
	// Draw line
	NSBezierPath *path = [NSBezierPath bezierPath];
	path.lineWidth = 0.0;
	[path moveToPoint:CGPointMake(startX,startY)];
	[path lineToPoint:CGPointMake(endX,endY)];
	[self set];
	[path stroke];
}

+ (instancetype)randomColor {
    return [NSColor colorWithHue:(arc4random() % 256/256.0) saturation:(( arc4random() % 128/256.0 ) + 0.5) brightness:((arc4random() % 128/256.0 ) + 0.5) alpha:1.0];
}

@end
