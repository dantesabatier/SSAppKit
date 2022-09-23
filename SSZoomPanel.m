//
//  SSZoomPanel.m
//  SSAppKit
//
//  Created by Dante Sabatier on 21/02/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSZoomPanel.h"
#import "NSWindow+SSAdditions.h"
#import <SSGraphics/SSImage.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>
#import <QuartzCore/CATransaction.h>

@implementation SSZoomPanel

#if defined(__MAC_10_12)
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#else
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#endif 
{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	if (self) {
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.animationBehavior = NSWindowAnimationBehaviorNone;
            //self.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary;
        }
#endif
	}
	return self;
}

- (void)close {
    if (!self.isVisible) {
        return;
    }
    
    CGRect destinationRect = CGRectZero;
    if ([self.delegate respondsToSelector:@selector(sourceFrameOnScreenForZoomPanel:)]) {
        destinationRect = [self.delegate sourceFrameOnScreenForZoomPanel:self];
    }
    
    if (NSIsEmptyRect(destinationRect)) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [super close];
            self.alphaValue = 1.0;
        }];
        self.animator.alphaValue = 0.0;
        [CATransaction commit];
        return;
    }
    
    CGRect sourceFrame = self.frame;
    NSWindow *sourceWindow = nil;
    if ([self.delegate respondsToSelector:@selector(sourceWindowForZoomPanel:)]) {
        sourceWindow = [self.delegate sourceWindowForZoomPanel:self];
    }
        
    if (!sourceWindow) {
        sourceWindow = ((NSApplication *)NSApp).mainWindow;
    }
    
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:sourceWindow.screen.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    panel.backgroundColor = [NSColor clearColor];
    panel.excludedFromWindowsMenu = YES;
    panel.opaque = NO;
    panel.hasShadow = NO;
    panel.releasedWhenClosed = YES;
    panel.ignoresMouseEvents = YES;
    panel.level = self.level;
    
    NSView *contentView = [[[NSView alloc] initWithFrame:((NSView *)panel.contentView).bounds] autorelease];
    contentView.autoresizingMask = NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewHeightSizable|NSViewMaxYMargin;
    contentView.layer = [CALayer layer];
    contentView.wantsLayer = YES;
    
    panel.contentView = contentView;
    
    [sourceWindow addChildWindow:panel ordered:NSWindowAbove];
    [panel orderFront:nil];
    
    NSBitmapImageRep *imageRep = [((NSView *)self.contentView).superview bitmapImageRepForCachingDisplayInRect:((NSView *)self.contentView).superview.bounds];
    [((NSView *)self.contentView).superview cacheDisplayInRect:((NSView *)self.contentView).superview.bounds toBitmapImageRep:imageRep];
    
    CALayer *layer = [CALayer layer];
    layer.contents = (__bridge id)imageRep.CGImage;
#if 1
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 0.33;
    layer.shadowRadius = 6.0;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        layer.shouldRasterize = YES;
        layer.rasterizationScale = CGRectGetWidth([contentView convertRectToBacking:destinationRect])/CGRectGetWidth(destinationRect);
        layer.contentsScale = layer.rasterizationScale*(CGFloat)2.0;
    }
#endif
#endif
    layer.anchorPoint = CGPointZero;
    layer.bounds = destinationRect;
    layer.position = destinationRect.origin;
    
    [contentView.layer addSublayer:layer];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [super close];
        self.alphaValue = 1.0;
    }];
    self.animator.alphaValue = 0.0;
    [CATransaction commit];
    
    NSTimeInterval duration = [self animationResizeTime:destinationRect];
#if DEBUG
    NSUInteger modifierFlags = self.currentEvent.modifierFlags;
    if (modifierFlags & NSShiftKeyMask) {
        duration *= 2.0;
    }
        
    if ((modifierFlags & NSShiftKeyMask) && (modifierFlags & NSControlKeyMask)) {
        duration *= 4;
    }
#endif
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [sourceWindow removeChildWindow:panel];
        [panel close];
    }];
    
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithRect:sourceFrame];
    boundsAnimation.toValue = [NSValue valueWithRect:destinationRect];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithPoint:sourceFrame.origin];
    positionAnimation.toValue = [NSValue valueWithPoint:destinationRect.origin];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.animations = @[boundsAnimation, positionAnimation];
    animationGroup.duration = duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    [layer addAnimation:animationGroup forKey:nil];
    
    [CATransaction commit];
}

