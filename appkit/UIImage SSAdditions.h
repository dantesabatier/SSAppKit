//
//  UIImage+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 25/11/15.
//
//

#import <UIKit/UIKit.h>
#import <base/SSGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SSAdditions)

+ (instancetype)imageWithColor:(UIColor *)color size:(CGSize)size;
- (nullable instancetype)initWithContentsOfURL:(NSURL *)imageURL;
@property (nullable, readonly, copy) NSData *PNGRepresentation;
@property (nullable, readonly, copy) NSData *JPEGRepresentation;

@end

NS_ASSUME_NONNULL_END
