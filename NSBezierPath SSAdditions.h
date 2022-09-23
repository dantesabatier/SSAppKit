//
//  NSBezierPath+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath(SSAdditions)

@property (readonly) CGPathRef CGPath CF_RETURNS_NOT_RETAINED;
+ (instancetype)bezierPathWithRoundedRect:(CGRect)aRect corners:(SSRectCorner)corners radius:(CGFloat)radius;
+ (instancetype)bezierPathWithRoundedRect:(CGRect)aRect radius:(CGFloat)radius;
- (void)applyInnerShadow:(NSShadow *)shadow;
- (void)drawBlurWithColor:(NSColor *)color radius:(CGFloat)radius;
- (void)strokeInside;
- (void)strokeInsideWithinRect:(CGRect)clipRect;
- (void)appendBezierPathWithString:(NSString *)text inFont:(NSFont *)font;
+ (instancetype)bezierPathWithString:(NSString *)text inFont:(NSFont *)font;
+ (instancetype)bezierPathWithCGPath:(CGPathRef)pathRef;
- (instancetype)pathWithStrokeWidth:(CGFloat)strokeWidth;

@end

extern void SSDrawStringAlignedInFrame(NSString *text, NSFont *font, NSTextAlignment alignment, CGRect frame);


NS_ASSUME_NONNULL_END
