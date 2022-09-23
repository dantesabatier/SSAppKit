//
//  Scroller.m
//  Massive Mail
//
//  Created by Dante Sabatier on 18/01/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientScroller.h"
#import "NSWindow+SSAdditions.h"
#import "NSScroller+SSAdditions.h"

@interface SSGradientScroller ()

- (void)drawTopSection;
- (void)drawButtonSeparatorWithHighlight:(BOOL)highlight;

@end

@implementation SSGradientScroller

@synthesize knobSlotGradient = _knobSlotGradient;
@synthesize activeKnobGradient = _activeKnobGradient;
@synthesize inactiveKnobGradient = _inactiveKnobGradient;
@synthesize activeButtonGradient = _activeButtonGradient;
@synthesize highlightButtonGradient = _highlightButtonGradient;
@synthesize inactiveButtonGradient = _inactiveButtonGradient;
@synthesize activeArrowGradient = _activeArrowGradient;
@synthesize inactiveArrowGradient = _inactiveArrowGradient;
@synthesize activeKnobOutlineColor = _activeKnobOutlineColor;
@synthesize inactiveKnobOutlineColor = _inactiveKnobOutlineColor;
@synthesize activeLineColor = _activeLineColor;
@synthesize highlightLineColor = _highlightLineColor;
@synthesize inactiveLineColor = _inactiveLineColor;

+ (BOOL)isCompatibleWithOverlayScrollers {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.knobSlotGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.6 alpha:1.0], 0.0,[NSColor colorWithCalibratedWhite:0.8 alpha:1.0], 0.1, [NSColor colorWithCalibratedWhite:0.92 alpha:1.0], 0.25, [NSColor colorWithCalibratedWhite:0.95 alpha:1.0], 0.67, [NSColor colorWithCalibratedWhite:0.92 alpha:1.0], 0.85, [NSColor colorWithCalibratedWhite:0.88 alpha:1.0], 1.0, nil] autorelease];
		self.activeKnobGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.808f green:0.831f blue:0.859 alpha:1.0], 0.0, [NSColor colorWithCalibratedRed:0.705f green:0.725f blue:0.749f alpha:1.0], 1.0, nil] autorelease];
		self.inactiveKnobGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.89 green:0.89 blue:0.89 alpha:1.0], 0.0,[NSColor colorWithCalibratedRed:0.684f green:0.688f blue:0.688f alpha:1.0], 1.0, nil] autorelease];
		self.activeButtonGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.0], 0.0,[NSColor colorWithCalibratedRed:0.671 green:0.671 blue:0.671 alpha:1.0], 1.0, nil] autorelease];
		self.highlightButtonGradient = self.activeKnobGradient;
		self.inactiveButtonGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.0], 0.0,[NSColor colorWithCalibratedRed:0.64 green:0.64 blue:0.64 alpha:1.0], 1.0, nil] autorelease];
		self.activeArrowGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.3 alpha:1.0], 0.0,[NSColor colorWithCalibratedWhite:0.2 alpha:1.0], 1.0, nil] autorelease];
		self.inactiveArrowGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.47 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.45 alpha:1.0], 1.0, nil] autorelease];
		
		self.activeKnobOutlineColor = [NSColor colorWithCalibratedRed:0.556f green:0.568f blue:0.580f alpha:1.0];
		self.inactiveKnobOutlineColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
		self.activeLineColor = [NSColor colorWithCalibratedRed:0.663 green:0.663 blue:0.663 alpha:1.0];
		self.highlightLineColor = [NSColor colorWithCalibratedRed:0.51 green:0.576 blue:0.675 alpha:1.0];
		self.inactiveLineColor = self.inactiveKnobOutlineColor;
	}
	return self;
}

- (void)dealloc {
	[_knobSlotGradient release];
	[_activeKnobGradient release];
	[_inactiveKnobGradient release];
	[_activeButtonGradient release];
	[_highlightButtonGradient release];
	[_inactiveButtonGradient release];
	[_activeArrowGradient release];
	[_inactiveArrowGradient release];
	[_activeKnobOutlineColor release];
	[_inactiveKnobOutlineColor release];
	[_activeLineColor release];
	[_highlightLineColor release];
	[_inactiveLineColor release];

	[super ss_dealloc];
}

