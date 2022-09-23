//
//  UIScrollView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 08/09/14.
//
//

#import "UIScrollView+SSAdditions.h"

@implementation UIScrollView (SSAdditions)

- (BOOL)hasHorizontalScroller {
    return self.showsHorizontalScrollIndicator;
}

- (void)setHasHorizontalScroller:(BOOL)hasHorizontalScroller {
    self.showsHorizontalScrollIndicator = hasHorizontalScroller;
}

- (BOOL)hasVerticalScroller {
    return self.showsVerticalScrollIndicator;
}

- (void)setHasVerticalScroller:(BOOL)hasVerticalScroller {
    self.showsVerticalScrollIndicator = hasVerticalScroller;
}

- (void)flashScrollers {
    [self flashScrollIndicators];
}

@end
