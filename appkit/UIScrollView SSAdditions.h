//
//  UIScrollView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 08/09/14.
//
//

#import "UIView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (SSAdditions)

@property (nonatomic, assign) BOOL hasHorizontalScroller;
@property (nonatomic, assign) BOOL hasVerticalScroller;

- (void)flashScrollers;

@end

NS_ASSUME_NONNULL_END
