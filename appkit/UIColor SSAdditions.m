//
//  UIColor+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/13.
//
//

#import "UIColor+SSAdditions.h"
#import <graphics/SSColor.h>

@implementation UIColor (SSAdditions)

+ (instancetype)colorWithString:(NSString *)representation {
    return [UIColor colorWithCIColor:[CIColor colorWithString:representation]];
}

+ (instancetype)colorWithPatternImage:(UIImage *)image scale:(CGFloat)scale {
    return [UIColor colorWithCGColor:SSAutorelease(SSColorCreateWithPatternImage(CGImageCreateCopy(image.CGImage), scale))];
}

- (NSString *)stringRepresentation {
    return SSColorGetStringRepresentation(self.CGColor);
}

- (NSString *)hexadecimalStringValue {
    return SSColorGetHexadecimalStringRepresentation(self.CGColor);
}

+ (instancetype)randomColor {
    return [UIColor colorWithHue:(arc4random() % 256/256.0) saturation:(( arc4random() % 128/256.0 ) + 0.5) brightness:((arc4random() % 128/256.0 ) + 0.5) alpha:1.0];
}

@end