- (void)drawRect:(CGRect)rect {	
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) {
        if (!self.isOverlaid) {
            NSDisableScreenUpdates();
            [self drawKnobSlotInRect:[self rectForPart:NSScrollerKnobSlot] highlight:NO];
            if (self.usableParts == NSNoScrollerParts) {
                NSEnableScreenUpdates();
                return;
            }
            
            if (self.usableParts == NSAllScrollerParts)
                [self drawKnob];
            
            [self drawArrow:NSScrollerIncrementArrow highlight:(self.hitPart == NSScrollerIncrementLine)];
            [self drawArrow:NSScrollerDecrementArrow highlight:(self.hitPart == NSScrollerDecrementLine)];
            
            if (self.arrowsSetting == SSScrollerArrowsTogether) {
                [self drawTopSection];
                [self drawButtonSeparatorWithHighlight:(self.hitPart == NSScrollerIncrementLine)];
            }
            
            [self.window invalidateShadow];
            NSEnableScreenUpdates();
        } else
            [super drawRect:rect];
        
    } else
        [super drawRect:rect];
}

- (CGRect)rectForPart:(NSScrollerPart)part {
    BOOL isVertical = self.isVertical;
    CGRect partRect = [super rectForPart:part];
    if (part == NSScrollerKnob) {
        partRect.origin.y += isVertical ? 3.5: 1.0;
        partRect.origin.x += isVertical ? 1.0 : 3.5;
        if (self.arrowsSetting == SSScrollerArrowsTogether) {
            partRect.size.width -= isVertical ? 2.0 : 4.5;			
            partRect.size.height -= isVertical ? 4.0 : 2.0;
        } else {
            partRect.size.width -= isVertical ? 2.0 : 7.0;
            partRect.size.height -= isVertical ? 7.0 : 2.0;
        }
    }
    return partRect;
}

- (void)drawKnobSlotInRect:(CGRect)slotRect highlight:(BOOL)flag {
    if (![NSGraphicsContext currentContext].drawingToScreen)
        return;
    
    if (self.isOverlaid) {
        [super drawKnobSlotInRect:slotRect highlight:flag];
        return;
    }
    
	[self.knobSlotGradient drawInRect:[self rectForPart:NSScrollerKnobSlot] angle:self.fillAngle];
}

- (void)drawKnob {
    if (![NSGraphicsContext currentContext].drawingToScreen || self.usableParts != NSAllScrollerParts) return;
    
    if (self.isOverlaid) {
        [super drawKnob];
        return;
    }
    
    BOOL isActive = self.window.isActive;
	NSBezierPath *knobPath = [NSBezierPath bezierPathWithRoundedRect:[self rectForPart:NSScrollerKnob] xRadius:7.0 yRadius:7.0];
	//	[NSGraphicsContext saveGraphicsState];
	//	[[NSShadow shadowWithColor:[NSColor blackColor] offset:CGSizeMake(0,-1) blurRadius:2.0] set];
	//	[knobPath fill]; // drawing gradients does not cause the shadow to draw, so we fill the knob with whatever color is currentlt set first.
	//	[NSGraphicsContext restoreGraphicsState];
	[(isActive ? self.activeKnobGradient : self.inactiveKnobGradient) drawInBezierPath:knobPath angle:self.fillAngle];
	[(isActive ? self.activeKnobOutlineColor : self.inactiveKnobOutlineColor) setStroke];
	[knobPath stroke];
}

