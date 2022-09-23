//
//  SSViewController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/18/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSViewController.h"

@implementation SSViewController

#if TARGET_OS_IPHONE

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#else

- (void)viewWillAppear {
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [super viewWillAppear];
    }
#endif
}

- (NSString *)nibName {
    return NSStringFromClass(self.class);
}

- (NSBundle *)nibBundle {
    return [NSBundle bundleForClass:self.class];
}

#endif

@end
