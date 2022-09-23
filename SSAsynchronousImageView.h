//
//  SSAsynchronousImageView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 27/08/14.
//
//

#import "SSImageView.h"
#if TARGET_OS_IPHONE
#import <foundation/SSImageProvider.h>
#else
#import <SSFoundation/SSImageProvider.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class SSAsynchronousImageView;

typedef void (^SSAsynchronousImageViewCompletionBlock)(__kindof SSAsynchronousImageView *imageView, __autoreleasing NSError * __nullable error);

NS_CLASS_AVAILABLE(10_6, 4_0)
@interface SSAsynchronousImageView : SSImageView {
@package
    NSURL *_imageURL;
    NSData *_imageData;
    SSImageProvider *_imageProvider;
    SSAsynchronousImageViewCompletionBlock _completionBlock;
}

@property (nullable, nonatomic, copy) NSURL *imageURL;
@property (nullable, nonatomic, readonly, copy) NSData *imageData;
@property (nonatomic, ss_strong) SSImageProvider *imageProvider;
@property (nullable, nonatomic, copy) SSAsynchronousImageViewCompletionBlock completionBlock;

@end

NS_ASSUME_NONNULL_END
