//
//  SSDarkWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 05/09/12.
//
//

#import "SSDarkWindow.h"
#import "NSView+SSAdditions.h"

@implementation SSDarkWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if (self) {
        self.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.8];
        self.alphaValue = 1.0;
        self.opaque = NO;
        
        SSTitleBar *titleBar = self.titleBar;
        titleBar.backgroundImage = nil;
        titleBar.backgroundGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.16 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.24 alpha:1.0], 1.0, nil] autorelease];
        titleBar.needsDisplayWhenWindowResignsKey = NO;
        [titleBar setBorderColor:[NSColor blackColor] forEdge:NSMinYEdge];
        
    }
    return self;
}

@end
