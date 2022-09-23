//
//  NSScrollView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/13/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "NSScrollView+SSAdditions.h"

@implementation NSScrollView (SSAdditions)

- (BOOL)bounces {
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        return self.verticalScrollElasticity != NSScrollElasticityNone && self.horizontalScrollElasticity != NSScrollElasticityNone;
    }
#endif
    return NO;
}

- (void)setBounces:(BOOL)bounces {
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        self.verticalScrollElasticity = bounces ? NSScrollElasticityAutomatic : NSScrollElasticityNone;
        self.horizontalScrollElasticity = bounces ? NSScrollElasticityAutomatic : NSScrollElasticityNone;
    }
#endif
}

@end
