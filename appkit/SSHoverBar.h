//
//  SSHoverBar.h
//  SSAppKit
//
//  Created by Dante Sabatier on 11/01/16.
//
//

#import "UIView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@class SSHoverViewShadowLayer;
@class SSHoverViewSeparatorView;

typedef NS_ENUM (NSInteger, SSHoverBarOrientation) {
    SSHoverBarOrientationVertical,
    SSHoverBarOrientationHorizontal,
};

IB_DESIGNABLE
@interface SSHoverBar : UIView {
@private
    NSArray<UIBarButtonItem *> *_items;
    NSArray<UIControl *> *_controls;
    UIVisualEffectView *_backgroundView;
    SSHoverViewSeparatorView *_separatorView;
    SSHoverViewShadowLayer *_shadowLayer;
    SSHoverBarOrientation _orientation;
}

@property (nullable, nonatomic, copy) IBOutlet NSArray<UIBarButtonItem *> *items;
@property (nonatomic, assign) SSHoverBarOrientation orientation;
@property (nullable, nonatomic, ss_strong) UIVisualEffect *effect;
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nullable, nonatomic, ss_strong) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable CGFloat shadowRadius;
@property (nonatomic, assign) IBInspectable CGFloat shadowOpacity;
@property (nullable, nonatomic, ss_strong) IBInspectable UIColor *shadowColor;

@end

NS_ASSUME_NONNULL_END
