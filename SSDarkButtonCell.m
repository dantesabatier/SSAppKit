//
//  SSDarkButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 5/1/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDarkButtonCell.h"
#import "NSGradient+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSDarkButtonCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.cornerRadius = 3.5;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cornerRadius = 3.5;
    }
    return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[NSGraphicsContext saveGraphicsState];
	
	NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.33 alpha:0.16];
    shadow.shadowOffset = NSMakeSize(0, -1.0);
    shadow.shadowBlurRadius = 0.0;
    [shadow set];
	
	CGRect bounds = CGRectInset(cellFrame, 1.0, 1.0);
    
    if (self.isBordered)
        [self drawBezelWithFrame:bounds inView:controlView];
    [self drawInteriorWithFrame:cellFrame inView:controlView];
    if (self.image)
        [self drawImage:self.image withFrame:[self imageRectForBounds:bounds] inView:controlView];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSButtonType buttonType = SSButtonCellGetType(self);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    {
        if (buttonType == NSSwitchButton) {
            CGRect boundingBox = CGRectInset(frame, 1.0, 1.0);
            
            [self drawBezelWithFrame:boundingBox inView:controlView];
            
            if (self.state != NSOffState) {
                CGMutablePathRef path = CGPathCreateMutable();
                CGRect interiorBounds = CGRectInset(boundingBox, NSWidth(boundingBox)*0.25, NSHeight(boundingBox)*0.25);
                if (self.state == NSMixedState) {
                    CGPathMoveToPoint(path, NULL, NSMinX(interiorBounds), NSMidY(interiorBounds));
                    CGPathAddLineToPoint(path, NULL, NSMaxX(interiorBounds), NSMidY(interiorBounds));
                } else {
                    CGPathMoveToPoint(path, NULL, NSMinX(interiorBounds), FLOOR(NSMaxY(interiorBounds) - (NSHeight(interiorBounds)*0.25)));
                    CGPathAddLineToPoint(path, NULL, NSMidX(interiorBounds), NSMaxY(interiorBounds));
                    CGPathAddLineToPoint(path, NULL, NSMaxX(interiorBounds), NSMinY(interiorBounds));
                }
                
                CGContextSaveGState(ctx);
                {
                    const CGFloat borderColorComponents[4] = {0.780, 0.780, 0.780, 1.0};
                    CGColorRef borderColor = CGColorCreate(space, borderColorComponents);
                    const CGFloat shadowComponents[4] = {0.0, 0.0, 0.0, 0.750};
                    CGColorRef shadowColor = CGColorCreate(space, shadowComponents);
                    
                    CGContextAddPath(ctx, path);
                    CGContextSetStrokeColorWithColor(ctx, borderColor);
                    CGContextSetLineWidth(ctx, 2.0);
                    CGContextSetShadowWithColor(ctx, CGSizeZero, 3.0, shadowColor);
                    CGContextStrokePath(ctx);
                    
                    CGColorRelease(borderColor);
                    CGColorRelease(shadowColor);
                }
                CGContextRestoreGState(ctx);
                CGPathRelease(path);
            }
        } else {
            if (image) {
                NSSize imageSize = image.size;
                NSRect imageRect = SSRectCenteredSize(frame, imageSize);
                
                NSRect fromRect = NSZeroRect;
                fromRect.size = imageSize;
                
                NSGraphicsContext *context = [NSGraphicsContext currentContext];
                [context saveGraphicsState];
                context.imageInterpolation = NSImageInterpolationHigh;
                if (image.isTemplate)
                    image = [image imageByTintingToColor:[NSColor whiteColor]];
                
                NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
                imageShadow.shadowOffset = NSMakeSize(0, - 1.0);
                imageShadow.shadowColor = [NSColor blackColor];
                imageShadow.shadowBlurRadius = 1.0;
                [imageShadow set];
                
                [image drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
                
                [context restoreGraphicsState];
            }
        }
    }
    CGContextRestoreGState(ctx);
    CGColorSpaceRelease(space);
}

#pragma mark getters & setters

- (BOOL)wantsBlueGradient
{
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

- (CGColorRef)borderColor;
{
    return CGColorGetConstantColor(kCGColorBlack);
}

- (CGGradientRef)backgroundGradient
{
    NSGradient *backgroundGradient = nil;
    if (self.isHighlighted)
        backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.36 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.26 alpha:1.0]] autorelease];
    else if (self.wantsBlueGradient)
        backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceRed:0.000 green:0.530 blue:0.870 alpha:1.000] endingColor:[NSColor colorWithDeviceRed:0.000 green:0.310 blue:0.780 alpha:1.000]] autorelease];
    else backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.220 alpha:1.000] endingColor:[NSColor colorWithCalibratedWhite:0.150 alpha:1.000]] autorelease];
    
    return backgroundGradient.CGGradient;
}

- (NSDictionary *)titleAttributes;
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

@end
