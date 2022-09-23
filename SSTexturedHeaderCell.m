//
//  SSTexturedHeaderCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTexturedHeaderCell.h"
#import "NSView+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import <SSBase/SSDefines.h>

@implementation SSTexturedHeaderCell

- (instancetype)initTextCell:(NSString *)aString {
	self = [super initTextCell:aString];
	if (self) {
		if (!aString || !aString.length)
            self.stringValue = @" ";
		
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.7];
        shadow.shadowOffset = CGSizeMake(0, -1.0);
        shadow.shadowBlurRadius = 1.0;
        
        attrs = [[NSMutableDictionary alloc] initWithCapacity:3];
        attrs[NSForegroundColorAttributeName] = [NSColor texturedHeaderTextColor];
        attrs[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11.0];
        attrs[NSShadowAttributeName] = shadow;
        
        [shadow release];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id copy = [super copyWithZone:zone];
    [attrs ss_retain];
    return copy;
}

- (void)dealloc {
    [attrs release];
    
    [super ss_dealloc];
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	[[[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.41 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.22 alpha:1.0], 0.9, [NSColor colorWithCalibratedWhite:0.15 alpha:1.0], 1.0, nil] autorelease] drawInRect:cellFrame angle:-90];
	
	cellFrame.size.width -= 1;
    
	[controlView.tableHeaderViewBackgroundGradient drawInRect:cellFrame angle:-90];
    
    cellFrame.size.width += 1;
	
	SEL selector = NSSelectorFromString(@"_drawSortIndicatorIfNecessaryWithFrame:inView:");
	if ([self respondsToSelector:selector]) {
        __unsafe_unretained NSView *view = controlView;
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self  methodSignatureForSelector:selector]];
		invocation.target = self;
		invocation.selector = selector;
		[invocation setArgument:&cellFrame atIndex:2];
		[invocation setArgument:&view atIndex:3];
		[invocation invoke];
	}
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	NSString *stringValue = [self.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if (!stringValue.length)
        return;
	
	CGRect centeredRect = cellFrame;
	centeredRect.size = [stringValue sizeWithAttributes:attrs];
	
	CGFloat maxX = CGRectGetMaxX(cellFrame);
	CGFloat maxWidth = maxX - CGRectGetMinX(centeredRect) - 10.0;
	if (maxWidth < 0)
        maxWidth = 0;
	
	centeredRect.size.width = MIN(CGRectGetWidth(centeredRect), maxWidth);
	centeredRect.origin.x += FLOOR((cellFrame.size.width - centeredRect.size.width)/(CGFloat)2.0);
	centeredRect.origin.y += FLOOR((cellFrame.size.height - centeredRect.size.height)/(CGFloat)2.0);
	
	[stringValue drawWithRect:centeredRect options:NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:attrs];
}

- (void)drawSortIndicatorWithFrame:(CGRect)cellFrame inView:(NSView *)controlView ascending:(BOOL)ascending priority:(NSInteger)priority {
	cellFrame.origin.y -=1;
	cellFrame.size.height += 2;
	
	if (priority == 0) {
		CGRect arrowRect = [self sortIndicatorRectForBounds:cellFrame];
		
		// Adjust Arrow rect
		arrowRect.size.width -= 2;
		arrowRect.size.height -= 1;
		
		NSBezierPath *arrowPath = [[NSBezierPath alloc] init];
		NSPoint points[3];
		
		if (!ascending) {
			// Re-center arrow
			arrowRect.origin.y -= 2;
			points[0] = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMinY(arrowRect) +2);
			points[1] = CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMinY(arrowRect) +2);
			points[2] = CGPointMake(NSMidX(arrowRect), CGRectGetMaxY(arrowRect));
		} else {
			points[0] = CGPointMake(CGRectGetMinX(arrowRect), CGRectGetMaxY(arrowRect) -2);
			points[1] = CGPointMake(CGRectGetMaxX(arrowRect), CGRectGetMaxY(arrowRect) -2);
			points[2] = CGPointMake(NSMidX(arrowRect), CGRectGetMinY(arrowRect));
		}
		
		[arrowPath appendBezierPathWithPoints:points count:3];
		
		if (self.isEnabled)
            [[NSColor colorWithCalibratedWhite:0.41 alpha:1.0] set];
        else
            [[NSColor disabledControlTextColor] set];
		
		[arrowPath fill];
		[arrowPath release];
	}
	
	cellFrame.origin.y += 1;
	cellFrame.size.height -= 2;
}

@end
