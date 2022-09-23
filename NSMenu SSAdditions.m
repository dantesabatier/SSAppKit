//
//  NSMenu+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSMenu+SSAdditions.h"

@implementation NSMenu(SSAdditions)

#if ((!TARGET_OS_IPHONE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED)) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_6))

- (void)removeAllItems {
    NSArray *items = [[self.itemArray copy] autorelease];
    for (NSMenuItem *item in items) {
        [self removeItem:item];
    }
}

#endif

@end

NSMenu *SSApplicationMenu() {
    return [NSApp.mainMenu itemWithTag:100].submenu;
}

NSMenu *SSFileMenu() {
    return [NSApp.mainMenu itemWithTag:200].submenu;
}

NSMenu *SSEditMenu() {
    return [NSApp.mainMenu itemWithTag:300].submenu;
}

NSMenu *SSViewMenu() {
    return [NSApp.mainMenu itemWithTag:400].submenu;
}

NSMenu *SSHelpMenu() {
    return [NSApp.mainMenu itemWithTag:2001].submenu;
}