- (void)drawIncrementButtonWithHighight:(BOOL)highlight {
    BOOL isVertical = self.isVertical;
    BOOL isActive = self.window.isActive;
	CGRect buttonRect = [self rectForPart:NSScrollerIncrementLine];
	
	// draw the button
	NSBezierPath *buttonPath = nil;
	if (self.arrowsSetting == SSScrollerArrowsTogether) {
        buttonPath = [NSBezierPath bezierPathWithRect:buttonRect];
    } else {
		buttonPath = [[[NSBezierPath alloc] init] autorelease];
		NSPoint buttonCorners[4];
		if (isVertical) {
			buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMinY(buttonRect) - CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0 clockwise:YES];
		} else {
			buttonCorners[0] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(buttonRect) - CGRectGetWidth(buttonRect)/2, CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90];			
		}
		[buttonPath closePath];
	}
	
	[(highlight ? self.highlightButtonGradient : (isActive ? self.activeButtonGradient : self.inactiveButtonGradient)) drawInBezierPath:buttonPath angle:self.fillAngle];
	
	// draw the outline
	NSBezierPath *outline = [[[NSBezierPath alloc] init] autorelease];
	if (self.arrowsSetting == SSScrollerArrowsTogether) {
		if (isVertical) {
			[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMaxY(buttonRect))];		
			[outline lineToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMinY(buttonRect))];
		} else {
			[outline moveToPoint:CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
			[outline lineToPoint:CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
		}
	} else {
		if (isVertical) {
			[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMaxY(buttonRect))];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMinY(buttonRect) - CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0 clockwise:YES];
		} else {
			[outline moveToPoint:CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(buttonRect) - CGRectGetWidth(buttonRect)/2, CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90];
		}
	}
	[isActive ? (highlight ? self.highlightLineColor : self.activeLineColor) : self.inactiveLineColor setStroke];
	[outline stroke];	
	
	// draw the arrow
	NSBezierPath *arrowGlyph = [[[NSBezierPath alloc] init] autorelease];
	NSPoint points[3];
	points[0] = isVertical ? CGPointMake(NSMidX(buttonRect), CGRectGetMidY(buttonRect) + 2.5) : CGPointMake(NSMidX(buttonRect) + 2.5, CGRectGetMidY(buttonRect));
	points[1] = isVertical ? CGPointMake(NSMidX(buttonRect) + 3.5, CGRectGetMidY(buttonRect) - 3) : CGPointMake(NSMidX(buttonRect) - 3, CGRectGetMidY(buttonRect) + 3.5);
	points[2] = isVertical ? CGPointMake(NSMidX(buttonRect) - 3.5, CGRectGetMidY(buttonRect) - 3) : CGPointMake(NSMidX(buttonRect) - 3, CGRectGetMidY(buttonRect) - 3.5);
	[arrowGlyph appendBezierPathWithPoints:points count:3];
	[(isActive ? self.activeArrowGradient : self.inactiveArrowGradient) drawInBezierPath:arrowGlyph angle:self.fillAngle];
}

- (void)drawDecrementButtonWithHighlight:(BOOL)highlight {
    BOOL isVertical = self.isVertical;
    BOOL isActive = self.window.isActive;
	CGRect buttonRect = [self rectForPart:NSScrollerDecrementLine];
	
	// draw the button
	NSBezierPath *buttonPath = [[[NSBezierPath alloc] init] autorelease];
	NSPoint buttonCorners[4];
	if (self.arrowsSetting == SSScrollerArrowsTogether) {
		if (isVertical) {
			buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMinY(buttonRect) - CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0 clockwise:YES];
		} else {
			buttonCorners[0] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(buttonRect) - CGRectGetWidth(buttonRect)/2, CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90];			
		}
	} else {
		if (isVertical) {
			buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMaxY(buttonRect) + CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0];
		} else {
			buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[1] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
			buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
			buttonCorners[3] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
            
			[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
			[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(buttonRect) + CGRectGetWidth(buttonRect)/2,CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90 clockwise:YES];		
		}
	}
	
	[buttonPath closePath];
	
	[(highlight ? self.highlightButtonGradient : (isActive ? self.activeButtonGradient : self.inactiveButtonGradient)) drawInBezierPath:buttonPath angle:self.fillAngle];
	
	// draw the outline
	NSBezierPath *outline = [[[NSBezierPath alloc] init] autorelease];
	if (self.arrowsSetting == SSScrollerArrowsTogether) {
		if (isVertical) {
			[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMaxY(buttonRect))];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMinY(buttonRect) - CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0 clockwise:YES];
		} else {
			[outline moveToPoint:CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMinX(buttonRect) - CGRectGetWidth(buttonRect)/2, CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90];
		}
	} else {
		if (isVertical) {
			[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMinY(buttonRect))];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMaxY(buttonRect) + CGRectGetHeight(buttonRect)/2) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0];
		} else {
			[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
			[outline appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(buttonRect) + CGRectGetWidth(buttonRect)/2, CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90 clockwise:YES];
		}
	}
	
	[isActive ? (highlight ? self.highlightLineColor : self.activeLineColor) : self.inactiveLineColor setStroke];
	
	[outline stroke];
	
	// draw the arrow
	NSBezierPath *arrowGlyph = [[[NSBezierPath alloc] init] autorelease];
	NSPoint points[3];
	points[0] = isVertical ? CGPointMake(NSMidX(buttonRect), CGRectGetMidY(buttonRect) - 2.5) : CGPointMake(NSMidX(buttonRect) - 2.5, CGRectGetMidY(buttonRect));
	points[1] = isVertical ? CGPointMake(NSMidX(buttonRect) + 3.5, CGRectGetMidY(buttonRect) + 3) : CGPointMake(NSMidX(buttonRect) + 3, CGRectGetMidY(buttonRect) + 3.5);
	points[2] = isVertical ? CGPointMake(NSMidX(buttonRect) - 3.5, CGRectGetMidY(buttonRect) + 3) : CGPointMake(NSMidX(buttonRect) + 3, CGRectGetMidY(buttonRect) - 3.5);
	[arrowGlyph appendBezierPathWithPoints:points count:3];
    
	[(isActive ? self.activeArrowGradient : self.inactiveArrowGradient) drawInBezierPath:arrowGlyph angle:self.fillAngle];	
}

