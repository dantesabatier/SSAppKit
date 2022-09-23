//
//  NSImage+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "NSImage+SSAdditions.h"

@implementation NSImage(SSAdditions)

#if defined(__MAC_10_6)

- (instancetype)initWithCGImage:(CGImageRef)cgImage size:(CGSize)size resizingMethod:(SSRectResizingMethod)resizingMethod {
    if (!cgImage) {
        return nil;
    }
    
    CGSize imageSize = SSImageGetSize(cgImage);
    if (!CGSizeEqualToSize(imageSize, size)) {
        cgImage = SSAutorelease(SSImageCreateCopyWithSize(cgImage, size, resizingMethod));
    }
    
    if (!cgImage) {
        return nil;
    }
    return [self initWithCGImage:cgImage size:size];
}

+ (instancetype)imageWithCGImage:(CGImageRef)cgImage {
	return [[[self.class alloc] initWithCGImage:cgImage size:SSImageGetSize(cgImage) resizingMethod:SSRectResizingMethodScale] autorelease];
}

- (CGImageRef)CGImage {
	return [self CGImageForProposedRect:NULL context:nil hints:nil];
}

+ (instancetype)imageWithColor:(NSColor *)color size:(CGSize)size {
    return [self imageWithCGImage:SSAutorelease(SSImageCreateWithColor(color.CGColor, size))];
}

#endif

- (instancetype)imageWithImageInterpolation:(NSImageInterpolation)interpolation {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGRect bounds = SSRectMakeWithSize(self.size);
	NSImageRep *imageRep = [self bestRepresentationForRect:bounds context:context hints:nil];
	if (!imageRep) {
		NSLog(@"Warning!, %@ %@, image representation not found!…", self.class, NSStringFromSelector(_cmd));
		return self;
	}
	
	NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
	[image lockFocus];
	
    context.imageInterpolation = interpolation;
	[imageRep drawInRect:bounds];
	
	[image unlockFocus];
	
	return [image autorelease];
}

- (NSBitmapImageRep *)bitmapRepresentation {
	return [[[NSBitmapImageRep alloc] initWithData:self.TIFFRepresentation] autorelease];
}

- (NSData *)PNGRepresentation {
	return [self bestRepresentationUsingType:NSPNGFileType];
}

- (NSData *)JPEGRepresentation {
	return [self bestRepresentationUsingType:NSJPEGFileType];
}

- (NSData *)JPEG2000Representation {
	return [self bestRepresentationUsingType:NSJPEG2000FileType];
}

- (NSData *)bestRepresentationUsingType:(NSBitmapImageFileType)type {
    NSDictionary *properties = nil;
    switch (type) {
        case NSJPEGFileType:
        case NSJPEG2000FileType:
            properties = @{NSImageCompressionFactor: @1.0};
            break;
        default:
            break;
    }
    return [[self imageWithImageInterpolation:NSImageInterpolationHigh].bitmapRepresentation representationUsingType:type properties:properties];
}

- (instancetype)imageByTintingToColor:(NSColor *)color {
	CGSize size = self.size;
    CGRect imageRect = SSRectMakeWithSize(size);
	NSImage *image = [[NSImage alloc] initWithSize:size];
    
	[image lockFocus];
    
    [self drawInRect:imageRect fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
	[color set];
    
	NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
    
	[image unlockFocus];  
	
	return [image autorelease];
}

- (instancetype)imageByApplyingFilters:(NSArray *)filters {
	CIImage *img = [CIImage imageWithData:self.TIFFRepresentation];
    for (CIFilter *filter in filters) {
        [filter setValue:img forKey:kCIInputImageKey];
        
        img = [filter valueForKey:kCIOutputImageKey];
    }
    
    NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:[NSCIImageRep imageRepWithCIImage:img]];
    
	return [image autorelease];
}

- (instancetype)imageByFillingVisibleAlphaWithColor:(NSColor *)fillColor {
    return [self imageByApplyingFilters:@[[CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputColor0", [[[CIColor alloc] initWithColor:fillColor] autorelease], @"inputColor1", [[[CIColor alloc] initWithColor:fillColor] autorelease], nil]]];
}

- (instancetype)imageByConvertingToBlackAndWhite {
    return [self imageByApplyingFilters:@[[CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:@"inputColor", [[[CIColor alloc] initWithColor:[NSColor whiteColor]] autorelease], @"inputIntensity", @1.0, nil]]];
}

#if defined(__MAC_10_6)

- (instancetype)imageByScalingToSize:(CGSize)targetSize {
	return [NSImage imageWithCGImage:SSAutorelease(SSImageCreateCopyWithSize(self.CGImage, targetSize, SSRectResizingMethodScale))];
}

- (instancetype)imageByCroppingToSize:(CGSize)targetSize {
	return [NSImage imageWithCGImage:SSAutorelease(SSImageCreateCopyWithSize(self.CGImage, targetSize, SSRectResizingMethodCrop))];
}

#endif

@end
