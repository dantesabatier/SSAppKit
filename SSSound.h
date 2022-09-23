//
//  SSSound.h
//  SSAppKit
//
//  Created by Dante Sabatier on 17/12/13.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSSoundCompletionBlock)(BOOL success);

NS_CLASS_AVAILABLE(10_7, 5_0)
@interface SSSound : NSObject <NSCopying, NSCoding> {
@private
    AVAudioPlayer *_player;
    SSSoundCompletionBlock _completionBlock;
}

- (nullable instancetype)initWithContentsOfURL:(NSURL *)URL error:(NSError **)outError;
+ (nullable instancetype)soundNamed:(NSString *)name;
@property (readonly, ss_strong) AVAudioPlayer *player;
- (void)play:(__nullable SSSoundCompletionBlock)completionBlock;
- (void)pause;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
