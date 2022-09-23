//
//  SSLayoutView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 9/19/12.
//
//

#import <TargetConditionals.h>
#import "SSView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSLayoutView : SSView {
@private
    BOOL _needsLayout;
}

#if (!TARGET_OS_IPHONE && !defined(__MAC_10_7)) || TARGET_OS_IPHONE
@property (nonatomic, assign) BOOL needsLayout;
- (void)layout;
#endif
#if !TARGET_OS_IPHONE
- (void)setNeedsLayout;
- (CGSize)sizeThatFits:(CGSize)size;
- (void)sizeToFit;
#endif
- (void)layoutIfNeeded;

@end

NS_ASSUME_NONNULL_END
