//
//  SSSegmentedControl.m
//  SSAppKit
//
//  Created by Dante Sabatier on 28/01/13.
//
//

#import "SSSegmentedControl.h"

@implementation SSSegmentedControl

- (void)validate {
	id validator = [NSApp targetForAction:self.action to:self.target from:self];
	if (validator) {
        if (![validator respondsToSelector:self.action]) {
            self.enabled = NO;
        } else if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
            self.enabled = [validator validateUserInterfaceItem:self];
        } else {
            self.enabled = YES;
        }
            
    }
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:nil];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
    
    if (!self.window)
        return;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validate) name:NSWindowDidUpdateNotification object:self.window];
}

@end
