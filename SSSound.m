//
//  SSSound.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/12/13.
//
//

#import "SSSound.h"
#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#import <foundation/NSBundle+SSAdditions.h>
#else
#import <SSFoundation/NSBundle+SSAdditions.h>
#endif

@interface SSSound () <AVAudioPlayerDelegate>

@property (nullable, copy) SSSoundCompletionBlock completionBlock;

@end

@implementation SSSound

+ (instancetype)soundNamed:(NSString *)name {
    //SSDebugLog(@"%@ %@\"%@\"", self.class, NSStringFromSelector(_cmd), name);
    return name.length ? [[[self.class alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForSoundResource:name] error:NULL] autorelease] : nil;
}

- (instancetype)initWithContentsOfURL:(NSURL *)URL error:(NSError **)outError {
    //SSDebugLog(@"%@ %@\"%@\"", self.class, NSStringFromSelector(_cmd), URL);
    NSParameterAssert(URL != nil);
    self = [super init];
    if (self) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:URL error:outError];
        _player.volume = 0.75;
        _player.delegate = self;
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[self.class allocWithZone:zone] initWithContentsOfURL:_player.url error:NULL];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [self initWithContentsOfURL:[coder decodeObjectForKey:@"url"] error:NULL];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_player.url forKey:@"url"];
}

- (void)dealloc {
    _player.delegate = nil;
    [_player release];
    [_completionBlock release];
    [super ss_dealloc];
}

- (void)play:(__nullable SSSoundCompletionBlock)completionBlock {
    if (_player.isPlaying) {
        return;
    }
    self.completionBlock = completionBlock;
    [self ss_retain];
    [_player play];
}

- (void)pause {
    [_player pause];
}

- (void)stop {
    [_player stop];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.completionBlock) {
        self.completionBlock(flag);
    }
    [self autorelease];
}

#pragma mark getters & setters

- (SSSoundCompletionBlock)completionBlock {
    return SSAtomicAutoreleasedGet(_completionBlock);
}

- (void)setCompletionBlock:(SSSoundCompletionBlock)completionBlock {
    SSAtomicCopiedSet(_completionBlock, completionBlock);
}

- (AVAudioPlayer *)player {
    return SSAtomicAutoreleasedGet(_player);
}

@end
