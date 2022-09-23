//
//  NSSegmentedControl+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSSegmentedControl+SSAdditions.h"
#import "NSSegmentedCell+SSAdditions.h"
#import <SSBase/SSDefines.h>

@implementation NSSegmentedControl(SSAdditions)

- (void)adjustWidthAndHideSegmentsAtIndexesIfNeeded:(NSIndexSet *)indexes {
    CGFloat width = (CGFloat)(self.segmentCount - indexes.count) + 1.0;
    CGFloat proposedSegmentWidth = [self widthForSegment:0];
    NSInteger segmentCount = self.segmentCount;
    if (segmentCount) {
        NSInteger idx = 0;
        while (idx < segmentCount) {
            CGFloat segmentWidth = [indexes containsIndex:idx] ? 0.0 : MAX([self widthForSegment:idx], proposedSegmentWidth);
            [self setWidth:segmentWidth forSegment:idx];
            width += segmentWidth;
            idx++;
        }
    }
	self.frame = CGRectMake(FLOOR(NSMidX(self.frame) - FLOOR(width*(CGFloat)0.5)), CGRectGetMinY(self.frame), FLOOR(width), CGRectGetHeight(self.frame));
}

- (NSInteger)segmentAtPoint:(NSPoint)point {
    NSInteger segment = NSNotFound;
    NSInteger segmentCount = self.segmentCount;
    if (segmentCount) {
        CGRect segmentRect = CGRectZero;
        segmentRect.size.height = CGRectGetHeight(self.frame);
        NSInteger idx = 0;
        while (idx < segmentCount) {
            segmentRect.size.width = [self widthForSegment:idx];
            if (NSPointInRect(point, segmentRect)) {
                segment = idx;
                break;
            }
            segmentRect.origin.x += CGRectGetWidth(segmentRect);
            idx++;
        }
    }
    return segment;
}

- (CGRect)rectForSegment:(NSInteger)segment {
    CGRect segmentRect = CGRectZero;
    NSInteger segmentCount = self.segmentCount;
    if (segmentCount) {
        segmentRect.size.height = CGRectGetHeight(self.frame);
        
        NSInteger idx = 0;
        while (idx < segmentCount) {
            segmentRect.size.width = [self widthForSegment:idx];
            if (idx == segment) {
                break;
            }
            
            segmentRect.origin.x += CGRectGetWidth(segmentRect);
            idx++;
        }
    }
    return segmentRect;
}

- (BOOL)isTrackingForSegment:(NSInteger)segment {
    return [self.cell isTrackingForSegment:segment];
}

@end
