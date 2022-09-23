//
//  SSAnchoredBar.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSAnchoredBar.h"
#import "NSColor+SSAdditions.h"
#import <SSBase/SSDefines.h>

@interface SSAnchoredBar ()

@end

@implementation SSAnchoredBar

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _resizeHandlePosition = NSMaxXEdge;
        _backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.90 alpha:1], 0.0, [NSColor colorWithCalibratedWhite:0.90 alpha:1], 0.45454, [NSColor colorWithCalibratedWhite:0.95 alpha:1], 0.45454, [NSColor colorWithCalibratedWhite:0.99 alpha:1], 1.0, nil];
        [self setBorderColor:[NSColor colorWithCalibratedWhite:0.79 alpha:1.0] forEdge:NSMaxYEdge];
    }
    return self;
}

- (void)dealloc 
{
	_splitView = nil;
	
	[super ss_dealloc];
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    
    _resizeHandlePosition = NSMaxXEdge;
    _backgroundGradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.90 alpha:1], 0.0, [NSColor colorWithCalibratedWhite:0.90 alpha:1], 0.45454, [NSColor colorWithCalibratedWhite:0.95 alpha:1], 0.45454, [NSColor colorWithCalibratedWhite:0.99 alpha:1], 1.0, nil];
    [self setBorderColor:[NSColor colorWithCalibratedWhite:0.79 alpha:1.0] forEdge:NSMaxYEdge];
}

#endif

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (self.isResizable) {
		NSRect handleRect = self.handleRect;
		
		[self drawResizeHandleInRect:handleRect withColor:[NSColor colorWithCalibratedWhite:0 alpha:0.598]];
		
		NSRect insetRect = NSOffsetRect(handleRect, 1, -1);
        
		[self drawResizeHandleInRect:insetRect withColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.55]];
	}
}

- (void)drawResizeHandleInRect:(NSRect)handleRect withColor:(NSColor *)color 
{
	[color drawPixelThickLineAtPosition:0 withInset:0 inRect:handleRect inView:self horizontal:NO flip:NO];
	[color drawPixelThickLineAtPosition:3 withInset:0 inRect:handleRect inView:self horizontal:NO flip:NO];
	[color drawPixelThickLineAtPosition:6 withInset:0 inRect:handleRect inView:self horizontal:NO flip:NO];
}

- (void)resetCursorRects 
{
	[super resetCursorRects];
	
	if (!self.isResizable)
        return;
	
	NSCursor *cursor = (self.resizeHandlePosition != NSMinYEdge) ? [NSCursor resizeLeftRightCursor] : (_resizing ? [NSCursor closedHandCursor] : [NSCursor openHandCursor]);
	
	[self addCursorRect:_resizing ? [(self.window).contentView convertRect:(self.window).contentView.frame toView:self] : self.handleRect cursor:cursor];
}

- (void)mouseDown:(NSEvent *)event
{
	if (!self.isResizable || !self.splitView)
        return;
	
	_resizing = YES;
	
	[self.window invalidateCursorRectsForView:self];
}

- (void)mouseDragged:(NSEvent *)event
{
	if (!self.isResizable || !self.splitView)
        return;
	
	NSPoint location = event.locationInWindow;
	CGFloat position = (self.resizeHandlePosition != NSMaxXEdge) ? (location.x - 10.0) : NSWidth(self.bounds);
	
	[self.splitView setPosition:position ofDividerAtIndex:0];
}

- (void)mouseUp:(NSEvent *)event 
{
	if (!self.isResizable || !self.splitView)
        return;
	
	_resizing = NO;
	
	[self.window invalidateCursorRectsForView:self];
}

#pragma mark getters & setters

- (NSSplitView *)splitView;
{
    return _splitView;
}

- (void)setSplitView:(NSSplitView *)splitView;
{
    _splitView = splitView;
}

- (BOOL)isResizable;
{
    return _resizable;
}

- (void)setResizable:(BOOL)resizable;
{
    _resizable = resizable;
}

- (NSRectEdge)resizeHandlePosition;
{
    return _resizeHandlePosition;
}

- (void)setResizeHandlePosition:(NSRectEdge)value 
{
	_resizeHandlePosition = value;
	
	self.needsDisplay = YES;	
}

- (NSRect)handleRect;
{
	CGFloat maxH = 10.0;
	CGFloat maxW = 10.0;
	NSRect bounds = self.bounds;
	bounds.origin.x = (self.resizeHandlePosition != NSMaxXEdge) ? 4.0 : (NSMaxX(bounds) - (maxW * 2));
	bounds.origin.y = FLOOR((NSHeight(bounds) - maxH) / 2.0);
	bounds.size = NSMakeSize(maxW, maxH);
	return bounds;
}

@end
