//
//  UIImageView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 06/11/16.
//
//

#import "UIView+SSAdditions.h"
#import "UIImage+SSAdditions.h"
#import <foundation/SSImageProvider.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^UIImageViewAsynchronousImageLoadingCompletionBlock)(UIImageView *imageView, __autoreleasing NSError * __nullable error);

@interface UIImageView (SSAdditions)

@property (nullable, nonatomic, copy) NSURL *imageURL;
@property (nullable, nonatomic, copy) UIImageViewAsynchronousImageLoadingCompletionBlock completionBlock;
@property (nullable, nonatomic, strong) SSImageProvider *imageProvider;

@end

NS_ASSUME_NONNULL_END
