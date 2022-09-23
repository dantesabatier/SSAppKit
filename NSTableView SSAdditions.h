//
//  NSTableView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/13.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

enum {
    SSTableViewRowNotFound = -1
};

typedef NS_ENUM(NSInteger, SSTableViewRowSizeStyle) {
#if defined(__MAC_10_7)
    SSTableViewRowSizeStyleDefault = NSTableViewRowSizeStyleDefault,
    SSTableViewRowSizeStyleCustom = NSTableViewRowSizeStyleCustom,
    SSTableViewRowSizeStyleSmall = NSTableViewRowSizeStyleSmall,
    SSTableViewRowSizeStyleMedium = NSTableViewRowSizeStyleMedium,
    SSTableViewRowSizeStyleLarge = NSTableViewRowSizeStyleLarge,
#else
    SSTableViewRowSizeStyleDefault = -1,
    SSTableViewRowSizeStyleCustom = 0,
    SSTableViewRowSizeStyleSmall = 1,
    SSTableViewRowSizeStyleMedium = 2,
    SSTableViewRowSizeStyleLarge = 3,
#endif
};

@interface NSTableView (SSAdditions)

@property (nullable, readonly, ss_weak) NSArrayController *contentController;

@end

extern CGSize SSTableViewGetProposedCellImageSizeForRowStyle(NSTableView *self, SSTableViewRowSizeStyle rowSizeStyle);
extern CGSize SSTableViewGetProposedCellImageSize(NSTableView *self);
extern BOOL SSTableViewMouseDownInButtonRect(NSTableView *self);
extern BOOL SSTableViewMouseDownInImageRect(NSTableView *self);

NS_ASSUME_NONNULL_END
