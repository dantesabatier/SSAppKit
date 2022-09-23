//
//  SSCaptureButton.h
//  SSAppKit
//
//  Created by Dante Sabatier on 11/01/16.
//
//

#import <UIKit/UIKit.h>
#import <base/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSCaptureButton : UIButton {
@private;
    CALayer *_circleLayer;
    CALayer *_circleBorder;
    CAShapeLayer *_progressLayer;
    CAGradientLayer *_gradientMaskLayer;
    UIColor *_borderColor;
    UIColor *_buttonColor;
    UIColor *_progressColor;
    NSTimeInterval _animationDelay;
    CGFloat _borderWidth;
    double _maxValue;
    double _minValue;
    double _doubleValue;
    BOOL _animating;
}

@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *progressColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *buttonColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable double maxValue;
@property (nonatomic, assign) IBInspectable double minValue;
@property (nonatomic, assign) IBInspectable double doubleValue;
@property (nonatomic, assign) IBInspectable NSTimeInterval animationDelay;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
- (void)startAnimation:(nullable id)sender;
- (void)stopAnimation:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
