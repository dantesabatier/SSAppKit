//
//  SSTintedSegmentedControlCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTintedSegmentedControlCell.h"
#import "NSSegmentedCell+SSAdditions.h"
#import "NSWindow+SSAdditions.h"

@implementation SSTintedSegmentedControlCell

- (void)drawBackgroundWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	[[NSColor colorWithCalibratedWhite:0.333 alpha:1.0] setFill];
    
    NSRectFill(cellFrame);
}

- (void)drawBackgroundForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
	[[self backgroundGradientForSegment:segment] drawInRect:frame angle:90];
}

- (void)drawSelectionForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
	if (![self isTrackingForSegment:segment])
        return;
	
    [super drawSelectionForSegment:segment inFrame:frame withView:controlView];
}

- (NSDictionary *)labelAttributesForSegment:(NSInteger)segment {
	NSColor *shadowColor = [NSColor whiteColor];
	NSColor *foregroundColor = [NSColor colorWithCalibratedRed:0.165f green:0.169f blue:0.176f alpha:1.0f];
	if ([self isSelectedForSegment:segment]) {
		shadowColor = [NSColor blackColor];
		foregroundColor = [NSColor whiteColor];
	}
	
	NSShadow *shadow = [[NSShadow alloc] init];
	shadow.shadowColor = shadowColor;
	shadow.shadowOffset = CGSizeMake(0, -1.0);
	shadow.shadowBlurRadius = 0.0f;
	
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	attrs[NSForegroundColorAttributeName] = foregroundColor;
	attrs[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11.0];
	attrs[NSShadowAttributeName] = shadow;
	
	[shadow release];
	
	return attrs;
}

- (NSGradient *)backgroundGradientForSegment:(NSInteger)segment {
	NSColor *startColor = nil;
    NSColor *endColor = nil;
	
	BOOL isActive = self.controlView.window.isActive;
	BOOL isBlueControlTint = [NSColor currentControlTint] == NSBlueControlTint;
    if ([self isTrackingForSegment:segment]) {
		if ([self isSelectedForSegment:segment]) {
			if (isBlueControlTint) {
				startColor = [NSColor colorWithCalibratedRed:76.0/255.0 green:121.0/255.0 blue:200.0/255.0 alpha:1.0];
				endColor = [NSColor colorWithCalibratedRed:109.0/255.0 green:152.0/255.0 blue:228.0/255.0 alpha:1.0];
				
			} else {
				startColor = [NSColor colorWithCalibratedRed:64.0/255.0 green:87.0/255.0 blue:112.0/255.0 alpha:1.0];
				endColor = [NSColor colorWithCalibratedRed:130.0/255.0 green:147.0/255.0 blue:166.0/255.0 alpha:1.0];
				
			}	
		} else {
			startColor = [NSColor colorWithCalibratedRed:175.0/255.0 green:184.0/255.0 blue:199.0/255.0 alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:207.0/255.0 green:214.0/255.0 blue:226.0/255.0 alpha:1.0];
		}
    } else if ([self isSelectedForSegment:segment]) {
		if (isActive) {
			if (isBlueControlTint) {
				startColor = [NSColor colorWithCalibratedRed:109.0/255.0 green:152.0/255.0 blue:228.0/255.0 alpha:1.0];
				endColor = [NSColor colorWithCalibratedRed:76.0/255.0 green:121.0/255.0 blue:200.0/255.0 alpha:1.0];
				
			} else {
				startColor = [NSColor colorWithCalibratedRed:130.0/255.0 green:147.0/255.0 blue:166.0/255.0 alpha:1.0];
				endColor = [NSColor colorWithCalibratedRed:64.0/255.0 green:87.0/255.0 blue:112.0/255.0 alpha:1.0];
				
			}		
		} else {
			startColor = [NSColor colorWithCalibratedWhite:193.0/255.0 alpha:1.0];
			endColor = [NSColor colorWithCalibratedWhite:138.0/255.0 alpha:1.0];
		}
		
	} else {
		if (isActive) {
			startColor = [NSColor colorWithCalibratedRed:207.0/255.0 green:214.0/255.0 blue:226.0/255.0 alpha:1.0];
			endColor = [NSColor colorWithCalibratedRed:175.0/255.0 green:184.0/255.0 blue:199.0/255.0 alpha:1.0];			
		} else {
			startColor = [NSColor colorWithCalibratedWhite:219.0/255.0 alpha:1.0];
			endColor = [NSColor colorWithCalibratedWhite:187.0/255.0 alpha:1.0];
		}
	}
    
    return [[[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor] autorelease];
}

@end
