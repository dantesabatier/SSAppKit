//
//  NSApplication+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/29/12.
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSApplication (SSAdditions)

@property (nullable, readonly, copy) NSImage *applicationIcon;
- (nullable NSImage *)applicationAlertCautionIconImageOfSize:(CGSize)iconSize;
@property (nullable, readonly, copy) NSImage *applicationAlertCautionIconImage;
#if NS_BLOCKS_AVAILABLE
- (void)beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock:(void (^ __nullable)(NSInteger returnCode))block NS_DEPRECATED_MAC(10_6, 10_9);
#endif

@end

NS_ASSUME_NONNULL_END
