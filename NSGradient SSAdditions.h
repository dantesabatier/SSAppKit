//
//  NSGradient+SSAdditions.h
//  LabelTest
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSGradient(SSAdditions)

@property (readonly) CGGradientRef CGGradient CF_RETURNS_NOT_RETAINED;
+ (instancetype)tableHeaderViewBackgroundGradientAsKey:(BOOL)isKey;
+ (instancetype)sourceListBackgroundGradientAsKey:(BOOL)isKey;
+ (instancetype)gradientWithBaseColor:(NSColor *)color;
+ (instancetype)gradientByGettingColorsFromImage:(NSImage *)image;
+ (instancetype)gradientByGettingColorsFromImage:(NSImage *)image vertically:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
