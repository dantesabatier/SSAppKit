//
//  ScrollView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientScrollView.h"
#import "SSGradientScroller.h"
#import "NSScroller+SSAdditions.h"

@implementation SSGradientScrollView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hasVerticalScroller = self.hasVerticalScroller;
        self.hasHorizontalScroller = self.hasHorizontalScroller;
    }
    return self;
}

- (void)setNeedsDisplay {
	self.needsDisplay = YES;
    [self.verticalScroller setNeedsDisplay];
    [self.horizontalScroller setNeedsDisplay];
}

- (void)drawRect:(CGRect)dirtyRect {
    if (!self.verticalScroller.isOverlaid && self.hasVerticalScroller && self.hasHorizontalScroller) {
        CGRect vframe = self.verticalScroller.frame;
        CGRect hframe = self.horizontalScroller.frame;
        NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85882352941176 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.73333333333333 alpha:1.0]];
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        [gradient drawInRect:CGRectMake(CGRectGetMaxX(hframe), CGRectGetMinY(hframe), CGRectGetWidth(vframe), CGRectGetHeight(hframe)) relativeCenterPosition:NSZeroPoint];
        [context restoreGraphicsState];
        [gradient release];
    } else
        [super drawRect:dirtyRect];
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToWindow {
    if (!self.window)
        return;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

#pragma mark getters && setters

- (void)setHasVerticalScroller:(BOOL)flag {
    super.hasVerticalScroller = flag;
    
    if (flag) {
        SSGradientScroller *scroller = [[[SSGradientScroller alloc] initWithFrame:self.verticalScroller.bounds] autorelease];
        scroller.arrowsPosition = self.verticalScroller.arrowsPosition;
        self.verticalScroller = scroller;
    }
}

- (void)setHasHorizontalScroller:(BOOL)flag {
    super.hasHorizontalScroller = flag;
    
    if (flag) {
        SSGradientScroller *scroller = [[[SSGradientScroller alloc] initWithFrame:self.horizontalScroller.bounds] autorelease];
        scroller.arrowsPosition = self.horizontalScroller.arrowsPosition;
        self.horizontalScroller = scroller;
    }
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
