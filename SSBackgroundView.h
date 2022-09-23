//
//  SSBackgroundView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/28/12.
//
//

#import "SSView.h"
#if TARGET_OS_IPHONE
#import <base/SSGeometry.h>
#else
#import <SSBase/SSGeometry.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSBackgroundView : SSView {
@package
    CGColorRef _fillColor;
    CGColorRef _borderColor;
    SSRectCorner _rectCorners;
    CGFloat _cornerRadius;
    CGFloat _borderWidth;
}

@property (nullable, nonatomic) CGColorRef fillColor;
@property (nullable, nonatomic) CGColorRef borderColor;
@property (nonatomic, assign) SSRectCorner rectCorners;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nullable, nonatomic, assign, readonly) CGPathRef path;

@end

NS_ASSUME_NONNULL_END

