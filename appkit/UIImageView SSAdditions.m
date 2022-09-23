//
//  UIImageView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 06/11/16.
//
//

#import "UIImageView+SSAdditions.h"
#import <foundation/NSObject+SSAdditions.h>

@implementation UIImageView (SSAdditions)

- (NSURL *)imageURL {
    return [self associatedValueForKey:@"imageURL"];
}

- (void)setImageURL:(NSURL *)imageURL {
#if 0
    if ([self.imageURL isEqual:imageURL])
        return;
#endif
    
    SSImageProvider *imageProvider = [self valueForKey:@"imageProvider"];
    
    [imageProvider cancelRequestForURL:self.imageURL];
    
    [self setAtomicCopiedAssociatedValue:imageURL forKey:@"imageURL"];
    
    UIImageViewAsynchronousImageLoadingCompletionBlock completionBlock = [self associatedValueForKey:@"completionBlock"];
    if (imageURL) {
        __ss_weak __typeof(completionBlock) weakCompletionBlock = completionBlock;
        [imageProvider provideCGImageAsynchronouslyForURL:imageURL completionHandler:^(CGImageRef image, NSData *imageData, NSDictionary *imageProperties, SSImageProviderResult result, NSError *error) {
            switch (result) {
                case SSImageProviderResultSucceeded:
                    self.image = [UIImage imageWithData:imageData];
                    break;
                default:
                    break;
            }
            
            if (weakCompletionBlock) {
                weakCompletionBlock(self, error);
            }
        }];
        
        __ss_weak __typeof(imageProvider) weakImageProvider = imageProvider;
        __block __unsafe_unretained id observer = [imageProvider addImageProviderObserverForURL:imageURL queue:nil usingBlock:^(CGImageRef image, CGSize imageSize, SSImageProviderState state, long long loadedImageLength, long long expectedImageLength) {
            if (loadedImageLength < expectedImageLength) {
                self.image = [UIImage imageWithCGImage:image];
            } else {
                [weakImageProvider removeImageProviderObserver:observer];
            }
        }];
    } else {
        if (completionBlock) {
            completionBlock(self, nil);
        }
    }
}

- (UIImageViewAsynchronousImageLoadingCompletionBlock)completionBlock {
    return [self associatedValueForKey:@"completionBlock"];
}

- (void)setCompletionBlock:(UIImageViewAsynchronousImageLoadingCompletionBlock)completionBlock {
    [self setAtomicCopiedAssociatedValue:completionBlock forKey:@"completionBlock"];
}

- (SSImageProvider *)imageProvider {
    SSImageProvider *imageProvider = [self associatedValueForKey:@"imageProvider"];
    if (!imageProvider) {
        imageProvider = [SSImageProvider sharedImageProvider];
    }
    return imageProvider;
}

- (void)setImageProvider:(SSImageProvider * _Nullable)imageProvider {
    [self setAssociatedValue:imageProvider forKey:@"imageProvider"];
}

@end
