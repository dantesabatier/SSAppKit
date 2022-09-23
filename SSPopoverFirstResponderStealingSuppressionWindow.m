//
//  SSPopoverFirstResponderStealingSuppressionWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 16/07/14.
//
//

#import "SSPopoverFirstResponderStealingSuppressionWindow.h"
#import "SSPopoverFirstResponderStealingSuppression.h"

@implementation SSPopoverFirstResponderStealingSuppressionWindow

- (BOOL)makeFirstResponder:(NSResponder *)responder {
    // Prevent popover content view from forcing our current first responder to resign
    if (responder != self.firstResponder && [responder isKindOfClass:[NSView class]]) {
        NSWindow *currentFirstResponderWindow = nil;
        NSWindow *const newFirstResponderWindow = ((NSView *)responder).window;
        NSResponder *const currentFirstResponder = self.firstResponder;
        if ([currentFirstResponder isKindOfClass:[NSWindow class]]) {
            currentFirstResponderWindow = (id)currentFirstResponder;
        } else if ([currentFirstResponder isKindOfClass:[NSView class]]) {
            currentFirstResponderWindow = ((NSView *)currentFirstResponder).window;
        }
        
        // Prevent some view in popover from stealing our first responder, but allow the user to explicitly activate it with a click on the popover.
        // Note that the current first responder may be in a child window, if it's a control in the "thick titlebar" area and we're currently full-screen.
        if ((newFirstResponderWindow != self) && (newFirstResponderWindow != currentFirstResponderWindow) && (self.currentEvent.window != newFirstResponderWindow)) {
            for (NSView *responderView = (id)responder; responderView; responderView = responderView.superview) {
                if ([responderView conformsToProtocol:@protocol(SSPopoverFirstResponderStealingSuppression)] && ((id <SSPopoverFirstResponderStealingSuppression>)responderView).suppressFirstResponderWhenPopoverShows) {
                    return NO;
                }
            }
        }
    }
    return [super makeFirstResponder:responder];
}

@end
