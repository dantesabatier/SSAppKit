//
//  NSSegmentedCell+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 01/02/14.
//
//

#import "NSSegmentedCell+SSAdditions.h"

@implementation NSSegmentedCell (SSAdditions)

- (BOOL)isTrackingForSegment:(NSInteger)segment {
    SEL selector = NSSelectorFromString(@"_trackingSegment");
	if (selector && [self respondsToSelector:selector]) {
        NSInteger trackingSegment;
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self  methodSignatureForSelector:selector]];
		invocation.target = self;
		invocation.selector = selector;
		[invocation invoke];
        [invocation getReturnValue:&trackingSegment];
        return (trackingSegment == segment);
	}
	return NO;
}

@end
