//
//  SSDarkScrollView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/15/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSDarkScrollView.h"
#import "SSGradientScroller.h"
#import "NSScroller+SSAdditions.h"

@implementation SSDarkScrollView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSGradient *knobSlotGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:59.0/255.0 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:94.0/255.0 alpha:1.0], 0.1, [NSColor colorWithCalibratedWhite:115.0/255.0 alpha:1.0], 0.25, [NSColor colorWithCalibratedWhite:117.0/255.0 alpha:1.0], 0.67, [NSColor colorWithCalibratedWhite:103.0/255.0 alpha:1.0], 0.85, [NSColor colorWithCalibratedWhite:94.0/255.0 alpha:1.0], 1.0, nil] autorelease];
        NSGradient *activeKnobGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.392f alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.172f alpha:1.0], 1.0, nil] autorelease];
        NSGradient *activeButtonGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:91.0/255.0 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.231f alpha:1.0], 1.0, nil] autorelease];
        NSGradient *activeArrowGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.57 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.55 alpha:1.0], 1.0, nil] autorelease];
        NSColor *activeKnobOutlineColor = [NSColor colorWithCalibratedWhite:0.149f alpha:0.92f];
        NSColor *activeLineColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
        NSColor *highlightLineColor = [NSColor colorWithCalibratedWhite:0.29 alpha:1.0];
        
        if (self.hasHorizontalScroller) {
            SSGradientScroller *horizontalScroller = (SSGradientScroller *) self.horizontalScroller;
            horizontalScroller.knobSlotGradient = knobSlotGradient;
			horizontalScroller.activeKnobGradient = activeKnobGradient;
			horizontalScroller.inactiveKnobGradient = activeKnobGradient;
			horizontalScroller.activeButtonGradient = activeButtonGradient;
			horizontalScroller.highlightButtonGradient = activeKnobGradient;
			horizontalScroller.inactiveButtonGradient = activeButtonGradient;
			horizontalScroller.activeArrowGradient = activeArrowGradient;
			horizontalScroller.inactiveArrowGradient = activeArrowGradient;
			horizontalScroller.activeKnobOutlineColor = activeKnobOutlineColor;
			horizontalScroller.inactiveKnobOutlineColor = activeKnobOutlineColor;
			horizontalScroller.activeLineColor = activeLineColor;
			horizontalScroller.highlightLineColor = highlightLineColor;
			horizontalScroller.inactiveLineColor = activeKnobOutlineColor;
#if defined(__MAC_10_7)
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
#endif
        }
        
        if (self.hasVerticalScroller) {
            SSGradientScroller *verticalScroller = (SSGradientScroller *) self.verticalScroller;
            verticalScroller.knobSlotGradient = knobSlotGradient;
			verticalScroller.activeKnobGradient = activeKnobGradient;
			verticalScroller.inactiveKnobGradient = activeKnobGradient;
			verticalScroller.activeButtonGradient = activeButtonGradient;
			verticalScroller.highlightButtonGradient = activeKnobGradient;
			verticalScroller.inactiveButtonGradient = activeButtonGradient;
			verticalScroller.activeArrowGradient = activeArrowGradient;
			verticalScroller.inactiveArrowGradient = activeArrowGradient;
			verticalScroller.activeKnobOutlineColor = activeKnobOutlineColor;
			verticalScroller.inactiveKnobOutlineColor = activeKnobOutlineColor;
			verticalScroller.activeLineColor = activeLineColor;
			verticalScroller.highlightLineColor = highlightLineColor;
			verticalScroller.inactiveLineColor = activeKnobOutlineColor;
#if defined(__MAC_10_7)
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                verticalScroller.knobStyle = NSScrollerKnobStyleLight;
#endif
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect 
{
    if (self.hasVerticalScroller && self.hasHorizontalScroller) {
        NSRect vframe = self.verticalScroller.frame;
        NSRect hframe = self.horizontalScroller.frame;
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.859 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.733 alpha:1.0]];
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        [gradient drawInRect:NSMakeRect(NSMaxX(hframe), NSMinY(hframe), NSWidth(vframe), NSHeight(hframe)) relativeCenterPosition:NSZeroPoint];
        [context restoreGraphicsState];
        [gradient release];
    }
    else
        [super drawRect:dirtyRect];
}

- (void)viewDidMoveToSuperview;
{
    [super viewDidMoveToSuperview];
    
    if (!self.superview)
        return;
    
    self.borderType = NSNoBorder;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        if (self.hasVerticalScroller)
            self.verticalScroller.knobStyle = NSScrollerKnobStyleLight;
        if (self.hasHorizontalScroller)
            self.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    }
#endif
}

#pragma mark getters && setters

- (void)setVerticalScroller:(NSScroller *)anObject
{
    super.verticalScroller = anObject;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        self.verticalScroller.knobStyle = NSScrollerKnobStyleLight;
#endif
}

- (void)setHorizontalScroller:(NSScroller *)anObject
{
    super.horizontalScroller = anObject;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        self.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
#endif
}

- (BOOL)allowsVibrancy
{
    return YES;
}

@end
