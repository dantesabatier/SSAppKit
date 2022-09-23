//
//  SSLabelPickerCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/12/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSLabelPickerCell.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "NSBezierPath+SSAdditions.h"
#import <SSBase/SSGeometry.h>

@implementation SSLabelPickerCell

- (void)drawWithFrame:(CGRect)frame inView:(NSView *)view {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
	[context saveGraphicsState];
    
	if ((self.state == NSOnState) || self.isHighlighted) {
        NSColor *color = nil;
        if (self.isHighlighted) {
            color = [NSColor whiteColor];
        } else if (view.window.isActive) {
            color = [NSColor lightGrayColor];
        } else {
            color = [NSColor colorWithCalibratedWhite:0.83921568627451 alpha:1.0];
        }
        
        CGRect bounds = NSInsetRect(frame, 1.0, 1.0);
        if (!self.controlView.effectiveAppearanceIsDark) {
            NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:bounds];
            path.lineWidth = 1.3;
            [[NSColor lightGrayColor] set];
            [path stroke];
        }
            
        CGRect interiorBox = NSInsetRect(bounds, 1.0, 1.0);
        NSBezierPath *interiorPath = [NSBezierPath bezierPathWithOvalInRect:interiorBox];
        interiorPath.lineWidth = 1.3;
		[color set];
		[interiorPath stroke];
	}
    
    if (!self.controlView.effectiveAppearanceIsDark) {
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.92 alpha:0.92];
        shadow.shadowOffset = CGSizeMake(0.0, -1.0);
        [shadow set];
    }
	
    [self.image drawInRect:[self imageRectForBounds:frame] fromRect:CGRectZero operation:NSCompositeSourceOver fraction:self.isEnabled ? 1.0 : 0.5 respectFlipped:YES hints:nil];
	
	[context restoreGraphicsState];
}

- (CGRect)imageRectForBounds:(CGRect)bounds {
    return CGRectIntegral(SSRectCenteredSize(bounds, self.image.size));
}

- (CGSize)cellSize {
    return SSSizeMakeSquare(18.0);
}

@end
