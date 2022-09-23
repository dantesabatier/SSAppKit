//
//  NSViewController+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 02/12/14.
//
//

#import <AppKit/NSViewController.h>
#import <SSBase/SSDefines.h>

@class NSPopover;

NS_ASSUME_NONNULL_BEGIN

@interface NSViewController (SSAdditions)

@property (nullable, nonatomic, readonly, unsafe_unretained) NSPopover *popover NS_AVAILABLE_MAC(10_7);

@end

NS_ASSUME_NONNULL_END
