//
//  NSSearchFieldCell+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 07/11/14.
//
//

#import "NSSearchFieldCell+SSAdditions.h"
#import <SSBase/SSDefines.h>

@implementation NSSearchFieldCell (SSAdditions)

- (NSImage *)searchButtonCellImage {
    NSImage *image = [[NSImage alloc] initWithSize:CGSizeMake(14, 14)];
    [image lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(CGRectMake(0, 0, 14, 14));
    
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.33];
    shadow.shadowOffset = CGSizeMake(0, 1.0);
    shadow.shadowBlurRadius = 1.0;
    
    NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:CGRectMake(1, 4, 8, 8)];
    path.lineWidth = 1.9;
    [path moveToPoint:CGPointMake(7, 6)];
    [path lineToPoint:CGPointMake(12, 1)];
    [shadow set];
    [self.textColor set];
    [path stroke];
    [image unlockFocus];
    return [image autorelease];
}

- (NSImage *)cancelButtonCellImage {
    NSImage *image = [[NSImage alloc] initWithSize:CGSizeMake(14, 14)];
    [image lockFocus];
    [[NSColor clearColor] set];
    NSRectFill(CGRectMake(0, 0, 14, 14));
    
    [[[self.textColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] colorWithAlphaComponent:0.16] set];
    [[NSBezierPath bezierPathWithOvalInRect:CGRectMake(1, 1, 12, 12)] fill];
    
    NSBezierPath *cross = [NSBezierPath bezierPath];
    cross.lineWidth = 1.1;
    [cross moveToPoint:CGPointMake(4, 4)];
    [cross lineToPoint:CGPointMake(10, 10)];
    [cross moveToPoint:CGPointMake(4, 10)];
    [cross lineToPoint:CGPointMake(10, 4)];
    [[[self.textColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] colorWithAlphaComponent:0.8] set];
    [cross stroke];
    
    [image unlockFocus];
    return [image autorelease];
}

@end
