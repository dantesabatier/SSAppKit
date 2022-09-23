//
//  NSViewController+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 02/12/14.
//
//

#import "NSViewController+SSAdditions.h"

@implementation NSViewController (SSAdditions)

- (id)popover {
#if defined(__MAC_10_7)
    Class SSPopoverWindowClass = NSClassFromString(@"_NSPopoverWindow");
    if (SSPopoverWindowClass) {
        NSWindow *window = self.view.window;
        if ([window isKindOfClass:SSPopoverWindowClass]) {
            SEL selector = NSSelectorFromString(@"_popover");
            if ([window respondsToSelector:selector]) {
                id popover = [window performSelector:selector];
                Class SSPopoverClass = NSClassFromString(@"NSPopover");
                if (SSPopoverClass && [popover isKindOfClass:SSPopoverClass]/* && [[popover contentViewController] isEqual:self]*/) {
                    return popover;
                }
            }
        }
    }
#endif
    return nil;
}

@end
