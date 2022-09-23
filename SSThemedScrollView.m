//
//  SSThemedScrollView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/24/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSThemedScrollView.h"
#import "SSThemedScroller.h"
#import "NSColor+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "NSScroller+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSThemedScrollView

+ (BOOL)isCompatibleWithResponsiveScrolling {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hasVerticalScroller = self.hasVerticalScroller;
        self.hasHorizontalScroller = self.hasHorizontalScroller;
    }
    return self;
}

- (void)dealloc {
    [_theme release];
    
    [super ss_dealloc];
}

- (void)setNeedsDisplay:(BOOL)flag {
    super.needsDisplay = flag;
    
    if (flag) {
        [self.verticalScroller setNeedsDisplay];
        [self.horizontalScroller setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)dirtyRect {
    if (self.hasVerticalScroller && self.hasHorizontalScroller && [self.horizontalScroller isKindOfClass:[SSThemedScroller class]] && ((SSThemedScroller *)self.horizontalScroller).isThemed) {
        CGColorRef backgroundColor = ((SSThemedScroller *)self.horizontalScroller).backgroundColor;
        if (backgroundColor) {
            CGRect vframe = self.verticalScroller.frame;
            CGRect hframe = self.horizontalScroller.frame;
            CGContextRef ctx = SSContextGetCurrent();
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, backgroundColor);
            CGContextFillRect(ctx, CGRectMake(CGRectGetMaxX(hframe), CGRectGetMinY(hframe), CGRectGetWidth(vframe), CGRectGetHeight(hframe)));
            CGContextRestoreGState(ctx);
        } else {
            [super drawRect:dirtyRect];
        }
    } else {
        [super drawRect:dirtyRect];
    }
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    if (!self.window)
        return;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

#pragma mark getters && setters

- (void)setHasVerticalScroller:(BOOL)flag {
    super.hasVerticalScroller = flag;
    
    if (flag) {
        SSThemedScroller *scroller = [[[SSThemedScroller alloc] initWithFrame:self.verticalScroller.bounds] autorelease];
        scroller.arrowsPosition = self.verticalScroller.arrowsPosition;
        scroller.theme = _theme;
        self.verticalScroller = scroller;
    }
}

- (void)setHasHorizontalScroller:(BOOL)flag {
    super.hasHorizontalScroller = flag;
    
    if (flag) {
        SSThemedScroller *scroller = [[[SSThemedScroller alloc] initWithFrame:self.horizontalScroller.bounds] autorelease];
        scroller.arrowsPosition = self.horizontalScroller.arrowsPosition;
        scroller.theme = _theme;
        self.horizontalScroller = scroller;
    }
}

- (void)setVerticalScroller:(NSScroller *)anObject {
    if ([anObject isKindOfClass:[SSThemedScroller class]])
        super.verticalScroller = anObject;
}

- (void)setHorizontalScroller:(NSScroller *)anObject {
    if ([anObject isKindOfClass:[SSThemedScroller class]])
        super.horizontalScroller = anObject;
}

- (id<SSTheme>)theme {
    return _theme;
}

- (void)setTheme:(id<SSTheme>)theme {
    SSNonAtomicRetainedSet(_theme, theme);
    
    if (theme) {
        if (self.hasHorizontalScroller && [self.horizontalScroller isKindOfClass:[SSThemedScroller class]])
            ((SSThemedScroller *)self.horizontalScroller).theme = theme;
        if (self.hasVerticalScroller && [self.verticalScroller isKindOfClass:[SSThemedScroller class]])
            ((SSThemedScroller *)self.verticalScroller).theme = theme;
        self.drawsBackground = YES;
        if (theme.backgroundImage) {
            self.backgroundColor = [NSColor colorWithPatternImage:theme.backgroundImage];
        } else {
            self.backgroundColor = theme.backgroundColor;
        }
    }
    
    self.needsDisplay = YES;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
