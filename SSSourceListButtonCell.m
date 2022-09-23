//
//  SSSourceListButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSourceListButtonCell.h"
#import <SSBase/SSDefines.h>

@implementation SSSourceListButtonCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	if (self) {
        _buttonCell = [[NSButtonCell alloc] init];
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            _buttonCell.bezelStyle = NSInlineBezelStyle;
        }
#endif
        _buttonCell.controlSize = self.controlSize;
        _buttonCell.enabled = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SSSourceListButtonCell *cell = (SSSourceListButtonCell *) [super copyWithZone:zone];
    cell->_buttonCell = [_buttonCell ss_retain];
	
    return cell;
}

- (void)dealloc {
	[_buttonCell release];
	
	[super ss_dealloc];
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	[super drawWithFrame:cellFrame inView:controlView];
    
    CGRect buttonRect = [self buttonRectForBounds:cellFrame];
    if (!NSIsEmptyRect(buttonRect))
        [_buttonCell drawWithFrame:buttonRect inView:controlView];
}

- (BOOL)trackMouse:(NSEvent *)event inRect:(CGRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag {
    if (_buttonCell.isEnabled) {
        NSPoint point = [controlView convertPoint:event.locationInWindow fromView:nil];
        CGRect buttonRect = [self buttonRectForBounds:cellFrame];
        if (!NSIsEmptyRect(buttonRect) && NSMouseInRect(point, buttonRect, controlView.isFlipped))
            [NSApp sendAction:self.action to:self.target from:controlView];
    }
	
    return [_buttonCell trackMouse:event inRect:cellFrame ofView:controlView untilMouseUp:flag];
}

#if defined(__MAC_10_10)
- (NSCellHitResult)hitTestForEvent:(NSEvent *)event inRect:(CGRect)cellFrame ofView:(NSView *)controlView
#else
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(CGRect)cellFrame ofView:(NSView *)controlView
#endif 
{
	NSPoint point = [controlView convertPoint:event.locationInWindow fromView:nil];
	CGRect linkRect = [self buttonRectForBounds:cellFrame];
	if (NSMouseInRect(point, linkRect, controlView.isFlipped)) 
        return NSCellHitContentArea|NSCellHitTrackableArea;
        
    return [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
}

- (CGRect)titleRectForBounds:(CGRect)bounds {
    CGSize buttonSize = NSZeroSize;
    if (/*self.target && */self.action) {
        buttonSize = _buttonCell.cellSize;
        if (NSEqualSizes(buttonSize, NSZeroSize))
            buttonSize = CGSizeMake(18.0, 18.0);
    }
    CGRect rect = [super titleRectForBounds:bounds];
    rect.size.width -= buttonSize.width;
    return rect;
}

- (CGRect)buttonRectForBounds:(CGRect)bounds {
    if (/*self.target && */self.action) {
        CGSize buttonSize = _buttonCell.cellSize;
        if (NSEqualSizes(buttonSize, NSZeroSize))
            buttonSize = CGSizeMake(18.0, 18.0);
        return CGRectMake(FLOOR(CGRectGetMaxX(bounds) - buttonSize.width), FLOOR(CGRectGetMidY(bounds) - (buttonSize.height*(CGFloat)0.5)), buttonSize.width, buttonSize.height);
    }
    return CGRectZero;
}

- (CGRect)badgeRectForBounds:(CGRect)bounds {
    CGRect badgeRect = [super badgeRectForBounds:bounds];
    badgeRect.origin.x -= FLOOR(CGRectGetWidth([self buttonRectForBounds:bounds])*(CGFloat)1.5);
    return badgeRect;
}

#pragma mark getters & setters

- (NSButtonCell *)buttonCell {
    return _buttonCell;
}

- (void)setEnabled:(BOOL)flag {
    super.enabled = flag;
    _buttonCell.enabled = flag;
}

- (void)setState:(NSInteger)value {
    super.state = value;
    _buttonCell.state = value;
}

- (void)setHighlighted:(BOOL)flag {
    super.highlighted = flag;
    _buttonCell.highlighted = flag;
}

- (void)setControlSize:(NSControlSize)size {
    super.controlSize = size;
    _buttonCell.controlSize = size;
}

- (CGSize)cellSize {
    CGSize cellSize = super.cellSize;
    cellSize.width += FLOOR(CGRectGetWidth([self buttonRectForBounds:self.controlView.bounds])*(CGFloat)1.5);
    return cellSize;
}

+ (BOOL)prefersTrackingUntilMouseUp {
	return YES;
}

@end
