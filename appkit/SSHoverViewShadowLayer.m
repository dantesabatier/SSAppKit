//
//  SSHoverViewShadowLayer.m
//  SSAppKit
//
//  Created by Dante Sabatier on 15/12/16.
//
//

#import "SSHoverViewShadowLayer.h"
#import "UIView+SSAdditions.h"

@implementation SSHoverViewShadowLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        CAShapeLayer *masklayer = [CAShapeLayer layer];
        masklayer = masklayer;
        masklayer.fillRule = kCAFillRuleEvenOdd;
        masklayer.fillColor = [UIColor blackColor].CGColor;
        self.mask = masklayer;
        self.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    super.cornerRadius = cornerRadius;
    [self updateShadowPathAndMask];
}

- (void)layoutSublayers {
    [super layoutSublayers];
    [self updateShadowPathAndMask];
}

- (nonnull UIBezierPath *)bezierPathForShadow {
    return [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.cornerRadius];
}

- (void)updateShadowPathAndMask {
    UIBezierPath *shadowPath = [self bezierPathForShadow];
    
    self.shadowPath = [shadowPath CGPath];
    // using the even odd fill rule we create a path that includes the shadow which contains a path that excludes this layer's shadow path
    CGFloat outsetForShadow = -1 * (fabs(self.shadowOffset.height) + fabs(self.shadowOffset.width) + self.shadowRadius * 2.0);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(outsetForShadow, outsetForShadow, outsetForShadow, outsetForShadow))];
    [maskPath appendPath:shadowPath];
    self.mask.frame = self.bounds;
    ((CAShapeLayer *)self.mask).path = maskPath.CGPath;
}

@end
