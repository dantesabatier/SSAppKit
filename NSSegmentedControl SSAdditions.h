//
//  NSSegmentedControl+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSegmentedControl(SSAdditions)

- (void)adjustWidthAndHideSegmentsAtIndexesIfNeeded:(nullable NSIndexSet *)indexes;
- (NSInteger)segmentAtPoint:(NSPoint)point;
- (CGRect)rectForSegment:(NSInteger)segment;
- (BOOL)isTrackingForSegment:(NSInteger)segment;

@end

NS_ASSUME_NONNULL_END
