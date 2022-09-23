//
//  NSMenu+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMenu(SSAdditions)

#if !defined(__MAC_10_6)
- (void)removeAllItems;
#endif

@end

extern NSMenu *SSApplicationMenu(void);
extern NSMenu *SSFileMenu(void);
extern NSMenu *SSEditMenu(void);
extern NSMenu *SSViewMenu(void);
extern NSMenu *SSHelpMenu(void);

NS_ASSUME_NONNULL_END

