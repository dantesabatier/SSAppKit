//
//  SSTexturedSliderCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTexturedSliderCell.h"
#import "SSAppKitUtilities.h"
#import <SSBase/SSGeometry.h>

@implementation SSTexturedSliderCell

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    static const CGFloat imageSquareSize = 12.0;
	[self drawBarInside:cellFrame flipped:controlView.isFlipped];
	[self drawKnob:CGRectMake(FLOOR(((CGRectGetWidth(cellFrame)-imageSquareSize)/(self.maxValue-self.minValue))*(self.doubleValue-self.minValue)), FLOOR(CGRectGetMidY(cellFrame) - (imageSquareSize*(CGFloat)0.5)), imageSquareSize, imageSquareSize)];
}

- (void)drawBarInside:(CGRect)cellFrame flipped:(BOOL)flipped {
    CGSize imageSize = CGSizeMake(FLOOR(CGRectGetWidth(cellFrame) - 5.0), 6.0);
    CGRect bounds = CGRectMake(FLOOR(NSMidX(cellFrame) - (imageSize.width*(CGFloat)0.5)), FLOOR(CGRectGetMidY(cellFrame) - (imageSize.height*(CGFloat)0.5)), imageSize.width, imageSize.height);
    NSDrawThreePartImage(bounds, SSAppKitGetImageResourceNamed(@"trackCapLeft"), SSAppKitGetImageResourceNamed(@"trackFill"), SSAppKitGetImageResourceNamed(@"trackCapRight"), self.isVertical, NSCompositeSourceOver, 1.0, flipped);
}

- (void)drawKnob:(CGRect)rect {
    NSString *imageName = self.isHighlighted ? @"knobHover" : @"knobNormal";
	NSImage *image = SSAppKitGetImageResourceNamed(imageName);
    CGRect imageBounds = CGRectIntegral(SSRectCenteredSize(rect, image.size));
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    context.imageInterpolation = NSImageInterpolationHigh;
    [image drawInRect:imageBounds fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    [context restoreGraphicsState];
}

@end
