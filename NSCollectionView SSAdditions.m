//
//  NSCollectionView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/17.
//
//

#import "NSCollectionView+SSAdditions.h"

@implementation NSCollectionView (SSAdditions)

- (NSIndexSet *)selectionIndexesForSection:(NSInteger)section {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    [self.selectionIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.section == section) {
            [indexes addIndex:obj.item];
        }
    }];
    return indexes;
}

- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes forSection:(NSInteger)section {
    NSMutableArray <NSIndexPath*>*indexPaths = [NSMutableArray arrayWithCapacity:selectionIndexes.count];
    [selectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    NSSet <NSIndexPath *>*selectionIndexPaths = self.selectionIndexPaths;
    self.selectionIndexPaths = [NSSet setWithCollectionViewIndexPaths:indexPaths];
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemsAtIndexPaths:)]) {
        [self.delegate collectionView:self didSelectItemsAtIndexPaths:self.selectionIndexPaths];
    }
    if ([self.delegate respondsToSelector:@selector(collectionView:didDeselectItemsAtIndexPaths:)]) {
        [self.delegate collectionView:self didDeselectItemsAtIndexPaths:selectionIndexPaths];
    }
}

- (NSIndexSet *)visibleItemIndexesForSection:(NSInteger)section {
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    [self.indexPathsForVisibleItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.section == section) {
            [indexes addIndex:obj.item];
        }
    }];
    return indexes;
}

- (void)setVisibleItemIndexes:(NSIndexSet *)visibleItemIndexes forSection:(NSInteger)section {
    [self setSelectionIndexes:visibleItemIndexes forSection:section];
    if ([self selectionIndexesForSection:section].count) {
        [self scrollToItemsAtIndexPaths:self.selectionIndexPaths scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
    }
}

@end
