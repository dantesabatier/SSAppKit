//
//  NSColor+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor(SSAdditions)

@property (readonly, copy) NSColor *contrastingLabelColor;
+ (instancetype)colorWithString:(NSString *)representation;
@property (nullable, readonly, copy) NSString *stringRepresentation;
@property (nullable, readonly, copy) NSString *hexadecimalStringValue;
#if !defined(__MAC_10_8)
+ (instancetype)colorWithCGColor:(CGColorRef)cgColor;
@property (readonly) CGColorRef CGColor NS_RETURNS_INNER_POINTER;
#endif
+ (instancetype)sourceListViewBackgroundColor;
+ (instancetype)defaultAlternateSelectedControlColor;
+ (instancetype)texturedHeaderTextColor;
- (void)drawPixelThickLineAtPosition:(int)posInPixels withInset:(int)insetInPixels inRect:(CGRect)aRect inView:(NSView *)view horizontal:(BOOL)isHorizontal flip:(BOOL)shouldFlip;
@property (class, readonly, copy) NSColor *randomColor;

@end

NS_ASSUME_NONNULL_END
