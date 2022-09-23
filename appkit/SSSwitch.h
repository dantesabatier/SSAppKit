//
//  SSSwitch.h
//  SSAppKit
//
//  Created by Dante Sabatier on 27/01/16.
//
//

#import <UIKit/UIKit.h>
#import <base/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(NA, 5_0)
IB_DESIGNABLE
@interface SSSwitch : UIControl {
@package;
    UIColor *_onColor;
    UIColor *_offColor;
    UIColor *_buttonColor;
    UIColor *_buttonBorderColor;
    UIColor *_borderColor;
    UIColor *_shadowColor;
    CGFloat _borderWidth;
    CGFloat _offset;
    BOOL _on;
}

@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *onColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *offColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *buttonColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *buttonBorderColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *borderColor;
@property (null_resettable, nonatomic, ss_strong) IBInspectable UIColor *shadowColor;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign, getter=isOn) IBInspectable BOOL on;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
