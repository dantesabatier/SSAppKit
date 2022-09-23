//
//  SSGradientSegmentedControl.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientSegmentedControl.h"
#import "SSGradientSegmentedCell.h"
#import "NSSegmentedControl+SSAdditions.h"

@implementation SSGradientSegmentedControl

+ (Class)cellClass {
    return SSGradientSegmentedCell.class;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
    if (self) {
        if (![self.cell isKindOfClass:self.class.cellClass]) {
            NSSegmentedCell *oldCell = self.cell;
            NSInteger segment, segmentCount = self.segmentCount;
            NSSegmentedCell *cell = [[[self.class.cellClass alloc] init] autorelease];
            cell.segmentCount = segmentCount;
            cell.trackingMode = oldCell.trackingMode;
            cell.action = oldCell.action;
            cell.target = oldCell.target;
            cell.tag = oldCell.tag;
            cell.enabled = oldCell.isEnabled;
            cell.bezeled = NO;
            cell.bordered = NO;
            cell.controlSize = oldCell.controlSize;
            cell.segmentStyle = oldCell.segmentStyle;
            
            for (segment = 0; segment < segmentCount; segment++) {
                [cell setWidth:[oldCell widthForSegment:segment] forSegment:segment];
                [cell setImage:[oldCell imageForSegment:segment] forSegment:segment];
                [cell setLabel:[oldCell labelForSegment:segment] forSegment:segment];
                [cell setToolTip:[oldCell toolTipForSegment:segment] forSegment:segment];
                [cell setEnabled:[oldCell isEnabledForSegment:segment] forSegment:segment];
                [cell setSelected:[oldCell isSelectedForSegment:segment] forSegment:segment];
                [cell setMenu:[oldCell menuForSegment:segment] forSegment:segment];
                [cell setTag:[oldCell tagForSegment:segment] forSegment:segment];
            }
            
            self.cell = cell;
        }
    }
    return self;
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    self.cell = [[[self.class.cellClass alloc] init] autorelease];
}

#endif

- (void)resizeHorizontally {
    CGRect superFrame = self.superview.frame;
    CGFloat width = CGRectGetWidth(superFrame);
    if ((self.autoresizingMask & NSViewMinXMargin) != 0) {
        width -= 20.0;
    }
        
    if ((self.autoresizingMask & NSViewMaxXMargin) != 0) {
         width -= 20.0;
    }
    
    CGRect frame = self.frame;
    frame.size = CGSizeMake(MAX(width, 80.0), CGRectGetHeight(frame));
    frame.origin = CGPointMake(NSMidX(superFrame) - (CGRectGetWidth(frame)*(CGFloat)0.5), CGRectGetMinY(frame));
    
    self.frame = CGRectIntegral(frame);
    
    [self adjustWidthAndHideSegmentsAtIndexesIfNeeded:[NSIndexSet indexSet]];
}

- (void)viewWillMoveToSuperview:(NSView *)superview {
	[super viewWillMoveToSuperview:superview];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:nil];
}

- (void)viewDidMoveToSuperview {
    if (self.superview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:self.superview];
    }
}

- (void)viewFrameChanged:(NSNotification *)notification {
    if ((self.autoresizingMask & NSViewWidthSizable) == 0) {
        return;
    }
    
    [self resizeHorizontally];
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger segment = [self segmentAtPoint:location];
    if (segment != self.selectedSegment && NSLocationInRange(segment, NSMakeRange(0, self.segmentCount))) {
        self.selectedSegment = segment;
        [self sendAction:self.action to:self.target];
    }
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
