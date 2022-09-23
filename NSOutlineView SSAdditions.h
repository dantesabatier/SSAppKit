//
//  NSOutlineView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/13.
//
//

#import <AppKit/NSOutlineView.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSOutlineView (SSAdditions)

@property (nullable, nonatomic, readonly, ss_strong) id clickedItem;
@property (nullable, nonatomic, ss_strong) id selectedItem;
@property (nullable, nonatomic, ss_strong) NSArray *selectedItems;
@property (nullable, nonatomic, readonly, ss_weak) NSTreeController *contentController;
@property (nullable, nonatomic, readonly, ss_strong) NSMenu *sourceMenu;
- (NSArray *)itemsAtRowsWithIndexes:(NSIndexSet *)indexes;

@end

NS_ASSUME_NONNULL_END
