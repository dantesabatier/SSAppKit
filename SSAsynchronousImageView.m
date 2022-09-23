//
//  SSAsynchronousImageView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 27/08/14.
//
//

#import "SSAsynchronousImageView.h"

@interface SSAsynchronousImageView ()

@property (nullable, nonatomic, readwrite, copy) NSData *imageData;

@end

@implementation SSAsynchronousImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.imageURL = [coder decodeObjectForKey:@"imageURL"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.imageURL forKey:@"imageURL"];
}

- (void)dealloc {
    [_imageURL release];
    [_imageData release];
    [_imageProvider release];
    [_completionBlock release];
    [super ss_dealloc];
}

#pragma mark getters & setters

- (NSURL *)imageURL {
    return _imageURL;
}

- (void)setImageURL:(NSURL *)imageURL {
#if 0
    if ([self.imageURL isEqual:imageURL]) {
        return;
    }
#endif
    
    SSImageProvider *imageProvider = self.imageProvider;
    [imageProvider cancelRequestForURL:_imageURL];
    
    SSNonAtomicCopiedSet(_imageURL, imageURL);
    
    [self setImage:NULL imageProperties:nil];
    
    if (imageURL) {
        __ss_weak __typeof(_completionBlock) weakCompletionBlock = _completionBlock;
        [imageProvider provideCGImageAsynchronouslyForURL:imageURL completionHandler:^(CGImageRef image, NSData *imageData, NSDictionary *imageProperties, SSImageProviderResult result, NSError *error) {
            switch (result) {
                case SSImageProviderResultSucceeded:
                    [self setImage:image imageProperties:imageProperties];
                    self.imageData = imageData;
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
                [self setImage:image imageProperties:nil];
            } else {
                [weakImageProvider removeImageProviderObserver:observer];
            }
        }];
    } else {
        if (_completionBlock) {
            _completionBlock(self, nil);
        }
    }
}

- (SSImageProvider *)imageProvider {
    return _imageProvider ? _imageProvider : [SSImageProvider sharedImageProvider];
}

- (void)setImageProvider:(SSImageProvider *)imageProvider {
    SSAtomicRetainedSet(_imageProvider, imageProvider);
}

- (SSAsynchronousImageViewCompletionBlock)completionBlock {
    return _completionBlock;
}

- (void)setCompletionBlock:(SSAsynchronousImageViewCompletionBlock)completionBlock {
    SSNonAtomicCopiedSet(_completionBlock, completionBlock);
}

- (NSData *)imageData {
    return _imageData;
}

- (void)setImageData:(NSData *)imageData {
    SSNonAtomicCopiedSet(_imageData, imageData);
}

@end
