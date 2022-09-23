//
//  UIColor+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/13.
//
//

#import <UIKit/UIKit.h>
#import <base/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (SSAdditions)

+ (instancetype)colorWithString:(NSString *)representation;
+ (instancetype)colorWithPatternImage:(UIImage *)image scale:(CGFloat)scale;
@property (nullable, readonly, copy) NSString *stringRepresentation;
@property (nullable, readonly, copy) NSString *hexadecimalStringValue;
@property (class, readonly, copy) UIColor *randomColor;

@end

NS_ASSUME_NONNULL_END
