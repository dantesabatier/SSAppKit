//
//  SSPopoverWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 04/12/12.
//
//

#import "SSPopoverWindow.h"

@implementation SSPopoverWindow

#if TARGET_OS_IPHONE

#else

#if defined(__MAC_10_12)
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#else
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#endif 
{
	self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
	if (self) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.animationBehavior = NSWindowAnimationBehaviorAlertPanel;
        }
        self.releasedWhenClosed = NO;
        self.opaque = NO;
        self.backgroundColor = [NSColor clearColor];
        self.hasShadow = YES;
	}
	return self;
}

#pragma mark NSEvent

- (void)keyDown:(NSEvent *)event {
    if (event.keyCode == 53) {
        [(id)self.delegate close];
    } else {
        [super keyDown:event];
    }
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (BOOL)canBecomeMainWindow {
    return NO;
}

#endif

@end
