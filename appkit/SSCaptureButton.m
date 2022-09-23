//
//  SSCaptureButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/01/16.
//
//

#import "SSCaptureButton.h"
#import "UIView+SSAdditions.h"
#import <base/SSGeometry.h>
#import <foundation/NSTimer+SSAdditions.h>
#import <quartz/CALayer+SSAdditions.h>

@interface SSCaptureButton()

@end

@implementation SSCaptureButton

- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if (self) {
        _borderWidth = 1.0;
        _minValue = 0.0;
        _maxValue = 1.0;
        _doubleValue = 0.0;
        _animationDelay = 1.0/30.0;
        _animating = NO;
        [self addTarget:self action:@selector(didTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self drawButton];
        [self didTouchDown];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeDouble:_maxValue forKey:@"maxValue"];
    [coder encodeDouble:_minValue forKey:@"minValue"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _maxValue = [coder decodeDoubleForKey:@"maxValue"] ? [coder decodeDoubleForKey:@"maxValue"] : 1.0;
        _minValue = [coder decodeDoubleForKey:@"minValue"] ? [coder decodeDoubleForKey:@"minValue"] : 0.0;
        _doubleValue = [coder decodeDoubleForKey:@"doubleValue"] ? [coder decodeDoubleForKey:@"doubleValue"] : 0.0;
        _animationDelay = [coder decodeDoubleForKey:@"animationDelay"] ? [coder decodeDoubleForKey:@"animationDelay"] : 1.0/30.0;
        [self addTarget:self action:@selector(didTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(didTouchUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(didTouchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self drawButton];
        [self didTouchDown];
    }
    
    return self;
}

- (void)dealloc {
    [_circleLayer release];
    [_circleBorder release];
    [_progressLayer release];
    [_gradientMaskLayer release];
    [_buttonColor release];
    [_progressColor release];
    
    [super ss_dealloc];
}

- (void)startAnimation:(nullable id)sender {
    if (!_animating) {
        _animating = YES;
        [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:_animationDelay validation:^BOOL{
            self.doubleValue += _animationDelay/1.0;
            if ((_doubleValue >= _maxValue) || !_animating) {
                self.doubleValue = _minValue;
            }
            return _animating;
        }] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAnimation:(nullable id)sender {
    _doubleValue = 0.0;
    _animating = NO;
}

- (void)reset {
    if (!_borderColor) {
        _borderColor = [[UIColor alloc] initWithWhite:0.89 alpha:1.0];
    }
    
    if (!_buttonColor) {
        _buttonColor = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    }
    
    if (!_progressColor) {
        _progressColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    
    [_progressLayer removeAllAnimations];
    [_circleBorder removeAllAnimations];
    [_circleLayer removeAllAnimations];
    
    _progressLayer.opacity = 1.0;
    _progressLayer.scale = 1.0;
    
    _circleBorder.opacity = 1.0;
    _circleBorder.scale = 1.0;
    _circleBorder.borderColor = _borderColor.CGColor;//[UIColor colorWithRed:0.89 green:0.89 blue:0.89 alpha:1].CGColor;
    _circleBorder.borderWidth = _borderWidth*self.scale;
    
    _circleLayer.scale = 1.0;
    _circleLayer.opacity = 1.0;
    _circleLayer.backgroundColor = _buttonColor.CGColor;
    
    _gradientMaskLayer.scale = 1.0;
    _gradientMaskLayer.opacity = 1.0;
    _gradientMaskLayer.colors = @[(id)_progressColor.CGColor, (id)_progressColor.CGColor];
    
    _doubleValue = 0.0;
}

- (void)drawButton {
    if (!_borderColor) {
        _borderColor = [[UIColor alloc] initWithWhite:0.89 alpha:1.0];
        //_borderColor = [[UIColor alloc] initWithRed:0.83 green:0.86 blue:0.89 alpha:1.0];
    }
    
    if (!_buttonColor) {
        _buttonColor = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    }
    
    if (!_progressColor) {
        _progressColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    
    self.backgroundColor = [UIColor clearColor];
    
    CALayer *layer = self.layer;
    if (!_circleLayer) {
        _circleLayer = [[CALayer alloc] init];
        _circleLayer.bounds = SSRectMakeSquare(self.frame.size.width/1.5);
        _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _circleLayer.position = SSRectGetCenterPoint(self.bounds);
        _circleLayer.cornerRadius = CGRectGetWidth(_circleLayer.bounds)/2;
        _circleLayer.shadowOffset = CGSizeMake(0.0, 2.0);
        _circleLayer.shadowRadius = 1.0;
        
        [layer insertSublayer:_circleLayer atIndex:0];
    }
    
#if 0
    _circleLayer.shadowOpacity = 0.33;
#endif
    _circleLayer.backgroundColor = _buttonColor.CGColor;
    
    if (!_circleBorder) {
        _circleBorder = [[CALayer alloc] init];
        _circleBorder.backgroundColor = [UIColor clearColor].CGColor;
        _circleBorder.borderWidth = _borderWidth*self.scale;
        _circleBorder.borderColor = _borderColor.CGColor;
        _circleBorder.bounds = CGRectMake(0, 0, self.bounds.size.width-1.5f, self.bounds.size.height-1.5f);
        _circleBorder.anchorPoint = CGPointMake(0.5, 0.5);
        _circleBorder.position = SSRectGetCenterPoint(self.bounds);
        
        _circleBorder.cornerRadius = self.frame.size.width/2;
        
        [layer insertSublayer:_circleBorder atIndex:0];
    }
    
    if (!_gradientMaskLayer) {
        _gradientMaskLayer = [[CAGradientLayer alloc] init];
        _gradientMaskLayer.frame = self.bounds;
        _gradientMaskLayer.locations = @[@0.0, @1.0];
    }
    
    if (!_progressLayer) {
        CGFloat startAngle = M_PI + M_PI_2;
        CGFloat endAngle = M_PI * 3 + M_PI_2;
        CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        
        _progressLayer = [[CAShapeLayer alloc] init];
        _progressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:self.frame.size.width/2-2 startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
        _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.strokeColor = [UIColor blackColor].CGColor;
        _progressLayer.lineWidth = 4.0;
        _progressLayer.strokeStart = 0.0;
        _progressLayer.strokeEnd = 0.0;
        
        _gradientMaskLayer.mask = _progressLayer;
        
        [layer insertSublayer:_gradientMaskLayer atIndex:0];
    }
    
    _gradientMaskLayer.colors = @[(id)_progressColor.CGColor, (id)_progressColor.CGColor];
}

- (void)layoutSubviews {
    _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _circleLayer.position = SSRectGetCenterPoint(self.bounds);

    _circleBorder.anchorPoint = CGPointMake(0.5, 0.5);
    _circleBorder.position = SSRectGetCenterPoint(self.bounds);
    
    [super layoutSubviews];
}

- (void)didTouchDown {
    CGFloat duration = 0.15;
    _circleLayer.contentsGravity = @"center";
    
    // Animate main circle
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @0.88;
    scaleAnimation.duration = duration;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = YES;
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = duration;
    colorAnimation.fillMode = kCAFillModeForwards;
    colorAnimation.removedOnCompletion = YES;
    colorAnimation.toValue = (id)_progressColor.CGColor;
    
    CAAnimationGroup *circleAnimations = [CAAnimationGroup animation];
    circleAnimations.removedOnCompletion = YES;
    circleAnimations.fillMode = kCAFillModeForwards;
    [circleAnimations setDuration:duration];
    [circleAnimations setAnimations:@[scaleAnimation, colorAnimation]];
    
    // Animate border
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.duration = duration;
    borderAnimation.fillMode = kCAFillModeForwards;
    borderAnimation.removedOnCompletion = YES;
    borderAnimation.toValue = (id)_borderColor.CGColor;
    
    CABasicAnimation *borderScale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    borderScale.fromValue = @(((CALayer *)_circleBorder.presentationLayer).scale);
    borderScale.toValue = @0.88;
    borderScale.duration = duration;
    borderScale.fillMode = kCAFillModeForwards;
    borderScale.removedOnCompletion = YES;
    
    CAAnimationGroup *borderAnimations = [CAAnimationGroup animation];
    borderAnimations.removedOnCompletion = YES;
    borderAnimations.fillMode = kCAFillModeForwards;
    borderAnimations.duration = duration;
    [borderAnimations setAnimations:@[borderAnimation, borderScale]];
    
    // Animate progress
    CABasicAnimation *fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @0.0;
    fadeIn.toValue = @1.0;
    fadeIn.duration = duration;
    fadeIn.fillMode = kCAFillModeForwards;
    fadeIn.removedOnCompletion = YES;
    
    [_progressLayer addAnimation:fadeIn forKey:@"fadeIn"];
    [_circleBorder addAnimation:borderAnimations forKey:@"borderAnimations"];
    [_circleLayer addAnimation:circleAnimations forKey:@"circleAnimations"];
}

- (void)didTouchUp {
    CGFloat duration = 0.15;
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = @0.88;
    scale.toValue =   @1.0;
    [scale setDuration:duration];
    scale.fillMode = kCAFillModeForwards;
    scale.removedOnCompletion = YES;
    
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.fillMode = kCAFillModeForwards;
    colorAnimation.removedOnCompletion = YES;
    colorAnimation.toValue = (id)_buttonColor.CGColor;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    animations.removedOnCompletion = YES;
    animations.fillMode = kCAFillModeForwards;
    animations.duration = duration;
    animations.animations = @[scale, colorAnimation];
    
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.duration = duration;
    borderAnimation.fillMode = kCAFillModeForwards;
    borderAnimation.removedOnCompletion = YES;
    borderAnimation.toValue = (id)_buttonColor.CGColor;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @0.88;
    scaleAnimation.toValue = @1.0;
    scaleAnimation.duration = duration;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *borderAnimations = [CAAnimationGroup animation];
    borderAnimations.removedOnCompletion = YES;
    borderAnimations.fillMode = kCAFillModeForwards;
    borderAnimations.duration = duration;
    borderAnimations.animations = @[borderAnimation, scaleAnimation];
    
    // Animate progress
    CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @1.0;
    fadeOut.toValue = @0.0;
    fadeOut.duration = duration*2;
    fadeOut.fillMode = kCAFillModeForwards;
    fadeOut.removedOnCompletion = YES;

    [_progressLayer addAnimation:fadeOut forKey:@"fadeOut"];
    [_circleBorder addAnimation:borderAnimations forKey:@"borderAnimations"];
    [_circleLayer addAnimation:animations forKey:@"circleAnimations"];
}

#pragma mark getters & setters

- (UIColor *)progressColor {
    if (!_progressColor) {
        _progressColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    return _progressColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    SSNonAtomicRetainedSet(_progressColor, progressColor);
    [self reset];
}

- (UIColor *)borderColor {
    if (!_borderColor) {
        _borderColor = [[UIColor alloc] initWithWhite:0.89 alpha:1.0];
    }
    return _borderColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    SSNonAtomicRetainedSet(_borderColor, borderColor);
    [self reset];
}

- (UIColor *)buttonColor {
    if (!_buttonColor) {
        _buttonColor = [[UIColor alloc] initWithWhite:1.0 alpha:1.0];
    }
    return _buttonColor;
}

- (void)setButtonColor:(UIColor *)buttonColor {
    SSNonAtomicRetainedSet(_buttonColor, buttonColor);
    [self reset];
}

- (CGFloat)borderWidth {
    return _borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    
    [self reset];
}

- (NSTimeInterval)animationDelay {
    return _animationDelay;
}

- (void)setAnimationDelay:(NSTimeInterval)animationDelay {
    _animationDelay = animationDelay;
    
    [self reset];
}

- (double)maxValue {
    return _maxValue;
}

- (void)setMaxValue:(double)maxValue {
    _maxValue = maxValue;
    
    [self reset];
}

- (double)minValue {
    return _minValue;
}

- (void)setMinValue:(double)minValue {
    _minValue = minValue;
    
    [self reset];
}

- (double)doubleValue {
    return _doubleValue;
}

- (void)setDoubleValue:(double)doubleValue {
    if (_doubleValue == doubleValue) {
        return;
    }
    
    _doubleValue = doubleValue;
    _progressLayer.strokeEnd = (_doubleValue/_maxValue);
    
    if ((doubleValue >= _maxValue) || (doubleValue == _minValue)) {
        [self reset];
    }
}

- (BOOL)isAnimating {
    return _animating;
}

@end
