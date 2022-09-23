//
//  SSDrawer.m
//  SSAppKit
//
//  Created by Dante Sabatier on 2/9/13.
//
//

#import "SSDrawer.h"
#import "SSBorderlessWindow.h"
#import "SSBackgroundView.h"
#import <SSBase/SSDefines.h>

@implementation SSDrawer

- (instancetype)init {
    self = [super init];
    if (self) {
        _preferredEdge = NSMaxXEdge;
    }
    return self;
}

- (void)dealloc {
    [_window release];
    [_contentViewController release];
    [_drawerViewController release];
    
    [super ss_dealloc];
}

- (void)open {
    
}

- (void)close {
    
}

#pragma mark getters & setters

- (NSViewController *)contentViewController {
    return _contentViewController;
}

- (void)setContentViewController:(NSViewController *)contentViewController {
    if (_contentViewController == contentViewController)
        return;
    
    SSNonAtomicRetainedSet(_contentViewController, contentViewController);
}

- (NSViewController *)drawerViewController {
    return _drawerViewController;
}

- (void)setdrawerViewController:(NSViewController *)drawerViewController {
    if (_drawerViewController == drawerViewController)
        return;
    
    SSNonAtomicRetainedSet(_drawerViewController, drawerViewController);
}

- (NSRectEdge)preferredEdge {
    return _preferredEdge;
}

- (void)setPreferredEdge:(NSRectEdge)preferredEdge {
    _preferredEdge = preferredEdge;
}

- (NSWindow *)window {
    if (!_window) {
        _window = [[SSBorderlessWindow alloc] initWithContentRect:CGRectMake(0, 0, 350, 160) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
        _window.contentView = [[[SSBackgroundView alloc] initWithFrame:((NSView *)_window.contentView).frame] autorelease];
    }
    return _window;
}

@end
