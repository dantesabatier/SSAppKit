//
//  SSMenuButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSMenuButton.h"
#import <SSBase/SSDefines.h>

@implementation SSMenuButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.menu = [coder decodeObjectForKey:@"menu"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.menu forKey:@"menu"];
}

- (void)mouseDown:(NSEvent *)event {
    if (self.isEnabled) {
        [self showMenuWithEvent:event];
    }
}

- (void)menuDidEndTracking:(NSNotification *)notification {
	NSButtonCell *cell = self.cell;
	if ([self respondsToSelector:@selector(setState:)]) {
        if (cell.state) {
            self.state = NSOffState;
        }
	} else {
        if (cell.isHighlighted) {
            cell.highlighted = NO;
        }
	}
    
    [self setNeedsDisplay];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showMenuWithEvent:(NSEvent *)event {
    NSMenu *menu = self.menu;
    if (!menu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidEndTracking:) name:NSMenuDidEndTrackingNotification object:menu];
    
    NSButtonCell *cell = self.cell;
	if ([self respondsToSelector:@selector(setState:)]) {
        if (!cell.state) {
            self.state = NSOnState;
        }
	} else {
        if (!cell.isHighlighted) {
            cell.highlighted = YES;
        }
	}
    
    NSPoint lpoint = CGPointMake(0, self.isFlipped ? (CGRectGetHeight(self.frame) + 3.0) : -3.0);
    NSPoint point = [self convertPoint:lpoint toView:nil];
    NSEvent *popupEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:point modifierFlags:0 timestamp:0 windowNumber:self.window.windowNumber context:[NSGraphicsContext currentContext] eventNumber:0 clickCount:1 pressure:0];
    [NSMenu popUpContextMenu:menu withEvent:popupEvent forView:self withFont:self.font];
}

@end
