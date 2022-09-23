//
//  NSImage+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SSGraphics/SSImage.h>
#import <CoreImage/CIFilter.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage(SSAdditions)

- (instancetype)initWithCGImage:(CGImageRef)cgImage size:(CGSize)size resizingMethod:(SSRectResizingMethod)resizingMethod NS_AVAILABLE_MAC(10_6);
+ (instancetype)imageWithCGImage:(CGImageRef)cgImage NS_AVAILABLE_MAC(10_6);
@property (nullable, readonly) CGImageRef CGImage CF_RETURNS_NOT_RETAINED NS_AVAILABLE_MAC(10_6);
+ (instancetype)imageWithColor:(NSColor *)color size:(CGSize)size NS_AVAILABLE_MAC(10_6);
- (instancetype)imageByTintingToColor:(NSColor *)color;
- (instancetype)imageByApplyingFilters:(NSArray <CIFilter*> *)filters;
- (instancetype)imageByFillingVisibleAlphaWithColor:(NSColor *)fillColor;
- (instancetype)imageByScalingToSize:(CGSize)targetSize NS_AVAILABLE_MAC(10_6);
- (instancetype)imageByCroppingToSize:(CGSize)targetSize NS_AVAILABLE_MAC(10_6);
@property (readonly, ss_strong) NSImage *imageByConvertingToBlackAndWhite;
- (nullable instancetype)imageWithImageInterpolation:(NSImageInterpolation)interpolation;
@property (nullable, readonly, copy) NSBitmapImageRep *bitmapRepresentation;
- (nullable NSData *)bestRepresentationUsingType:(NSBitmapImageFileType)type;
@property (nullable, readonly, copy) NSData *PNGRepresentation;
@property (nullable, readonly, copy) NSData *JPEGRepresentation;
@property (nullable, readonly, copy) NSData *JPEG2000Representation;

@end


NS_ASSUME_NONNULL_END

