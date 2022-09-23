//
//  NSAlert+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 9/13/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAlert (SSAdditions)

#if NS_BLOCKS_AVAILABLE
#if !defined(__MAC_10_9)
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:((void (^ __nullable)(NSInteger returnCode))handler NS_AVAILABLE(10_6, N_A);
#endif
#endif

@end

#if NS_BLOCKS_AVAILABLE
extern void SSBeginAlertSheet(NSString *title, NSString *defaultButton, NSString * __nullable alternateButton, NSString * __nullable otherButton, NSWindow *docWindow, void (^ __nullable completionHandler)(NSInteger returnCode), NSString * __nullable msgFormat, ...)  NS_AVAILABLE(10_6, N_A);
#endif

NS_ASSUME_NONNULL_END
