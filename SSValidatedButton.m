//
//  SSValidatedButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSValidatedButton.h"

@implementation SSValidatedButton

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    if (self.window) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validate) name:NSWindowDidUpdateNotification object:self.window];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:nil];
}

- (void)validate {
    id validator = [NSApp targetForAction:self.action to:self.target from:self];
    if (!validator || ![validator respondsToSelector:self.action]) {
        self.enabled = NO;
    } else if ([validator respondsToSelector:@selector(validateButton:)]) {
        self.enabled = [validator validateButton:self];
    } else if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
        self.enabled = [validator validateUserInterfaceItem:self];
    } else {
        self.enabled = YES;
    }
}

@end
