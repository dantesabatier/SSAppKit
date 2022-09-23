//
//  SSOverlayWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/22/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSOverlayWindow.h"
#import <SSBase/SSDefines.h>

@implementation SSOverlayWindow

- (instancetype)init
{
    self = [self initWithContentRect:NSMakeRect(0, 0, 300, 300) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
            self.animationBehavior = NSWindowAnimationBehaviorNone;
        self.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
        self.hasShadow = NO;
	}
	return self;
}

- (void)dealloc
{
    self.parentView = nil;
    
    [super ss_dealloc];
}

- (void)orderFront:(id)sender;
{
    if (_parentView.window) {
        NSRect frame = _parentView.window.frame;
        if (_parentView != _parentView.window.contentView) {
            frame = [_parentView.superview convertRect:_parentView.frame toView:self.contentView];
#if defined(__MAC_10_7)
            if ([self respondsToSelector:@selector(convertRectToScreen:)])
                frame = [self convertRectToScreen:frame];
#else
            frame.origin = [self convertBaseToScreen:frame.origin];
#endif
        }
        
        [self setFrame:frame display:YES];
        
        [_parentView.window addChildWindow:self ordered:NSWindowAbove];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:_parentView.window];
    }
	
    self.alphaValue = 0;
    [super orderFront:sender];
	[NSAnimationContext currentContext].duration = 0.6;
    (self.animator).alphaValue = 1.0;
}

- (void)makeKeyAndOrderFront:(id)sender;
{
	[self orderFront:nil];
}

- (void)orderOut:(id)sender
{
    [super orderOut:sender];
}

- (void)close;
{
    if (self.alphaValue != 1.0 || !self.isVisible)
        return;
    
    if (_parentView.window) {
        if ([_parentView.window.childWindows containsObject:self])
            [_parentView.window removeChildWindow:self];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:_parentView.window];
    }
    
    [NSAnimationContext currentContext].duration = 0.6;
    (self.animator).alphaValue = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([NSAnimationContext currentContext].duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [super close];
    });
}

#pragma mark NSView notifications

- (void)viewFrameChanged:(NSNotification *)notification;
{
    if (self.isVisible) {
        NSRect frame = [_parentView.superview convertRect:_parentView.frame toView:self.contentView];
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            frame = [_parentView.window convertRectToScreen:frame];
        }
#else
        frame.origin = [_parentView.window convertBaseToScreen:frame.origin];
#endif
        
        
        
        [self setFrame:frame display:YES];
    }
}

#pragma mark NSWindow notifications

- (void)windowWillClose:(NSNotification *)notification
{
    [self close];
}

#pragma mark getters & setters

- (NSView *)parentView
{
    return _parentView;
}

- (void)setParentView:(NSView *)parentView
{
	if (_parentView == parentView)
        return;
	
	if (_parentView)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:_parentView];
	
    SSNonAtomicRetainedSet(_parentView, parentView);
	
	if (_parentView)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:_parentView];
}

- (BOOL)canBecomeKeyWindow
{
    return NO;
}

@end
