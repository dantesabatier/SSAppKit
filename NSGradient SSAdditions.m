//
//  NSGradient+SSAdditions.m
//  LabelTest
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSGradient+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <SSGraphics/SSGradient.h>
#import <SSFoundation/NSString+SSAdditions.h>

@implementation NSGradient(SSAdditions)

+ (instancetype)tableHeaderViewBackgroundGradientAsKey:(BOOL)isKey {
    if (isKey) {
        return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.41 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.65 alpha:1.0], 0.1, [NSColor colorWithCalibratedWhite:0.69 alpha:1.0], 0.4, [NSColor colorWithCalibratedWhite:0.82 alpha:1.0], 0.6, [NSColor colorWithCalibratedWhite:0.95 alpha:1.0], 0.85, [NSColor colorWithCalibratedWhite:0.98 alpha:1.0], 1.0, nil] autorelease];
    }
    return [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.69 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.855 alpha:1.0], 0.1, [NSColor colorWithCalibratedWhite:0.965 alpha:1.0], 0.9, [NSColor colorWithCalibratedWhite:0.98 alpha:1.0], 1.0, nil] autorelease];
}

+ (instancetype)sourceListBackgroundGradientAsKey:(BOOL)isKey {
    if (isKey) {
        return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.68627450980392 green:0.72156862745098 blue:0.78039215686275 alpha:1.0] endingColor:[NSColor colorWithCalibratedRed:0.8156862745098 green:0.84313725490196 blue:0.89019607843137 alpha:1.0]] autorelease];
    }
        
    return [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.73333333333333 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.85882352941176 alpha:1.0]] autorelease];
}

+ (instancetype)gradientWithBaseColor:(NSColor *)color {
	return [[[NSGradient alloc] initWithStartingColor:[[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] highlightWithLevel:0.6] endingColor:[[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] shadowWithLevel:0.1]] autorelease];
}

+ (instancetype)gradientByGettingColorsFromImage:(NSImage *)image {
	return [self gradientByGettingColorsFromImage:image vertically:YES];
}

+ (instancetype)gradientByGettingColorsFromImage:(NSImage *)image vertically:(BOOL)flag {
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
	NSMutableArray *colors = [NSMutableArray array];
	NSInteger count = flag ? imageRep.pixelsHigh : imageRep.pixelsWide;
	for (NSInteger i = 0; i < count; i++) {
        NSColor *color = [imageRep colorAtX:(flag ? 0 : i) y:(flag ? i : 0)];
        if (color) {
            [colors addObject:color];
        }
    }
    
	return [[[NSGradient alloc] initWithColors:colors] autorelease];
}

- (CGGradientRef)CGGradient {
    NSInteger count = self.numberOfColorStops;
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:count];
    CGFloat *locations = malloc(count*sizeof(CGFloat));
    for (NSInteger i = 0; i < count; i++) {
        NSColor *nscolor = nil;
        CGFloat location;
        [self getColor:&nscolor location:&location atIndex:i];
        
        if (nscolor) {
            CGColorRef color = nscolor.CGColor;
            if (color) {
                [colors addObject:(__bridge id)color];
                locations[i] = location;
            }
        }
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace.CGColorSpace, (__bridge CFArrayRef)colors, locations);
    free(locations);
    return SSAutorelease(gradient);
}

@end
