//
//  SSDetachableScroller.m
//  SSAppKit
//
//  Created by Dante Sabatier on 3/7/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDetachableScroller.h"
#import "NSScroller+SSAdditions.h"
#import <SSBase/SSDefines.h>

@implementation SSDetachableScroller

- (NSScrollerPart)testPart:(NSPoint)aPoint {
    NSScrollerPart part = [super testPart:aPoint];
    NSPoint location = [self convertPoint:aPoint fromView:nil];
    if (NSPointInRect(location, [self rectForPart:NSScrollerKnob]))
        return NSScrollerKnob;
    
    return part;
}

- (CGRect)rectForPart:(NSScrollerPart)aPart {
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6 && self.isOutsideControl) {
        if (aPart == NSScrollerKnob) {
            CGRect rect = [self rectForPart:NSScrollerKnobSlot];
            CGFloat maxWidth = rect.size.width;
            CGFloat minWidth = 30;
            rect.size.width = MAX(maxWidth * self.knobProportion, minWidth);
            
            CGFloat incrementWidth = (CGFloat) (maxWidth - rect.size.width) / (self.numberOfIncrements);
            rect.origin.x += self.integerValue * incrementWidth;
            
            return rect;
        } else if (aPart == NSScrollerKnobSlot) {
            CGRect rect = [super rectForPart:aPart];
            rect.size.height = 12.0;
            rect.origin.y = CGRectGetMidY(self.bounds) - (rect.size.height/2);
            return rect;
        }
        return CGRectZero;
    }
    return [super rectForPart:aPart];
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
	[super setNeedsDisplayInRect:self.bounds];
}

#pragma mark getters & setters

- (NSInteger)integerValue {
    if (self.isOutsideControl) {
        return (NSInteger)FLOOR(self.floatValue*(CGFloat)self.numberOfIncrements);
    }
    return super.integerValue;
}

- (void)setIntegerValue:(NSInteger)integerValue {
    if (self.isOutsideControl) {
        self.floatValue = MAX(SS_NONNAN(((CGFloat)integerValue/(CGFloat)self.numberOfIncrements)), 0.01);
    } else {
        super.integerValue = integerValue;
    }
}

- (NSUInteger)numberOfIncrements {
    if (self.isOutsideControl) {
        return _numberOfIncrements;
    }
    return 0;
}

- (void)setNumberOfIncrements:(NSUInteger)value {
    if (!self.isOutsideControl) {
        return;
    }
    
	_numberOfIncrements = value;
    
    self.knobProportion = value ? (1.0/(value+1.0)) : 1.0;
	
	[self setNeedsDisplay];
}

- (BOOL)isFlipped {
    return YES;
}

@end
