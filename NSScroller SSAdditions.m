//
//  NSScroller+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 2/9/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "NSScroller+SSAdditions.h"

@implementation NSScroller (SSAdditions)

- (SSScrollerArrowsSetting)arrowsSetting {
    return self.isVertical ? CGRectGetMaxY([self rectForPart:NSScrollerDecrementLine]) == CGRectGetMinY([self rectForPart:NSScrollerIncrementLine]) ? SSScrollerArrowsTogether : SSScrollerArrowsApart : CGRectGetMaxX([self rectForPart:NSScrollerDecrementLine]) == CGRectGetMinX([self rectForPart:NSScrollerIncrementLine]) ? SSScrollerArrowsTogether : SSScrollerArrowsApart;
}

- (BOOL)isVertical {
	return (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds));
}

- (BOOL)isOverlaid {
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        return self.scrollerStyle == NSScrollerStyleOverlay;
    }
#endif
    return NO;
}

- (BOOL)isOutsideControl {
    return ![self.superview isKindOfClass:[NSScrollView class]];
}

@end
