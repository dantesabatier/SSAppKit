//
//  NSSound+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 12/09/13.
//
//

#import <AppKit/NSSound.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSound (SSAdditions)

+ (nullable instancetype)alertSoundNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
