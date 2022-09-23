//
//  SSStyledView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSStyledView.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSView+SSAdditions.h"

@interface SSStyledView ()

@end

@implementation SSStyledView

#pragma mark life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _rectCorners = 0;
        _gradientAngle = 90.0;
        _cornerRadius = 0.0;
    }
    return self;
}

- (void)dealloc {
	[_colorEdges release];
	[_backgroundColor release];
	[_backgroundGradient release];
	[_alternateBackgroundGradient release];

	[super ss_dealloc];
}

- (void)prepareForInterfaceBuilder {
    _rectCorners = 0;
    _gradientAngle = 90.0;
    _cornerRadius = 0.0;
}

#pragma mark drawing

- (void)drawRect:(CGRect)rect {
    BOOL isActive = YES;
    BOOL needsDisplayWhenWindowResignsKey = NO;
    BOOL allowsVibrancy = NO;
#if !TARGET_INTERFACE_BUILDER
    isActive = self.window.isActive;
    needsDisplayWhenWindowResignsKey = self.needsDisplayWhenWindowResignsKey;
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        allowsVibrancy = self.effectiveAppearance.allowsVibrancy;
    }
#endif
#endif
    
    SSRectCorner rectCorners = self.rectCorners;
    CGFloat cornerRadius = self.cornerRadius;
	CGRect bounds = self.bounds;
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    NSColor *backgroundColor = self.backgroundColor;
    if (backgroundColor) {
        if ((needsDisplayWhenWindowResignsKey && !isActive) || (allowsVibrancy && !isActive)) {
            backgroundColor = [NSColor colorWithCalibratedWhite:0.909804 alpha:(self.window.isSheet ? 0.909804 : backgroundColor.alphaComponent)];
        }
        [backgroundColor set];
        [[NSBezierPath bezierPathWithRoundedRect:bounds corners:rectCorners radius:cornerRadius] fill];
    }
    
    CGFloat inset = 1.0;
    NSColor *bottomColor = [self borderColorForEdge:NSRectEdgeMinY];
	if (bottomColor) {
		bounds.origin.y += inset;
		bounds.size.height -= inset;
	}
    
	NSColor *topColor = [self borderColorForEdge:NSMaxYEdge];
	if (topColor) {
        bounds.size.height -= inset;
    }
    
    NSColor *leftColor = [self borderColorForEdge:NSMinXEdge];
    if (leftColor) {
		bounds.origin.x += inset;
		bounds.size.width -= inset;
	}
    
    NSColor *rightColor = [self borderColorForEdge:NSMaxXEdge];
    if (rightColor) {
        bounds.size.width -= inset;
    }
	
	NSColor *bottomInsetColor = [self insetColorForEdge:NSRectEdgeMinY];
    if (bottomInsetColor) {
        bounds.origin.y += inset;
		bounds.size.height -= inset;
    }
    
    NSColor *topInsetColor = [self insetColorForEdge:NSMaxYEdge];
    if (topInsetColor) {
		bounds.size.height -= inset;
    }
    
    NSColor *leftInsetColor = [self insetColorForEdge:NSMinXEdge];
    if (leftInsetColor) {
		bounds.origin.x += inset;
		bounds.size.width -= inset;
	}
    
    NSColor *rightInsetColor = [self insetColorForEdge:NSMaxXEdge];
    if (rightInsetColor) {
        bounds.size.width -= inset;
    }
    
    NSBezierPath *backgroundGradientPath = [NSBezierPath bezierPathWithRoundedRect:bounds corners:rectCorners radius:cornerRadius];
    [backgroundGradientPath addClip];
    
    NSGradient *backgroundGradient = self.backgroundGradient;
    if (backgroundGradient)
        [(!needsDisplayWhenWindowResignsKey || isActive) ? backgroundGradient : self.alternateBackgroundGradient drawInBezierPath:backgroundGradientPath angle:self.gradientAngle];
    
    NSImage *backgroundImage = self.backgroundImage;
    if (backgroundImage) {
        CGFloat yOffset = CGRectGetMaxY([self convertRect:bounds toView:nil]);
        CGFloat xOffset = CGRectGetMinX([self convertRect:bounds toView:nil]);
        context.patternPhase = CGPointMake(xOffset, yOffset);
        
        [[NSColor colorWithPatternImage:backgroundImage] set];
        [backgroundGradientPath fill];
    }
    
    [context restoreGraphicsState];
    
    [leftInsetColor drawPixelThickLineAtPosition:(leftColor ? 1 : 0) withInset:0 inRect:self.bounds inView:self horizontal:NO flip:NO];
    [bottomInsetColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:YES flip:NO];
    [rightInsetColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:NO flip:YES];
    [topInsetColor drawPixelThickLineAtPosition:(topColor ? 1 : 0) withInset:0 inRect:self.bounds inView:self horizontal:YES flip:YES];
    
    [leftColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:NO flip:NO];
    [bottomColor drawPixelThickLineAtPosition:bottomInsetColor ? 1 : 0 withInset:0 inRect:self.bounds inView:self horizontal:YES flip:NO];
    [rightColor drawPixelThickLineAtPosition:rightInsetColor ? 1 : 0 withInset:0 inRect:self.bounds inView:self horizontal:NO flip:YES];
    [topColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:YES flip:YES];
}

#pragma mark NSView

