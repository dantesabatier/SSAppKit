//
//  SSCollectionView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 9/19/12.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSLayoutView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSCollectionViewDropOperation) {
    SSCollectionViewDropOn = 0,
    SSCollectionViewDropBefore = 1,
};

@class SSCollectionView;
@protocol SSCollectionViewDataSource <NSObject>

@optional
- (NSInteger)numberOfItemsInCollectionView:(SSCollectionView *)collectionView;
- (nullable id)collectionView:(SSCollectionView *)collectionView itemAtIndex:(NSInteger)index;

@end

@protocol SSCollectionViewDelegate <NSObject>

@optional
#if defined(__MAC_10_7)
- (nullable id <NSPasteboardWriting>)collectionView:(SSCollectionView *)collectionView pasteboardWriterForItemAtIndex:(NSInteger)index NS_AVAILABLE_MAC(10_7);
- (void)collectionView:(SSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexes:(NSIndexSet *)indexes NS_AVAILABLE_MAC(10_7);
- (void)collectionView:(SSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation NS_AVAILABLE_MAC(10_7);
- (BOOL)collectionView:(SSCollectionView *)collectionView ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session NS_AVAILABLE_MAC(10_7);
- (void)collectionView:(SSCollectionView *)collectionView updateDraggingItemsForDrag:(id <NSDraggingInfo>)draggingInfo NS_AVAILABLE_MAC(10_7);
#endif
- (nullable NSImage *)collectionView:(SSCollectionView *)collectionView draggingImageForItemAtIndex:(NSInteger)index;
- (nullable NSImage *)collectionView:(SSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset;
- (BOOL)collectionView:(SSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard;
- (NSDragOperation)collectionView:(SSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)info proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(SSCollectionViewDropOperation *)proposedDropOperation;
- (BOOL)collectionView:(SSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)info index:(NSInteger)index dropOperation:(SSCollectionViewDropOperation)dropOperation;
- (BOOL)collectionView:(SSCollectionView *)collectionView moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSInteger)destinationIndex;
- (void)collectionView:(SSCollectionView *)collectionView backgroundWasRightClickedWithEvent:(NSEvent *)event;
- (BOOL)collectionView:(SSCollectionView *)collectionView shouldTypeSelectForEvent:(NSEvent *)event withCurrentSearchString:(NSString *)searchString;
- (nullable NSString *)collectionView:(SSCollectionView *)collectionView typeSelectStringForItemAtIndex:(NSInteger)index;
- (void)collectionViewSelectionDidChange:(SSCollectionView *)collectionView;

@end

NS_CLASS_AVAILABLE(10_6, NA)
@interface SSCollectionView : SSLayoutView
#if defined(__MAC_10_7)
<NSUserInterfaceValidations, NSDraggingSource, NSDraggingDestination>
#else
<NSUserInterfaceValidations>
#endif 
{
@private
    NSMutableDictionary *_cachedItems;
    NSMutableDictionary *_visibleItems;
    NSMutableIndexSet *_visibleItemIndexes;
    NSPoint _initialMousePosition;
    CGRect _previousVisibleRect;
    SSCollectionViewDropOperation _currentDropOperation;
    NSArray *_content;
    NSIndexSet *_selectionIndexes;
    NSArray <NSColor *>*_backgroundColors;
    NSCollectionViewItem *_itemPrototype;
    CGFloat _minimumLineSpacing;
    CGFloat _minimumInteritemSpacing;
    CGFloat _interitemSpacing;
    CGSize _itemSize;
    NSInteger _currentDropIndex;
    NSInteger _numberOfItems;
    NSInteger _numberOfColumns;
    NSInteger _numberOfRows;
    NSInteger _maxNumberOfColumns;
    NSInteger _maxNumberOfRows;
    CGFloat _zoomValue;
    struct {
        unsigned int isFirstResponder:1;
        unsigned int allowsMultipleSelection:1;
        unsigned int allowsEmptySelection:1;
        unsigned int allowsReordering:1;
        unsigned int allowsTypeSelect:1;
        unsigned int animates:1;
        unsigned int animationsAreExplicitlyDisabled:1;
        unsigned int zooming:1;
        unsigned int selectable:1;
        unsigned int dragging:1;
        unsigned int draggingRubberBand:1;
        unsigned int unarchiving:1;
        unsigned int usesAlternatingBackgroundColors;
        unsigned int dataSourceRespondsToNumberOfItems:1;
        unsigned int dataSourceRespondsToItemAtIndex:1;
        unsigned int delegateRespondsToPasteboardWriter:1;
        unsigned int delegateRespondsToDraggingSessionWillBegin:1;
        unsigned int delegateRespondsToDraggingSessionEnded:1;
        unsigned int delegateRespondsToIgnoreModifierKeys:1;
        unsigned int delegateRespondsToUpdateDraggingItems:1;
        unsigned int delegateRespondsToWriteItems:1;
        unsigned int delegateRespondsToDraggingImageForItem:1;
        unsigned int delegateRespondsToDraggingImageForItems:1;
        unsigned int delegateRespondsToValidateDrop:1;
        unsigned int delegateRespondsToAcceptDrop:1;
        unsigned int delegateRespondsToMoveItems:1;
        unsigned int delegateRespondsToBackgroundWasRightClicked:1;
        unsigned int delegateShouldTypeSelectForEvent:1;
        unsigned int delegateTypeSelectStringForItemAtIndex:1;
        unsigned int delegateRespondsToSelectionDidChange:1;
    } _flags;
    SEL _action;
    __ss_weak id _target;
    __ss_weak id <SSCollectionViewDataSource> _dataSource;
    __ss_weak id <SSCollectionViewDelegate> _delegate;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSCollectionViewDataSource> dataSource;
@property (nullable, nonatomic, ss_weak) IBOutlet id <SSCollectionViewDelegate> delegate;
@property (nullable, nonatomic, ss_weak) id target;
@property (nullable) SEL action;
@property (nullable, nonatomic, copy) IBOutlet NSCollectionViewItem *itemPrototype;
@property (nullable, nonatomic, copy) NSArray *content;
@property (nonatomic, ss_strong) NSIndexSet *selectionIndexes;
@property (nonatomic, readonly, ss_strong) NSIndexSet *visibleItemIndexes;
@property (nonatomic, copy) NSArray <NSColor*> *backgroundColors;
@property (nonatomic, assign) CGFloat zoomValue;
#if NS_BLOCKS_AVAILABLE
- (void)setZoomValue:(CGFloat)zoomValue animated:(BOOL)animated completion:(void(^__nullable)(void))completion NS_AVAILABLE(10_6, 5_0);
- (void)setZoomValue:(CGFloat)zoomValue animated:(BOOL)animated NS_AVAILABLE(10_6, 5_0);
#endif
@property (nonatomic, assign) CGFloat minimumLineSpacing;
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;
@property (nonatomic, assign) NSInteger maxNumberOfColumns;
@property (nonatomic, assign) NSInteger maxNumberOfRows;
@property (nonatomic, assign) BOOL animates;
@property (nonatomic, assign) BOOL allowsMultipleSelection;
@property (nonatomic, assign) BOOL allowsEmptySelection;
@property (nonatomic, assign) BOOL allowsReordering;
@property (nonatomic, assign) BOOL allowsTypeSelect NS_AVAILABLE(10_7, NA);
@property (nonatomic, assign, getter = isSelectable) BOOL selectable;
@property (nonatomic, readonly, getter=isFirstResponder) BOOL firstResponder;
@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (nonatomic, readonly) NSInteger numberOfRows;
@property (nonatomic, readonly) CGSize cellSize;
- (IBAction)selectAll:(nullable id)sender;
- (IBAction)deselectAll:(nullable id)sender;
- (IBAction)zoomIn:(nullable id)sender;
- (IBAction)zoomOut:(nullable id)sender;
- (void)scrollIndexToVisible:(NSInteger)index;
- (NSInteger)indexOfItemAtPoint:(NSPoint)point;
- (CGRect)frameForItemAtIndex:(NSInteger)index;
- (nullable NSCollectionViewItem *)newItemForRepresentedObject:(id)object;
- (nullable NSCollectionViewItem *)reusableItemForRepresentedObject:(id)object;
- (nullable NSCollectionViewItem *)itemAtIndex:(NSInteger)index;
- (nullable NSImage *)draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset;

@end

NS_ASSUME_NONNULL_END
