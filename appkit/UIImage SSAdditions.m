//
//  UIImage+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 25/11/15.
//
//

#import "UIImage+SSAdditions.h"
#import <graphics/SSColor.h>
#import <graphics/SSImage.h>

@implementation UIImage (SSAdditions)

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size {
    return [self imageWithCGImage:SSAutorelease(SSImageCreateWithColor(color.CGColor, size))];
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)imageURL {
    return [self initWithData:[[NSData alloc] initWithContentsOfURL:imageURL]];
}

- (NSData *)PNGRepresentation {
    return UIImagePNGRepresentation(self);
}

- (NSData *)JPEGRepresentation {
    return UIImageJPEGRepresentation(self, 1.0);
}

@end
