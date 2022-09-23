//
//  SSSlider.m
//  SSAppKit
//
//  Created by Dante Sabatier on 16/09/13.
//
//

#import "SSSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <SSBase/SSDefines.h>

@implementation SSSlider

+ (id)defaultAnimationForKey:(NSString *)key {
    if ([key isEqualToString:@"floatValue"]) {
        return [CABasicAnimation animation];
    }
    return [super defaultAnimationForKey:key];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)scrollWheel:(NSEvent*)event {
	CGFloat valueRange = self.maxValue - self.minValue;
	CGFloat valueOffset = self.doubleValue - self.minValue;
	CGFloat pixelRange = self.isVertical ? CGRectGetHeight(self.frame) : CGRectGetWidth(self.frame);
	CGFloat valueInPixelSpace = ((valueOffset / valueRange) * pixelRange);
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        valueInPixelSpace += event.deltaX;
        valueInPixelSpace -= event.deltaY;
    } else {
        valueInPixelSpace += event.deltaY;
        valueInPixelSpace -= event.deltaX;
    }
	
    self.floatValue = self.minValue + ((valueInPixelSpace / pixelRange) * valueRange);
	[self sendAction:self.action to:self.target];
}

#if 0

- (void)setDoubleValue:(double)aDouble {
    aDouble = (aDouble > self.maxValue) ? self.maxValue : aDouble;
    aDouble = (aDouble < self.minValue) ? self.minValue : aDouble;
    
    if (((self.doubleValue == self.minValue) && (aDouble == self.maxValue)) || ((self.doubleValue == self.maxValue) && (aDouble == self.minValue))) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:0.15];
        
        [self.animator setFloatValue:(CGFloat)aDouble];
        [NSAnimationContext endGrouping];
    } else {
        super.doubleValue = aDouble;
    }
}

#endif

@end