- (void)viewDidMoveToWindow {
	if (!self.window)
        return;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

#pragma mark geters & setters

- (NSMutableDictionary *)colorEdges {
    if (!_colorEdges)
        _colorEdges = [[NSMutableDictionary alloc] init];
    return _colorEdges;
}

- (NSColor *)borderColorForEdge:(NSRectEdge)edge {
	return self.colorEdges[[NSString stringWithFormat:@"border:%@", @(edge)]];
}

- (void)setBorderColor:(NSColor *)color forEdge:(NSRectEdge)edge {
	NSString *key = [NSString stringWithFormat:@"border:%@", @(edge)];
	if (!color)
        [self.colorEdges removeObjectForKey:key];
	else
        self.colorEdges[key] = color;
	
	self.needsDisplay = YES;
}

- (NSColor *)insetColorForEdge:(NSRectEdge)edge {
    return self.colorEdges[[NSString stringWithFormat:@"inset:%@", @(edge)]];
}

- (void)setInsetColor:(NSColor *)color forEdge:(NSRectEdge)edge {
	NSString *key = [NSString stringWithFormat:@"inset:%@", @(edge)];
	if (!color)
        [self.colorEdges removeObjectForKey:key];
	else
        self.colorEdges[key] = color;
	
	self.needsDisplay = YES;
}

- (NSInteger)tag {
    return _tag;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
}

- (NSImage *)backgroundImage {
    return _backgroundImage;
}

- (void)setBackgroundImage:(NSImage *)backgroundImage {
    if (_backgroundImage == backgroundImage)
        return;
    
    SSNonAtomicRetainedSet(_backgroundImage, backgroundImage);
    self.needsDisplay = YES;
}

- (NSColor *)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    if (_backgroundColor == backgroundColor)
        return;
    
    SSNonAtomicRetainedSet(_backgroundColor, backgroundColor);
    
    self.enclosingScrollView.backgroundColor = self.backgroundColor;
    self.needsDisplay = YES;
}

- (NSGradient *)backgroundGradient {
    return _backgroundGradient;
}

- (void)setBackgroundGradient:(NSGradient *)backgroundGradient {
    if (_backgroundGradient == backgroundGradient)
        return;
    
    SSNonAtomicRetainedSet(_backgroundGradient, backgroundGradient);
    self.needsDisplay = YES;
}

- (NSGradient *)alternateBackgroundGradient {
    if (!_alternateBackgroundGradient) {
        _alternateBackgroundGradient = [_backgroundGradient copy];
    }
    return _alternateBackgroundGradient;
}

- (void)setAlternateBackgroundGradient:(NSGradient *)alternateBackgroundGradient {
    if (_alternateBackgroundGradient == alternateBackgroundGradient)
        return;
    
    SSNonAtomicRetainedSet(_alternateBackgroundGradient, alternateBackgroundGradient);
    self.needsDisplay = YES;
}

- (NSColor *)topBorderColor {
    return [self borderColorForEdge:NSMaxYEdge];
}

- (void)setTopBorderColor:(NSColor *)topBorderColor {
    [self setBorderColor:topBorderColor forEdge:NSMaxYEdge];
}

- (NSColor *)bottomBorderColor {
    return [self borderColorForEdge:NSRectEdgeMinY];
}

- (void)setBottomBorderColor:(NSColor *)bottomBorderColor {
    [self setBorderColor:bottomBorderColor forEdge:NSRectEdgeMinY];
}

- (NSColor *)leftBorderColor {
    return [self borderColorForEdge:NSMinXEdge];
}

- (void)setLeftBorderColor:(NSColor *)leftBorderColor {
    [self setBorderColor:leftBorderColor forEdge:NSMinXEdge];
}

- (NSColor *)rightBorderColor {
    return [self borderColorForEdge:NSMaxXEdge];
}

- (void)setRightBorderColor:(NSColor *)rightBorderColor {
    [self setBorderColor:rightBorderColor forEdge:NSMaxXEdge];
}

- (NSColor *)bottomInsetColor {
    return [self insetColorForEdge:NSRectEdgeMinY];
}

- (void)setBottomInsetColor:(NSColor *)bottomInsetColor {
    [self setInsetColor:bottomInsetColor forEdge:NSRectEdgeMinY];
}

- (NSColor *)topInsetColor {
    return [self insetColorForEdge:NSMaxYEdge];
}

- (void)setTopInsetColor:(NSColor *)topInsetColor {
    [self setInsetColor:topInsetColor forEdge:NSMaxYEdge];
}

- (NSColor *)leftInsetColor {
    return [self insetColorForEdge:NSMinXEdge];
}

- (void)setLeftInsetColor:(NSColor *)leftInsetColor {
    [self setInsetColor:leftInsetColor forEdge:NSMinXEdge];
}

- (NSColor *)rightInsetColor {
    return [self insetColorForEdge:NSMaxXEdge];
}

- (void)setRightInsetColor:(NSColor *)rightInsetColor {
    [self setInsetColor:rightInsetColor forEdge:NSMaxXEdge];
}

- (CGFloat)gradientAngle {
    return _gradientAngle;
}

- (void)setGradientAngle:(CGFloat)gradientAngle {
    if (_gradientAngle == gradientAngle)
        return;
    
    _gradientAngle = gradientAngle;
    self.needsDisplay = YES;
}

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius)
        return;
    
    _cornerRadius = cornerRadius;
    
    self.needsDisplay = YES;
}

- (SSRectCorner)rectCorners {
    return _rectCorners;
}

- (void)setRectCorners:(SSRectCorner)rectCorners {
    if (_rectCorners == rectCorners)
        return;
    
    _rectCorners = rectCorners;
    
    self.needsDisplay = YES;
}

- (BOOL)isOpaque {
    return _backgroundColor.alphaComponent == 1.0;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
