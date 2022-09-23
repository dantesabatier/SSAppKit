//
//  SSDarkImageCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 04/12/12.
//
//

#import "SSDarkImageCell.h"
#import "NSImage+SSAdditions.h"

@implementation SSDarkImageCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSImage *image = self.image;
    if (image) {
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        
        context.imageInterpolation = NSImageInterpolationHigh;
        
        NSRect imageRect = [self imageRectForBounds:NSInsetRect(cellFrame, 1.0, 1.0)];
        if (SSSizeIsGreaterThanSize(image.size, imageRect.size))
            image = [image imageByScalingToSize:imageRect.size];
        
        if (image.isTemplate) image = [image imageByTintingToColor:[NSColor whiteColor]];
        
        NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
        imageShadow.shadowOffset = NSMakeSize(0.0, -1.0);
        imageShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.5];
        [imageShadow set];
        
        [image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
        
        [context restoreGraphicsState];
    }
}

@end
