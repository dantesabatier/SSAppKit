//
//  SSProgressView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/21/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSView.h"
#if !TARGET_OS_IPHONE
#import <SSQuartz/SSQuartzDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSProgressView : SSView {
@private
    CADisplayLink *_displayLink;
    CGFloat _phase;
    CGGradientRef _progressGradient;
    id _startProgressGradientColor;
    id _endProgressGradientColor;
    CGFloat _cornerRadius;
    struct {
        unsigned int viewHasCustomProgressGradient:1;
        unsigned int indeterminate:1;
    } _flags;
    double _minValue;
    double _maxValue;
    double _doubleValue;
}

@property (nonatomic, nullable) CGGradientRef progressGradient;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) double minValue;
@property (nonatomic) double maxValue;
@property (nonatomic) double doubleValue;
@property (nonatomic, getter = isIndeterminate) BOOL indeterminate;
- (void)startAnimation:(nullable id)sender;
- (void)stopAnimation:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END

