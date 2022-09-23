//
//  NSCollectionView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/17.
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCollectionView (SSAdditions)

- (NSIndexSet *)selectionIndexesForSection:(NSInteger)section;
- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes forSection:(NSInteger)section;
- (NSIndexSet *)visibleItemIndexesForSection:(NSInteger)section;
- (void)setVisibleItemIndexes:(NSIndexSet *)visibleItemIndexes forSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
