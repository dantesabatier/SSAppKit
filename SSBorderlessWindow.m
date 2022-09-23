//
//  SSBorderlessWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/22/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSBorderlessWindow.h"

@implementation SSBorderlessWindow

#if defined(__MAC_10_12)
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#else
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#endif 
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	if (self) {
        self.backgroundColor = [NSColor clearColor];
        self.releasedWhenClosed = NO;
        self.movableByWindowBackground = NO;
        self.excludedFromWindowsMenu = YES;
        self.alphaValue = 1.0;
        self.opaque = NO;
        self.hasShadow = YES;
	}
	return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end