- (void)drawArrow:(NSScrollerArrow)whichArrow highlight:(BOOL)highlight {
	if (whichArrow == NSScrollerIncrementArrow)
		[self drawIncrementButtonWithHighight:highlight];
	else
		[self drawDecrementButtonWithHighlight:highlight];
}

- (void)drawTopSection {
    BOOL isVertical = self.isVertical;
    BOOL isActive = self.window.isActive;
	NSBezierPath *buttonPath = [[[NSBezierPath alloc] init] autorelease];
	CGRect buttonRect;
	NSPoint buttonCorners[4];
	if (isVertical) {
		buttonRect = CGRectMake(0.0, 0.0, CGRectGetWidth(self.frame),6.0);
        
		buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
		buttonCorners[1] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
		buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
		buttonCorners[3] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
        
		[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
		[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect),CGRectGetMaxY(buttonRect) + CGRectGetHeight(buttonRect)/2 + 5) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0];
	} else {
		buttonRect = CGRectMake(0.0, 0.0, 6.0, CGRectGetHeight(self.frame));
        
		buttonCorners[0] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMaxY(buttonRect));
		buttonCorners[1] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMaxY(buttonRect));
		buttonCorners[2] = CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect));
		buttonCorners[3] = CGPointMake(CGRectGetMaxX(buttonRect), CGRectGetMinY(buttonRect));
        
		[buttonPath appendBezierPathWithPoints:buttonCorners count:4];
		[buttonPath appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(buttonRect) + CGRectGetWidth(buttonRect)/2 + 5,CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90 clockwise:YES];		
	}
	
	[buttonPath closePath];
	
	[isActive ? self.activeButtonGradient : self.inactiveButtonGradient drawInBezierPath:buttonPath angle:self.fillAngle];
	
	NSBezierPath *outline = [[[NSBezierPath alloc] init] autorelease];
	if (isVertical) {
		[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect) + 0.5, CGRectGetMinY(buttonRect))];
		[outline appendBezierPathWithArcWithCenter:CGPointMake(NSMidX(buttonRect), CGRectGetMaxY(buttonRect) + CGRectGetHeight(buttonRect)/2 + 5) radius:CGRectGetWidth(buttonRect)/2 startAngle:180 endAngle:0];
	} else {
		[outline moveToPoint:CGPointMake(CGRectGetMinX(buttonRect), CGRectGetMinY(buttonRect) + 0.5)];
		[outline appendBezierPathWithArcWithCenter:CGPointMake(CGRectGetMaxX(buttonRect) + CGRectGetWidth(buttonRect)/2 + 5,CGRectGetMidY(buttonRect)) radius:CGRectGetHeight(buttonRect)/2 startAngle:270 endAngle:90 clockwise:YES];		
	}
	
	[self.activeLineColor setStroke];
	[outline stroke];
}

- (void)drawButtonSeparatorWithHighlight:(BOOL)highlight {
    BOOL isActive = self.window.isActive;
	CGRect lineRect = [self rectForPart:NSScrollerIncrementLine];
	if (self.isVertical) {
		lineRect.size.height = 0.0;
		lineRect.origin.y += 0.5;
	} else {
		lineRect.size.width = 0.0;
		lineRect.origin.x += 0.5;
	}
	[isActive ? (highlight ? self.highlightLineColor : self.activeLineColor) : self.inactiveLineColor setStroke];
	[[NSBezierPath bezierPathWithRect:lineRect] stroke];	
}

- (CGFloat)fillAngle {
    if (self.isVertical)
        return 0.0f;
    if (floor(NSAppKitVersionNumber) == NSAppKitVersionNumber10_7)
        return -90.0f;
    return 90.0f;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