- (void)makeKeyAndOrderFront:(id)sender {
    if (self.isVisible) {
        [super makeKeyAndOrderFront:sender];
        return;
    }
    
    if (!self.frameAutosaveName) {
        [self center];
    }
    
    CGRect sourceFrame = CGRectZero;
    if ([self.delegate respondsToSelector:@selector(sourceFrameOnScreenForZoomPanel:)]) {
        sourceFrame = [self.delegate sourceFrameOnScreenForZoomPanel:self];
    }
    
    if (NSIsEmptyRect(sourceFrame)) {
        [super makeKeyAndOrderFront:sender];
        return;
    }
    
    NSWindow *sourceWindow = nil;
    if ([self.delegate respondsToSelector:@selector(sourceWindowForZoomPanel:)]) {
        sourceWindow = [self.delegate sourceWindowForZoomPanel:self];
    }
        
    if (!sourceWindow) {
        sourceWindow = ((NSApplication *)NSApp).mainWindow;
    }
    
    CGRect destinationRect = self.frame;
    if (!CGRectContainsRect(sourceWindow.screen.visibleFrame, destinationRect)) {
        destinationRect = SSRectCenteredRect(sourceWindow.screen.visibleFrame, destinationRect);
        [self setFrame:destinationRect display:YES];
    }
    
    NSPanel *panel = [[NSPanel alloc] initWithContentRect:sourceWindow.screen.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    panel.backgroundColor = [NSColor clearColor];
    panel.excludedFromWindowsMenu = YES;
    panel.opaque = NO;
    panel.hasShadow = NO;
    panel.releasedWhenClosed = YES;
    panel.ignoresMouseEvents = YES;
    panel.level = self.level;
    
    NSView *contentView = [[[NSView alloc] initWithFrame:((NSView *)panel.contentView).bounds] autorelease];
    contentView.autoresizingMask = NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewHeightSizable|NSViewMaxYMargin;
    contentView.layer = [CALayer layer];
    contentView.wantsLayer = YES;
    
    panel.contentView = contentView;
    
    [sourceWindow addChildWindow:panel ordered:NSWindowAbove];
    [panel orderFront:nil];
    
    NSBitmapImageRep *imageRep = [((NSView *)self.contentView).superview bitmapImageRepForCachingDisplayInRect:((NSView *)self.contentView).superview.bounds];
    [((NSView *)self.contentView).superview cacheDisplayInRect:((NSView *)self.contentView).superview.bounds toBitmapImageRep:imageRep];
    
    CALayer *layer = [CALayer layer];
    layer.contents = (__bridge id)imageRep.CGImage;
#if 1
    layer.shadowOffset = CGSizeZero;
    layer.shadowOpacity = 0.33;
    layer.shadowRadius = 6.0;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        layer.shouldRasterize = YES;
        layer.rasterizationScale = CGRectGetWidth([contentView convertRectToBacking:destinationRect])/CGRectGetWidth(destinationRect);
        layer.contentsScale = layer.rasterizationScale*(CGFloat)2.0;
    }
#endif
#endif
    layer.anchorPoint = CGPointZero;
    layer.bounds = destinationRect;
    layer.position = destinationRect.origin;
    
    [contentView.layer addSublayer:layer];
    
    NSTimeInterval duration = [self animationResizeTime:sourceFrame];
#if DEBUG
    NSUInteger modifierFlags = self.currentEvent.modifierFlags;
    if (modifierFlags & NSShiftKeyMask) {
        duration *= 2.0;
    }
    
    if ((modifierFlags & NSShiftKeyMask) && (modifierFlags & NSControlKeyMask)) {
        duration *= 4;
    }
#endif
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [sourceWindow removeChildWindow:panel];
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [panel close];
        }];
        panel.animator.alphaValue = 0.0;
        [CATransaction commit];
        
        [super makeKeyAndOrderFront:sender];
    }];
    
    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithRect:sourceFrame];
    boundsAnimation.toValue = [NSValue valueWithRect:destinationRect];
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithPoint:sourceFrame.origin];
    positionAnimation.toValue = [NSValue valueWithPoint:destinationRect.origin];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.animations = @[boundsAnimation, positionAnimation];
    animationGroup.duration = duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    [layer addAnimation:animationGroup forKey:nil];
    
    [CATransaction commit];
}

#pragma mark getters & setters

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (id<SSZoomPanelDelegate>)delegate {
    return (id<SSZoomPanelDelegate>)super.delegate;
}

- (void)setDelegate:(id<SSZoomPanelDelegate>)delegate {
    super.delegate = delegate;
}

@end
