//
//  SSDarkTextView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/20/12.
//
//

#import "SSDarkTextView.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSScrollView+SSAdditions.h"

@implementation SSDarkTextView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.insertionPointColor = [NSColor whiteColor];
        self.textColor = [NSColor whiteColor];
        self.drawsBackground = NO;
        self.font = [NSFont systemFontOfSize:11.0];
        self.textContainerInset = NSMakeSize(0.0, 2.0);
        
        NSMutableDictionary *selectedTextAttributes = [[self.selectedTextAttributes mutableCopy] autorelease];
        selectedTextAttributes[NSBackgroundColorAttributeName] = [NSColor colorWithCalibratedWhite:1.0 alpha:0.33];
        
        self.selectedTextAttributes = selectedTextAttributes;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.insertionPointColor = [NSColor whiteColor];
        self.textColor = [NSColor whiteColor];
        self.drawsBackground = NO;
        self.font = [NSFont systemFontOfSize:11.0];
        self.textContainerInset = NSMakeSize(0.0, 2.0);
        
        NSMutableDictionary *selectedTextAttributes = [[self.selectedTextAttributes mutableCopy] autorelease];
        selectedTextAttributes[NSBackgroundColorAttributeName] = [NSColor colorWithCalibratedWhite:1.0 alpha:0.33];
        
        self.selectedTextAttributes = selectedTextAttributes;
    }
    return self;
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    
	self.enclosingScrollView.bounces = NO;
    self.enclosingScrollView.drawsBackground = NO;
    self.enclosingScrollView.borderType = NSNoBorder;
}

- (void)drawViewBackgroundInRect:(NSRect)rect
{
    NSRect backgroundRect = self.visibleRect;
    backgroundRect.size.height -= 1.f;
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
    [[NSColor colorWithCalibratedWhite:0.000 alpha:0.150] set];
    [backgroundPath fill];
    
    NSShadow *innerGlow = [[[NSShadow alloc] init] autorelease];
    innerGlow.shadowColor = [NSColor colorWithCalibratedWhite:0.000 alpha:0.300];
    innerGlow.shadowOffset = NSZeroSize;
    innerGlow.shadowBlurRadius = 3.0;
    
    [backgroundPath applyInnerShadow:innerGlow];
    NSRect innerShadowRect = NSInsetRect(backgroundRect, -2.f, 0.f);
    innerShadowRect.size.height *= 2.f;
    
    NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRect:innerShadowRect];
    
    NSShadow *innerShadow = [[[NSShadow alloc] init] autorelease];
    innerShadow.shadowColor = [NSColor colorWithCalibratedWhite:0.000 alpha:0.400];
    innerShadow.shadowOffset = NSMakeSize(0, -1.0);
    innerShadow.shadowBlurRadius = 3.0;
    
    
    [shadowPath applyInnerShadow:innerShadow];
    NSRect dropShadowRect = backgroundRect;
    dropShadowRect.origin.y = NSMaxY(self.visibleRect) - 1.f;
    [[NSColor colorWithCalibratedWhite:1.000 alpha:0.100] set];
    [NSBezierPath fillRect:dropShadowRect];
}

- (BOOL)allowsVibrancy
{
    return YES;
}

@end
