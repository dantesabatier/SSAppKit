//
//  SSBorderlessPanel.m
//  SSAppKit
//
//  Created by Dante Sabatier on 06/08/12.
//
//

#import "SSBorderlessPanel.h"

@implementation SSBorderlessPanel

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	if (self)
	{
        self.backgroundColor = [NSColor clearColor];
        self.releasedWhenClosed = NO;
        self.movableByWindowBackground = NO;
        self.excludedFromWindowsMenu = YES;
        self.alphaValue = 1.0;
        self.opaque = NO;
        self.hasShadow = YES;
        [self useOptimizedDrawing:YES];
	}
	return self;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
