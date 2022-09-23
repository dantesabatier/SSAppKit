//
//  SSCollectionView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 9/19/12.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSCollectionView.h"
#import "SSRubberBandView.h"
#import "NSWindow+SSAdditions.h"
#import "NSScrollView+SSAdditions.h"
#import <Carbon/Carbon.h>
#import <SSGraphics/SSColorSpace.h>
#import <SSGraphics/SSContext.h>
#import <SSBase/SSGeometry.h>
#import <SSGraphics/SSImage.h>
#import <SSFoundation/NSArray+SSAdditions.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSString+SSAdditions.h>
#import <SSFoundation/NSTimer+SSAdditions.h>
#import <SSQuartz/SSQuartzDefines.h>
#import <QuartzCore/CAMediaTimingFunction.h>

NSString *const CollectionViewSelectionDidChangeNotification = @"CollectionViewSelectionDidChangeNotification";

#define kCVRubberBandViewTag 63649
#define kCVCellMinimumHeight ((CGFloat) 90.0)

#define __CHANGE_SUBVIEWS_SELECTION_STATE 1
#define __ADJUST_SUBVIEWS_WIDTH 1
#define __REMOVE_SUBVIEWS 0

@interface SSCollectionView ()
#if defined(__MAC_10_7)
<NSDraggingSource, NSDraggingDestination>
#endif

@end

@implementation SSCollectionView

+ (void)initialize {
    if (self == SSCollectionView.class) {
        [self exposeBinding:NSContentBinding];
        [self exposeBinding:NSSelectionIndexesBinding];
    }
}

+ (BOOL)isCompatibleWithResponsiveScrolling {
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _flags.selectable = 1;
        _flags.allowsEmptySelection = 1;
        _flags.allowsMultipleSelection = 1;
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            _flags.allowsTypeSelect = 1;
        }
#endif
        _zoomValue = 0.0;
        _numberOfItems = 0;
        _minimumInteritemSpacing = 0.0;
        _minimumLineSpacing = 0.0;
        _backgroundColors = [[NSArray alloc] initWithObjects:[NSColor whiteColor], nil];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.selectable = [coder decodeObjectForKey:@"selectable"] ? [coder decodeBoolForKey:@"selectable"] : YES;
        self.allowsMultipleSelection = [coder decodeObjectForKey:@"allowsMultipleSelection"] ? [coder decodeBoolForKey:@"allowsMultipleSelection"] : YES;
        self.allowsEmptySelection = [coder decodeObjectForKey:@"allowsEmptySelection"] ? [coder decodeBoolForKey:@"allowsEmptySelection"] : YES;
        self.allowsReordering = [coder decodeBoolForKey:@"allowsReordering"];
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.allowsTypeSelect = [coder decodeObjectForKey:@"allowsTypeSelect"] ? [coder decodeBoolForKey:@"allowsTypeSelect"] : YES;
        }   
#endif
        _zoomValue = 0.0;
        _numberOfItems = 0;
        _minimumInteritemSpacing = 0.0;
        _minimumLineSpacing = 0.0;
        _backgroundColors = [[NSArray alloc] initWithObjects:[NSColor whiteColor], nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeBool:self.selectable forKey:@"selectable"];
    [coder encodeBool:self.allowsTypeSelect forKey:@"allowsTypeSelect"];
    [coder encodeBool:self.allowsReordering forKey:@"allowsReordering"];
    [coder encodeBool:self.allowsMultipleSelection forKey:@"allowsMultipleSelection"];
    [coder encodeBool:self.allowsEmptySelection forKey:@"allowsEmptySelection"];
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
    _action = NULL;
    _target = nil;
    
    [_cachedItems release];
    [_visibleItems release];
    [_visibleItemIndexes release];
    [_itemPrototype release];
    [_selectionIndexes release];
    [_backgroundColors release];
    
    [super ss_dealloc];
}

- (void)prepareForInterfaceBuilder {
    _backgroundColors = [[NSArray alloc] initWithObjects:[NSColor whiteColor], nil];
}

- (void)drawRect:(CGRect)rect {
    NSArray *backgroundColors = self.backgroundColors;
    if (backgroundColors.count) {
        [NSGraphicsContext saveGraphicsState];
        [backgroundColors[0] setFill];
        NSRectFill(rect);
        if (backgroundColors.count > 1) {
            NSArray *numbers = @[@"0", @"2", @"4", @"6", @"8"];
            for (NSNumber *number in _visibleItems.allKeys) {
                @autoreleasepool {
                    CGRect frame = [self frameForItemAtIndex:number.integerValue];
                    if ([self needsToDrawRect:frame]) {
                        [numbers containsObject:number.stringValue.charactersAsComponents.lastObject] ? [(NSColor *)backgroundColors[0] setFill] : [(NSColor *)backgroundColors[1] setFill];
                        NSRectFill(frame);
                    }
                }
            }
        }
        [NSGraphicsContext restoreGraphicsState];
    }
}

#pragma mark layout

- (void)layout {
    [super layout];
    [self sizeToFit];
    //[self scrollRectToVisible:_previousVisibleRect];
    //[self centerSelectionInVisibleArea:nil];
    [self layoutItems];
    [self removeInvisibleItems];
    [self addMissingItems];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize contentSize = self.enclosingScrollView.frame.size;
    if (SSSizeIsEmpty(contentSize)) {
        contentSize = self.bounds.size;
    }
    
    CGRect bounds = self.bounds;
    CGSize cellSize = self.cellSize;
    CGSize intercellSpacing = self.intercellSpacing;
    if (self.enclosingScrollView.hasHorizontalScroller) {
        bounds.size.width = MAX(CEIL(cellSize.width + (intercellSpacing.width*(CGFloat)2.0)), contentSize.width);
    }
    
    CGFloat availableSpace = CGRectGetWidth(bounds) - (intercellSpacing.width*(CGFloat)2.0);
    _numberOfColumns = (NSInteger)MAX(MIN(FLOOR(availableSpace/(cellSize.width + intercellSpacing.width)), _numberOfItems), 1);
    if (_maxNumberOfColumns) {
        _numberOfColumns = MIN(_numberOfColumns, _maxNumberOfColumns);
    }
    
    _numberOfRows = (NSInteger)CEIL((double)_numberOfItems/(double)_numberOfColumns);
    
    if (_maxNumberOfRows && (_numberOfRows >= _maxNumberOfRows)) {
        _numberOfColumns = MAX((NSInteger)MIN(CEIL((double)_numberOfItems/(double)_maxNumberOfRows), _numberOfItems), 1);
        _numberOfRows = _maxNumberOfRows;
    }
    
    _interitemSpacing = FABS((availableSpace - (_numberOfColumns * cellSize.width)) / _numberOfColumns);
    
    if (self.enclosingScrollView.hasHorizontalScroller) {
        CGRect maxXBounds = [self frameForItemAtIndex:_numberOfColumns-1];
        contentSize.width = MAX(MAX(FLOOR(CGRectGetWidth(maxXBounds) + (intercellSpacing.width*(CGFloat)2.0)), contentSize.width), FLOOR(CGRectGetMaxX(maxXBounds) + intercellSpacing.width));
    }
    
    contentSize.height = MAX(FLOOR((_numberOfRows * (cellSize.height + intercellSpacing.height)) + intercellSpacing.height), contentSize.height);
    
    return contentSize;
}

#pragma mark items

- (void)layoutItems {
    [_visibleItems enumerateKeysAndObjectsUsingBlock:^(NSNumber *number, NSCollectionViewItem *item, BOOL *stop) {
        item.view.frame = [self frameForItemAtIndex:number.integerValue];
    }];
}

- (void)removeInvisibleItems {
    NSRange visibleItemsRange = self.visibleItemsRange;
    NSDictionary *items = [[_visibleItems copy] autorelease];
    [items enumerateKeysAndObjectsUsingBlock:^(NSNumber *number, NSCollectionViewItem *item, BOOL *stop) {
        NSInteger idx = number.integerValue;
        if (!NSLocationInRange(idx, visibleItemsRange)) {
#if __REMOVE_SUBVIEWS
            [item.view removeFromSuperview];
#else
            item.view.hidden = YES;
#endif
            [_visibleItems removeObjectForKey:number];
            [_visibleItemIndexes removeIndex:idx];
        }
    }];
}

- (void)addMissingItems {
    BOOL animates = _flags.animates && !_flags.animationsAreExplicitlyDisabled && !_flags.zooming;
    if (animates) {
        [NSAnimationContext currentContext].duration = 0.15;
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            [NSAnimationContext currentContext].timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        }
            
#if defined(__MAC_10_8)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7) {
            [[NSAnimationContext currentContext] setAllowsImplicitAnimation:YES];
        }
#endif
#endif
        [NSAnimationContext beginGrouping];
    }
    
    NSIndexSet *selectionIndexes = self.selectionIndexes;
    NSIndexSet *visibleItemIndexes = [NSIndexSet indexSetWithIndexesInRange:self.visibleItemsRange];
    [visibleItemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            id obj = [_content safeObjectAtIndex:idx];
            if (!obj) {
                NSLog(@"%@ %@, Warning!, invalid index %ld", self.class, NSStringFromSelector(_cmd), idx);
                *stop = YES;
            }
            
            if (!*stop) {
                NSCollectionViewItem *item = [self reusableItemForRepresentedObject:obj];
                item.selected = [selectionIndexes containsIndex:idx];
                item.representedObject = obj;
                
                NSView *view = item.view;
#if !__REMOVE_SUBVIEWS
                view.hidden = NO;
#endif
                id animator = animates ? view.animator : view;
                [animator setFrame:[self frameForItemAtIndex:idx]];
                
                if (!_visibleItemIndexes) {
                    _visibleItemIndexes = [[NSMutableIndexSet alloc] init];
                }
                
                [_visibleItemIndexes addIndex:idx];
                
                [self updateSelectionStateOfItem:item];
                [self addSubview:view];
                [self setNeedsDisplayInRect:view.frame];
                
                if (!_visibleItems) {
                    _visibleItems = [[NSMutableDictionary alloc] initWithCapacity:visibleItemIndexes.count];
                }
                
                _visibleItems[@(idx)] = item;
            }
        }
    }];
    
    if (animates) {
        [NSAnimationContext endGrouping];
    }
}

- (NSCollectionViewItem *)newItemForRepresentedObject:(id)object {
    return [_itemPrototype copy];
}

- (NSCollectionViewItem *)reusableItemForRepresentedObject:(id)object {
    NSString *key = [object valueForKey:@"identifier"];
    NSCollectionViewItem *item = _cachedItems[key];
    if (!item) {
        item = [[self newItemForRepresentedObject:object] autorelease];
        if (!_cachedItems) {
            _cachedItems = [[NSMutableDictionary alloc] initWithCapacity:_numberOfItems];
        }
        _cachedItems[key] = item;
    }
    
    return item;
}

- (NSCollectionViewItem *)itemAtIndex:(NSInteger)index {
    return _visibleItems[@(index)];
}

#pragma mark selection

- (void)updateSelectionStateOfItem:(NSCollectionViewItem *)item {
#if __CHANGE_SUBVIEWS_SELECTION_STATE
    NSView *view = item.view;
    if (![view infoForBinding:@"selected"] && [view respondsToSelector:@selector(setSelected:)]) {
        [(id)view setSelected:item.isSelected];
    }
#endif
}

- (void)modifySelectionBy:(NSInteger)index {
    NSIndexSet *selectionIndexes = self.selectionIndexes;
    if (!selectionIndexes.count) {
        return;
    }
    
    NSInteger selectionIndex = (selectionIndexes.lastIndex + index);
    if (NSLocationInRange(selectionIndex, NSMakeRange(0, _numberOfItems))) {
        self.selectionIndexes = [NSIndexSet indexSetWithIndex:selectionIndex];
    }
}

#pragma mark actions

- (IBAction)selectAll:(id)sender {
    self.selectionIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _numberOfItems)];
}

- (IBAction)deselectAll:(id)sender {
    self.selectionIndexes = [NSIndexSet indexSet];
}

- (IBAction)zoomIn:(id)sender {
    self.zoomValue = 1.0;
}

- (IBAction)zoomOut:(id)sender {
    self.zoomValue = 0.0;
}

- (void)scrollIndexToVisible:(NSInteger)index {
    if (NSLocationInRange(index, NSMakeRange(0, _numberOfItems))) {
        [self scrollRectToVisible:[self frameForItemAtIndex:index]];
    }
}

#pragma mark NSResponder

- (void)moveUp:(id)sender {
    if (!self.selectionIndexes.count) {
        return;
    }
    
    CGRect frame = [self frameForItemAtIndex:self.selectionIndexes.lastIndex];
    frame.origin.y -= self.rowHeight;
    
    NSIndexSet *indexes = [self indexesOfItemsInRect:frame];
    if (indexes.count) {
        self.selectionIndexes = [NSIndexSet indexSetWithIndex:indexes.firstIndex];
    }
}

- (void)moveDown:(id)sender {
    if (!self.selectionIndexes.count) {
        return;
    }
    
    CGRect frame = [self frameForItemAtIndex:self.selectionIndexes.lastIndex];
    frame.origin.y += self.rowHeight;
    NSIndexSet *indexes = [self indexesOfItemsInRect:frame];
    if (indexes.count) {
        self.selectionIndexes = [NSIndexSet indexSetWithIndex:indexes.firstIndex];
    }
}

- (void)moveRight:(id)sender {
    [self modifySelectionBy:+1];
}

- (void)moveLeft:(id)sender {
    [self modifySelectionBy:-1];
}

- (void)insertTab:(id)sender {
    if (self.isFirstResponder) {
        [self.window selectNextKeyView:self];
    }
}

- (void)insertBacktab:(id)sender {
    if (self.isFirstResponder) {
        [self.window selectPreviousKeyView:self];
    }
}

- (void)centerSelectionInVisibleArea:(id)sender {
    if (!_flags.draggingRubberBand) {
        NSInteger selectionIndex = self.selectionIndexes.firstIndex;
        if (NSLocationInRange(selectionIndex, NSMakeRange(0, _numberOfItems))) {
            [self centerRectInVisibleArea:[self frameForItemAtIndex:selectionIndex]];
        }
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [super encodeRestorableStateWithCoder:coder];
    }
    [coder encodeRect:_previousVisibleRect forKey:@"previousVisibleRect"];
}

- (void)restoreStateWithCoder:(NSCoder *)coder {
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [super restoreStateWithCoder:coder];
    }
    _previousVisibleRect = [coder decodeRectForKey:@"previousVisibleRect"];
}

- (void)cancelOperation:(id)sender {
    [self.window fieldEditor:YES forObject:self].string = @"";
}

#pragma mark events

- (void)keyDown:(NSEvent *)event {
    switch (event.keyCode) {
        case kVK_Escape: {
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
                if (self.window.styleMask & NSFullScreenWindowMask) {
                    [self.window toggleFullScreen:nil];
                }
            }
            
            if (self.isInFullScreenMode) {
                [self exitFullScreenModeWithOptions:nil];
            }
            
            [super keyDown:event];
        }
            break;
        default: {
#if defined(__MAC_10_7)
            if (!self.allowsTypeSelect) {
                [super keyDown:event];
                return;
            }
            
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
                if (!_itemPrototype.textField) {
                    [super keyDown:event];
                    return;
                }
                NSText *fieldEditor = [self.window fieldEditor:YES forObject:self];
                [fieldEditor interpretKeyEvents:@[event]];
                
                NSString *string = fieldEditor.string;
                if ([string isEqualToString:@""] || (_flags.delegateShouldTypeSelectForEvent && ![self.delegate collectionView:self shouldTypeSelectForEvent:event withCurrentSearchString:string])) {
                    [self cancelOperation:nil];
                    [super keyDown:event];
                    return;
                }
                
                [self performLatestRequestOfSelector:@selector(cancelOperation:) withObject:nil afterDelay:1.0 inModes:@[NSDefaultRunLoopMode, NSModalPanelRunLoopMode]];
                
                NSArray *objs = nil;
                if (_flags.delegateTypeSelectStringForItemAtIndex) {
                    objs = [_content objectsPassingTest:^BOOL(id obj, NSInteger idx, BOOL *stop) {
                        return [[self.delegate collectionView:self typeSelectStringForItemAtIndex:idx] hasCaseInsensitivePrefix:string];
                    }];
                } else {
                    objs = [_content objectsPassingTest:^BOOL(id obj, NSInteger idx, BOOL *stop) {
                        return [[self reusableItemForRepresentedObject:obj].textField.stringValue hasCaseInsensitivePrefix:string];
                    }];
                }
                
                if (!objs.count) {
                    [self cancelOperation:nil];
                    [super keyDown:event];
                    return;
                }
                self.selectionIndexes = [NSIndexSet indexSetWithIndex:[_content indexOfObject:objs[0]]];
            } else {
                [super keyDown:event];
            }
#else
            [super keyDown:event];
#endif
        }
            break;
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.isSelectable) {
        return;
    }
    
    [self.window makeFirstResponder:self];
    
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger index = [self indexOfItemAtPoint:location];
    if (index == NSNotFound) {
        if (event.modifierFlags & NSControlKeyMask) {
            if (_flags.delegateRespondsToBackgroundWasRightClicked) {
                [_delegate collectionView:self backgroundWasRightClickedWithEvent:event];
            }
        } else {
            if (self.allowsEmptySelection)
                [self deselectAll:nil];
            
            if (self.allowsMultipleSelection) {
                _initialMousePosition = location;
                _flags.draggingRubberBand = 1;
            }
        }
        return;
    }
    
    switch (event.clickCount) {
        case 1: {
            _initialMousePosition = location;
        }
            break;
        case 2: {
            SEL action = self.action;
            if (action) {
                id target = self.target;
                if (!target) {
                    target = [NSApp targetForAction:action];
                }
                if (target) {
                    [target performSelector:action withObject:self];
                    return;
                }
            }
        }
            break;
        default:
            break;
    }
    
    NSIndexSet *selectionIndexes = self.selectionIndexes;
    if ((event.modifierFlags & NSCommandKeyMask) != 0) {
        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
        [indexes addIndexes:selectionIndexes];
        
        if ([indexes containsIndex:index]) {
            if (indexes.count != 1) {
                [indexes removeIndex:index];
            } else {
                if (self.allowsEmptySelection) {
                    [indexes removeIndex:index];
                }
            }
        } else {
            if (self.allowsMultipleSelection) {
                [indexes addIndex:index];
            }
        }
        self.selectionIndexes = indexes;
    } else if ((event.modifierFlags & NSShiftKeyMask) != 0) {
        if (self.allowsMultipleSelection && selectionIndexes.count) {
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
            [indexes addIndexes:selectionIndexes];
            
            NSInteger start = selectionIndexes.firstIndex;
            NSInteger end = selectionIndexes.lastIndex;
            if (index < start) {
                [indexes addIndexesInRange:NSMakeRange(index, start - index)];
            } else if (index > end) {
                [indexes addIndexesInRange:NSMakeRange(end + 1, index - end)];
            }
            self.selectionIndexes = indexes;
        } else {
            self.selectionIndexes = [NSIndexSet indexSetWithIndex:index];
        }
    } else {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:index];
        if ([selectionIndexes containsIndex:index]) {
            [[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithDuration:0.5 completion:^ {
                if (!_flags.dragging) {
                    self.selectionIndexes = indexes;
                }
            }] forMode:NSRunLoopCommonModes];
        } else {
            self.selectionIndexes = indexes;
        }
    }
}

- (void)rightMouseDown:(NSEvent *)event {
    CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger index = [self indexOfItemAtPoint:location];
    if (index != NSNotFound) {
        [super rightMouseDown:event];
        return;
    }
    if (_flags.delegateRespondsToBackgroundWasRightClicked) {
        [_delegate collectionView:self backgroundWasRightClickedWithEvent:event];
    }
}

- (void)mouseUp:(NSEvent *)event {
    _currentDropIndex = NSNotFound;
    _initialMousePosition = CGPointMake(-1, -1);
    _flags.dragging = 0;
    _flags.draggingRubberBand = 0;
    
    self.rubberBandView.selectionRect = CGRectZero;
    self.needsDisplay = YES;
}

- (NSMenu *)menuForEvent:(NSEvent *)event {
    if (self.menu && _numberOfItems) {
        CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
        NSInteger index = [self indexOfItemAtPoint:location];
        if (index != NSNotFound) {
            if (![self.selectionIndexes containsIndex:index]) {
                NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
                [indexes addIndexes:self.selectionIndexes];
                [indexes addIndex:index];
                self.selectionIndexes = indexes;
            }
            return self.menu;
        }
    }
    return nil;
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (_flags.draggingRubberBand) {
        CGRect draggingRect = CGRectIntegral(SSRectMakeWithPoints(_initialMousePosition, location));
        SSRubberBandView *rubberBandView = self.rubberBandView;
        rubberBandView.selectionRect = [self convertRect:draggingRect toView:rubberBandView];
        
        [self autoscroll:event];
        [self performLatestRequestOfSelector:@selector(setSelectionIndexes:) withObject:[self indexesOfItemsInRect:draggingRect] afterDelay:0.1 inModes:@[NSDefaultRunLoopMode, NSModalPanelRunLoopMode]];
        return;
    }
    
    _flags.dragging = (_flags.delegateRespondsToPasteboardWriter || _flags.delegateRespondsToWriteItems);
    if (!_flags.dragging) {
        return;
    }
    id <SSCollectionViewDelegate> delegate = self.delegate;
    if (!delegate) {
        return;
    }
    
    NSIndexSet *selectionIndexes = self.selectionIndexes;
    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        if (_flags.delegateRespondsToPasteboardWriter) {
            if (selectionIndexes.count) {
                NSIndexSet *visibleItemIndexes = self.visibleItemIndexes;
                NSMutableArray *draggingItems = [NSMutableArray arrayWithCapacity:selectionIndexes.count];
                [selectionIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    @autoreleasepool {
                        id writer = [_delegate collectionView:self pasteboardWriterForItemAtIndex:idx];
                        if (writer) {
                            Class NSDraggingItemClass = NSClassFromString(@"NSDraggingItem");
                            id draggingItem = [[[NSDraggingItemClass alloc] initWithPasteboardWriter:writer] autorelease];
                            if ([visibleItemIndexes containsIndex:idx]) {
                                NSImage *image = nil;
                                NSCollectionViewItem *item = [self itemAtIndex:idx];
                                if (_flags.delegateRespondsToDraggingImageForItem) {
                                    image = [_delegate collectionView:self draggingImageForItemAtIndex:idx];
                                }
                                
                                if (!image) {
                                    image = item.imageView.image;
                                }
                                
                                CGRect frame = [self frameForItemAtIndex:idx];
                                if (image) {
                                    frame.size = SSSizeMakeWithAspectRatioInsideSize(image.size, SSSizeMakeSquare(MIN(CGRectGetWidth(frame), CGRectGetHeight(frame))), SSRectResizingMethodScale);
                                } else {
                                    image = item.view.imageRepresentation;
                                }
                                
                                [draggingItem setDraggingFrame:frame contents:image];
                            }
                            [draggingItems addObject:draggingItem];
                        }
                    }
                }];
                
                if (draggingItems.count) {
                    id session = [self beginDraggingSessionWithItems:draggingItems event:event source:self];
                    [session setDraggingFormation:NSDraggingFormationPile];
                    
                    if (_flags.delegateRespondsToDraggingSessionWillBegin) {
                        [_delegate collectionView:self draggingSession:session willBeginAtPoint:location forItemsAtIndexes:selectionIndexes];
                    }
                }
            }
        } else {
            if (_flags.delegateRespondsToWriteItems && [_delegate collectionView:self writeItemsAtIndexes:selectionIndexes toPasteboard:pboard]) {
                [self dragImageAtPoint:location offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];
            }
        }
    } else {
        if (_flags.delegateRespondsToWriteItems && [_delegate collectionView:self writeItemsAtIndexes:selectionIndexes toPasteboard:pboard]) {
            [self dragImageAtPoint:location offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];
        }
    }
#else
    if (_flags.delegateRespondsToWriteItems && [_delegate collectionView:self writeItemsAtIndexes:selectionIndexes toPasteboard:pboard]) {
        [self dragImageAtPoint:location offset:NSZeroSize event:event pasteboard:pboard source:self slideBack:YES];
    }
#endif
}

#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060

#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    NSDragOperation operation = NSDragOperationCopy;
    if (context == NSDraggingContextWithinApplication) {
        operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
    return operation;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    _initialMousePosition = CGPointMake(-1, -1);
    _currentDropOperation = SSCollectionViewDropOn;
    _currentDropIndex = NSNotFound;
    _flags.dragging = 0;
    _flags.draggingRubberBand = 0;
    
    if (_flags.delegateRespondsToDraggingSessionEnded) {
        [_delegate collectionView:self draggingSession:session endedAtPoint:screenPoint operation:operation];
    }
}

- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
    if (_flags.delegateRespondsToIgnoreModifierKeys) {
        return [_delegate collectionView:self ignoreModifierKeysForDraggingSession:session];
    }
    return NO;
}

#else

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSDragOperation operation = NSDragOperationCopy;
    if (isLocal) {
        operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
    
    return operation;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    _initialMousePosition = CGPointMake(-1, -1);
    _currentDropOperation = SSCollectionViewDropOn;
    _currentDropIndex = NSNotFound;
    _flags.dragging = 0;
    _flags.draggingRubberBand = 0;
}

#endif

- (NSImage *)draggingImageForItemAtIndex:(NSInteger)index {
    NSImage *image = nil;
    if (_flags.delegateRespondsToDraggingImageForItem) {
        image = [_delegate collectionView:self draggingImageForItemAtIndex:index];
    }
    
    if (!image) {
        NSCollectionViewItem *item = [self itemAtIndex:index];
        if (!(image = item.imageView.image)) {
            image = item.view.imageRepresentation;
        }
        
    }
    return image;
}

- (NSImage *)draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset {
    static const NSInteger maxNumberOfDraggedItems = 10;
    NSInteger numberOfDraggedItems = indexes.count;
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger draggingLeaderIndex = [self indexOfItemAtPoint:location];
    NSIndexSet *visibleIndexes = self.visibleItemIndexes;
    NSMutableIndexSet *draggedItemIndexes = [NSMutableIndexSet indexSet];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (draggedItemIndexes.count >= maxNumberOfDraggedItems) {
            *stop = YES;
        } else {
            if ([visibleIndexes containsIndex:idx]) {
                [draggedItemIndexes addIndex:idx];
            } 
        }
    }];
    
    [draggedItemIndexes removeIndex:draggingLeaderIndex];
    
    CGFloat scale = self.scale;
    CGSize cellSize = self.cellSize;
    static const CGFloat boxInset = 32.0;
    CGFloat extraSpace = (boxInset*(CGFloat)2.0);
    CGRect imageBounds = CGRectMake(0, 0, FLOOR((cellSize.width*(CGFloat)1.2) + extraSpace), FLOOR((cellSize.height*(CGFloat)1.2) + extraSpace));
    CGRect boundingBox = SSRectScale(imageBounds, scale);
    boundingBox.origin = CGPointZero;
    
    CGRect interiorBox = CGRectIntegral(CGRectInset(boundingBox, boxInset, boxInset));
    CGRect itemBounds = CGRectZero;
    itemBounds.size = SSSizeScale(cellSize, scale);
    if (numberOfDraggedItems > 1) {
        itemBounds.origin = CGPointMake(CGRectGetMinX(interiorBox), FLOOR(CGRectGetMaxY(interiorBox) - CGRectGetHeight(itemBounds)));
    } else {
        itemBounds.origin = CGPointMake(FLOOR(CGRectGetMidX(boundingBox) - (CGRectGetWidth(itemBounds) * (CGFloat)0.5)), FLOOR(CGRectGetMidY(boundingBox) - (CGRectGetHeight(itemBounds) * (CGFloat)0.5)));
    }
    
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, CGRectGetWidth(boundingBox), CGRectGetHeight(boundingBox), 8, CGRectGetWidth(boundingBox)*4, SSColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Host));
    CGContextSaveGState(ctx);
    {
        CGContextSetShouldAntialias(ctx, true);
        CGContextSetAllowsAntialiasing(ctx, true);
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        
        CGContextSaveGState(ctx);
        {
            CGContextSetAlpha(ctx, 0.99);
            CGContextBeginTransparencyLayer(ctx, NULL);
            
            __block BOOL rotate = NO;
            
            [draggedItemIndexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
                @autoreleasepool {
                    NSImage *draggingImage = [self draggingImageForItemAtIndex:idx];
                    if (draggingImage) {
                        CGImageRef imageRef = SSAutorelease(SSImageCreateRotatedClockwiseByAngle(SSImageGetCGImage(draggingImage), RADIANS((CGFloat)((int)arc4random()%20) - 10)));
                        SSContextDrawImage(ctx, imageRef, itemBounds, SSRectResizingMethodScale);
                        
                        rotate = !rotate;
                    }
                }
            }];
            
            NSImage *itemImage = [self draggingImageForItemAtIndex:draggingLeaderIndex];
            if (itemImage) {
                CGImageRef imageRef = SSImageGetCGImage(itemImage);
                if (numberOfDraggedItems > 1) {
                    imageRef = SSAutorelease(SSImageCreateRotatedClockwiseByAngle(imageRef, RADIANS((CGFloat)((int)arc4random()%20) - 10)));
                }
                SSContextDrawImage(ctx, imageRef, itemBounds, SSRectResizingMethodScale);
            }
            
            CGContextEndTransparencyLayer(ctx);
        }
        CGContextRestoreGState(ctx);
        
        if (numberOfDraggedItems > 1) {
            CGImageRef badge = SSAutorelease(SSImageCreateBadgeWithLabel(@(numberOfDraggedItems).stringValue, [NSFont boldSystemFontOfSize:11.0*(CGFloat)scale], 0.0));
            CGRect badgeRect = CGRectZero;
            badgeRect.size = SSImageGetSize(badge);
            badgeRect.origin = CGPointMake(CGRectGetMinX(boundingBox), FLOOR(CGRectGetMaxY(boundingBox) - CGRectGetHeight(badgeRect)));
            
            CGContextSaveGState(ctx);
            {
                CGContextSetShadow(ctx, CGSizeMake(1.0, -1.0), 3.0);
                CGContextDrawImage(ctx, badgeRect, badge);
            }
            CGContextRestoreGState(ctx);
        }
    }
    CGContextRestoreGState(ctx);
    
    return [[[NSImage alloc] initWithCGImage:SSAutorelease(CGBitmapContextCreateImage(ctx)) size:imageBounds.size] autorelease];
}

- (void)dragImageAtPoint:(CGPoint)point offset:(CGSize)offset event:(NSEvent *)event pasteboard:(NSPasteboard *)pasteboard source:(id)source slideBack:(BOOL)slideBack {
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSInteger draggingLeaderIndex = [self indexOfItemAtPoint:location];
    NSPoint initialOffset = NSZeroPoint;
    NSImage *image = nil;
    if (_flags.delegateRespondsToDraggingImageForItems) {
        image = [_delegate collectionView:self draggingImageForItemsAtIndexes:self.selectionIndexes withEvent:event offset:&initialOffset];
    }
    
    if (!image) {
        image = [self draggingImageForItemsAtIndexes:self.selectionIndexes withEvent:event offset:&initialOffset];
    }
    
    CGSize cellSize = self.cellSize;
    NSImage *itemImage = [self draggingImageForItemAtIndex:draggingLeaderIndex];
    if (itemImage) {
        cellSize = SSSizeMakeWithAspectRatioInsideSize(SSSizeMakeSquare(MAX(itemImage.size.width, itemImage.size.height)), cellSize, SSRectResizingMethodScale);
    }
    
    CGRect itemBounds = [self frameForItemAtIndex:draggingLeaderIndex];
    itemBounds.size = cellSize;
    
    CGRect imageBounds = SSRectMakeWithSize(image.size);
    imageBounds.origin = CGPointMake(FLOOR(CGRectGetMidX(itemBounds) - (CGRectGetWidth(imageBounds)*(CGFloat)0.5)), FLOOR(CGRectGetMidY(itemBounds) - (CGRectGetHeight(imageBounds)*(CGFloat)0.5)));
    
    point.x -= location.x - CGRectGetMinX(imageBounds);
    point.y += CGRectGetMaxY(imageBounds) - location.y;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [self dragImage:image at:point offset:offset event:event pasteboard:pasteboard source:source slideBack:slideBack];
#pragma clang diagnostic pop
}

#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if (_delegate) {
        if ((sender.draggingSource == self) && self.allowsReordering) {
            return NSDragOperationMove;
        } else if (_flags.delegateRespondsToValidateDrop) {
            return [_delegate collectionView:self validateDrop:sender proposedIndex:&_currentDropIndex dropOperation:&_currentDropOperation];
        }
    }
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    NSPoint point = [self convertPoint:sender.draggingLocation fromView:nil];
    _currentDropIndex = [self indexOfItemAtPoint:point];
    if (_currentDropIndex != NSNotFound) {
        CGRect frame = [self frameForItemAtIndex:_currentDropIndex];
        CGRect rect = frame;
        rect.size.width = FLOOR(CGRectGetWidth(frame)*(CGFloat)0.3);
        rect.origin.x = FLOOR(NSMidX(frame) - (CGRectGetWidth(rect)*(CGFloat)0.5));
        
        _currentDropOperation = NSPointInRect(point, rect) ? SSCollectionViewDropOn : SSCollectionViewDropBefore;
    }
    
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if (_delegate) {
        if ((sender.draggingSource == self) && self.allowsReordering) {
            if (_flags.delegateRespondsToMoveItems) {
                return [_delegate collectionView:self moveItemsAtIndexes:self.selectionIndexes toIndex:_currentDropIndex];
            }
        }
        
        if (_flags.delegateRespondsToAcceptDrop) {
            return [_delegate collectionView:self acceptDrop:sender index:_currentDropIndex dropOperation:_currentDropOperation];
        }
    }
    return NO;
}

- (BOOL)wantsPeriodicDraggingUpdates {
    return NO;
}

- (void)updateDraggingItemsForDrag:(id <NSDraggingInfo>)sender {
    if (_flags.delegateRespondsToUpdateDraggingItems) {
        [_delegate collectionView:self updateDraggingItemsForDrag:sender];
    }
}

#pragma mark NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
    SEL action = [item action];
    if (action == @selector(deselectAll:)) {
        return (self.selectionIndexes.count > 0) && self.allowsEmptySelection;
    } else if (action == @selector(selectAll:)) {
        return self.allowsMultipleSelection;
    } else if (action == @selector(centerSelectionInVisibleArea:)) {
        return (self.selectionIndexes.count > 0);
    }
    return YES;
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillStartLiveResizeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEndLiveResizeNotification object:nil];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillEnterFullScreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidEnterFullScreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillExitFullScreenNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidExitFullScreenNotification object:nil];
    }
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    if (!self.window) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillStartLiveResize:) name:NSWindowWillStartLiveResizeNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidEndLiveResize:) name:NSWindowDidEndLiveResizeNotification object:self.window];
    
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidEnterFullScreen:) name:NSWindowDidEnterFullScreenNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:self.window];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidExitFullScreen:) name:NSWindowDidExitFullScreenNotification object:self.window];
    }
#endif
    
    [self layout];
}

- (void)viewWillMoveToSuperview:(NSView *)superview {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:nil];
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewWillStartLiveScrollNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidLiveScrollNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSScrollViewDidEndLiveScrollNotification object:nil];
    }
#endif
}

- (void)viewDidMoveToSuperview {
    if (!self.superview) {
        return;
    }
    
    self.enclosingScrollView.backgroundColor = _backgroundColors.firstObject;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameChanged:) name:NSViewFrameDidChangeNotification object:self.superview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewBoundsChanged:) name:NSViewBoundsDidChangeNotification object:self.superview];
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewWillStartLiveScroll:) name:NSScrollViewWillStartLiveScrollNotification object:self.enclosingScrollView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidLiveScroll:) name:NSScrollViewDidLiveScrollNotification object:self.enclosingScrollView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollViewDidEndLiveScroll:) name:NSScrollViewDidEndLiveScrollNotification object:self.enclosingScrollView];
    }
#endif
    
    [self layout];
}

- (void)viewWillStartLiveResize {
    [super viewWillStartLiveResize];
    
    _flags.animationsAreExplicitlyDisabled = 1;
}

- (void)viewDidEndLiveResize {
    [super viewDidEndLiveResize];
    
    _flags.animationsAreExplicitlyDisabled = 0;
}

- (void)viewFrameChanged:(NSNotification *)notification {
    CGRect visibleRect = self.visibleRect;
    if (!NSEqualRects(visibleRect, _previousVisibleRect)) {
        _previousVisibleRect = visibleRect;
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            [self invalidateRestorableState];
        }
#endif
    }
    self.needsLayout = YES;
}

- (void)viewBoundsChanged:(NSNotification *)notification {
    if (_flags.zooming) {
        return;
    }
    
    CGRect visibleRect = self.visibleRect;
    if (NSEqualRects(visibleRect, _previousVisibleRect)) {
        return;
    }
    
    _previousVisibleRect = visibleRect;
    
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        [self invalidateRestorableState];
    }
#endif
    
    [self removeInvisibleItems];
    [self addMissingItems];
}

#pragma mark NSScrollView notifications

- (void)scrollViewWillStartLiveScroll:(NSNotification *)notification {
    _flags.animationsAreExplicitlyDisabled = 1;
}

- (void)scrollViewDidLiveScroll:(NSNotification *)notification {
    
}

- (void)scrollViewDidEndLiveScroll:(NSNotification *)notification {
    _flags.animationsAreExplicitlyDisabled = 0;
}

#pragma mark NSWindow notifications

- (void)windowWillStartLiveResize:(NSNotification *)notification {
    _flags.animationsAreExplicitlyDisabled = 1;
}

- (void)windowDidEndLiveResize:(NSNotification *)notification {
    [self centerSelectionInVisibleArea:nil];
    
    _flags.animationsAreExplicitlyDisabled = 0;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {
    _flags.animationsAreExplicitlyDisabled = 1;
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
    [self centerSelectionInVisibleArea:nil];
    
    _flags.animationsAreExplicitlyDisabled = 0;
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
    _flags.animationsAreExplicitlyDisabled = 1;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
    [self centerSelectionInVisibleArea:nil];
    
    _flags.animationsAreExplicitlyDisabled = 0;
}

#pragma mark getters & setters

- (SSRubberBandView *)rubberBandView {
    SSRubberBandView *rubberBandView = [self.superview viewWithTag:kCVRubberBandViewTag];
    if (!rubberBandView) {
        rubberBandView = [[[SSRubberBandView alloc] initWithFrame:self.frame] autorelease];
        rubberBandView.tag = kCVRubberBandViewTag;
        rubberBandView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        [self.superview addSubview:rubberBandView positioned:NSWindowAbove relativeTo:self];
    }
    return rubberBandView;
}

- (NSIndexSet *)indexesOfItemsInRect:(CGRect)rect {
    if (!_numberOfItems || CGRectIsEmpty(rect)) {
        return nil;
    }
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:(NSRange){0, _numberOfItems}];
    return [indexes indexesPassingTest:^BOOL(NSUInteger idx, BOOL * _Nonnull stop) {
        return CGRectIntersectsRect([self frameForItemAtIndex:idx], rect);
    }];
}

- (NSInteger)indexOfItemAtPoint:(NSPoint)point {
    for (NSNumber *key in _visibleItems) {
        NSInteger index = key.integerValue;
        if (CGRectContainsPoint([self frameForItemAtIndex:index], point)) {
            return index;
        }
    }
    return NSNotFound;
}

- (CGRect)frameForItemAtIndex:(NSInteger)index {
    if (!NSLocationInRange(index, (NSRange){0, _numberOfItems})) {
        return CGRectZero;
    }
    
    CGSize cellSize = self.cellSize;
    CGSize intercellSpacing = self.intercellSpacing;
    NSInteger column = index % _numberOfColumns;
    NSInteger row = (index - column) / _numberOfColumns;
    return CGRectMake(FLOOR(intercellSpacing.width + (_interitemSpacing*(CGFloat)0.5) + (column * (cellSize.width + _interitemSpacing))), FLOOR(intercellSpacing.height + (row * (cellSize.height + intercellSpacing.height))), cellSize.width, cellSize.height);
}

- (NSRange)visibleItemsRange {
    CGFloat rowHeight = self.rowHeight;
    CGRect visibleRect = self.visibleRect;
    visibleRect.origin.y -= rowHeight;
    visibleRect.size.height += (rowHeight * 2);
    if (visibleRect.origin.y < 0.0)
        visibleRect.origin.y = 0.0;
    
    NSInteger rows = visibleRect.origin.y / rowHeight;
    NSInteger startIndex = rows * _numberOfColumns;
    NSInteger endIndex = 0;
    
    rows = (visibleRect.origin.y + visibleRect.size.height) / rowHeight;
    endIndex = rows * _numberOfColumns;
    endIndex = MIN(_numberOfItems, endIndex);
    
    return NSMakeRange(startIndex, endIndex-startIndex);
}

- (NSIndexSet *)visibleItemIndexes {
    return _visibleItemIndexes;
}

- (CGFloat)rowHeight {
    CGSize intercellSpacing = self.intercellSpacing;
    return _numberOfItems ? (self.cellSize.height + intercellSpacing.height) : (kCVCellMinimumHeight + intercellSpacing.height);
}

- (NSCollectionViewItem *)itemPrototype {
    return _itemPrototype;
}

- (void)setItemPrototype:(NSCollectionViewItem *)itemPrototype {
    if ([_itemPrototype isEqual:itemPrototype]) {
        return;
    }
    
    //NSLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    
    SSNonAtomicCopiedSet(_itemPrototype, itemPrototype);
    
    _itemSize = itemPrototype.view.frame.size;
    
    [self layout];
}

- (id<SSCollectionViewDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSCollectionViewDelegate>)delegate {
    _delegate = delegate;
    
    _flags.delegateRespondsToPasteboardWriter = [delegate respondsToSelector:@selector(collectionView:pasteboardWriterForItemAtIndex:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingSessionWillBegin = [delegate respondsToSelector:@selector(collectionView:draggingSession:willBeginAtPoint:forItemsAtIndexes:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingSessionEnded = [delegate respondsToSelector:@selector(collectionView:draggingSession:endedAtPoint:operation:)] ? 1 : 0;
    _flags.delegateRespondsToIgnoreModifierKeys = [delegate respondsToSelector:@selector(collectionView:ignoreModifierKeysForDraggingSession:)] ? 1 : 0;
    _flags.delegateRespondsToUpdateDraggingItems = [delegate respondsToSelector:@selector(collectionView:updateDraggingItemsForDrag:)] ? 1 : 0;
    _flags.delegateRespondsToWriteItems = [delegate respondsToSelector:@selector(collectionView:writeItemsAtIndexes:toPasteboard:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingImageForItem = [delegate respondsToSelector:@selector(collectionView:draggingImageForItemAtIndex:)] ? 1 : 0;
    _flags.delegateRespondsToDraggingImageForItems = [delegate respondsToSelector:@selector(collectionView:draggingImageForItemsAtIndexes:withEvent:offset:)] ? 1 : 0;
    _flags.delegateRespondsToValidateDrop = [delegate respondsToSelector:@selector(collectionView:validateDrop:proposedIndex:dropOperation:)] ? 1 : 0;
    _flags.delegateRespondsToAcceptDrop = [delegate respondsToSelector:@selector(collectionView:acceptDrop:index:dropOperation:)] ? 1 : 0;
    _flags.delegateRespondsToMoveItems = [delegate respondsToSelector:@selector(collectionView:moveItemsAtIndexes:toIndex:)] ? 1 : 0;
    _flags.delegateRespondsToBackgroundWasRightClicked = [delegate respondsToSelector:@selector(collectionView:backgroundWasRightClickedWithEvent:)] ? 1 : 0;
    _flags.delegateShouldTypeSelectForEvent = [delegate respondsToSelector:@selector(collectionView:shouldTypeSelectForEvent:withCurrentSearchString:)] ? 1 : 0;
    _flags.delegateTypeSelectStringForItemAtIndex = [delegate respondsToSelector:@selector(collectionView:typeSelectStringForItemAtIndex:)] ? 1 : 0;
    _flags.delegateRespondsToSelectionDidChange = [delegate respondsToSelector:@selector(collectionViewSelectionDidChange:)] ? 1 : 0;
}

- (id<SSCollectionViewDataSource>)dataSource {
    return _dataSource;
}

- (void)setDataSource:(id<SSCollectionViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    _flags.dataSourceRespondsToNumberOfItems = [dataSource respondsToSelector:@selector(numberOfItemsInCollectionView:)] ? 1 : 0;
    _flags.dataSourceRespondsToItemAtIndex = [dataSource respondsToSelector:@selector(collectionView:itemAtIndex:)] ? 1 : 0;
}

- (id)target {
    return _target;
}

- (void)setTarget:(id)target {
    _target = target;
}

- (SEL)action {
    return _action;
}

- (void)setAction:(SEL)action {
    _action = action;
}

- (NSArray *)content {
    return _content;
}

- (void)setContent:(NSArray *)content {
    if ([_content isEqualToArray:content]) {
        return;
    }
    
    for (id obj in _content) {
        @autoreleasepool {
            NSCollectionViewItem *item = [self reusableItemForRepresentedObject:obj];
            [item.view removeFromSuperview];
            
            if (![content containsObject:obj]) {
                item.representedObject = nil;
                NSString *identifier = [obj identifier];
                [_visibleItems removeObjectForKey:identifier];
                [_cachedItems removeObjectForKey:identifier];
            }
        }
    }
    
    self.subviews = @[];
    
    SSNonAtomicCopiedSet(_content, content);
    
    _numberOfItems = content.count;
    
    if (_numberOfItems && !self.allowsEmptySelection && !self.selectionIndexes.count) {
        self.selectionIndexes = [NSIndexSet indexSetWithIndex:0];
    }
    
    [self setNeedsDisplayInRect:self.visibleRect];
    [self layout];
}

- (NSIndexSet *)selectionIndexes {
    if (!_selectionIndexes) {
        _selectionIndexes = [[NSIndexSet alloc] init];
    }
    return _selectionIndexes;
}

- (void)setSelectionIndexes:(NSIndexSet *)selectionIndexes {
    if (!self.isSelectable || !selectionIndexes) {
        selectionIndexes = [NSIndexSet indexSet];
    }
    
    NSIndexSet *indexes = self.selectionIndexes;
    if (![selectionIndexes isEqualToIndexSet:indexes]) {
        NSMutableIndexSet *allIndexes = [[selectionIndexes mutableCopy] autorelease];
        [allIndexes addIndexes:indexes];
        [allIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
            NSCollectionViewItem *item = [self itemAtIndex:idx];
            item.selected = [selectionIndexes containsIndex:idx];
            [self updateSelectionStateOfItem:item];
        }];
        
        SSNonAtomicCopiedSet(_selectionIndexes, selectionIndexes);
        
        id controller = [self controllerForBinding:SSSelectionIndexesBinding];
        if (controller) {
            [controller setValue:selectionIndexes forKeyPath:[self keyPathForBinding:SSSelectionIndexesBinding]];
        }
        
        [self centerSelectionInVisibleArea:nil];
        
        if (_flags.delegateRespondsToSelectionDidChange) {
            [self.delegate collectionViewSelectionDidChange:self];
        }
    }
}

- (NSArray *)backgroundColors {
    if (!_backgroundColors) {
        _backgroundColors = _flags.usesAlternatingBackgroundColors ? [[NSColor controlAlternatingRowBackgroundColors] copy] : [@[[NSColor whiteColor]] copy];
    }
    return _backgroundColors;
}

- (void)setBackgroundColors:(NSArray *)backgroundColors {
    SSNonAtomicCopiedSet(_backgroundColors, backgroundColors);
    self.enclosingScrollView.backgroundColor = backgroundColors.firstObject;
    self.needsDisplay = YES;
}

- (void)didZoom {
    _flags.zooming = 0;
}

- (CGFloat)zoomValue {
    return _zoomValue;
}

- (void)setZoomValue:(CGFloat)zoomValue {
    if (_zoomValue == zoomValue) {
        return;
    }
    _zoomValue = MIN(MAX(zoomValue, 0.0), 1.0);
    _flags.zooming = 1;
    [self layout];
#if TARGET_OS_IPHONE
    [self performLatestRequestOfSelector:@selector(didZoom) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
#else
    if (!self.window.isVisible) {
        _flags.zooming = 0;
        return;
    }
    [self performLatestRequestOfSelector:@selector(didZoom) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes, NSModalPanelRunLoopMode]];
#endif
}

#if NS_BLOCKS_AVAILABLE

- (void)setZoomValue:(CGFloat)zoomValue animated:(BOOL)animated completion:(void(^__nullable)(void))completion {
    if (self.zoomValue == zoomValue) {
        return;
    }
    zoomValue = MIN(MAX(zoomValue, 0.0), 1.0);
    if (!animated) {
        self.zoomValue = zoomValue;
        return;
    }
    CGFloat initial = self.zoomValue;
    CGFloat diference = (zoomValue-initial);
    [[CADisplayLink displayLinkWithDuration:0.25 execution:^(CGFloat progress) {
        self.zoomValue = initial + (diference*progress);
    } completion:^{
        if (completion) {
            completion();
        }
    }] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setZoomValue:(CGFloat)zoomValue animated:(BOOL)animated {
    [self setZoomValue:zoomValue animated:animated completion:nil];
}

#endif

- (CGSize)cellSize {
    CGFloat magnification = 5.0;
    CGRect bounds = self.bounds;
    CGSize intercellSpacing = self.intercellSpacing;
    CGSize cellSize = _itemSize;
    CGFloat availableSpace = CGRectGetWidth(bounds) - (intercellSpacing.width*(CGFloat)2.0);
#if __ADJUST_SUBVIEWS_WIDTH
    if (_maxNumberOfColumns == 1) {
        cellSize.width = availableSpace;
    }
#endif
    CGFloat zoomValue = self.zoomValue;
    CGFloat zoomFactor = MAX(magnification, 1.0);
    return CGSizeMake(FLOOR(MIN(cellSize.width * (1.0 + (zoomValue * zoomFactor)), availableSpace)), FLOOR(cellSize.height * (1.0 + (zoomValue * zoomFactor))));
}

- (CGSize)intercellSpacing {
    CGFloat zoomValue = self.zoomValue;
    return CGSizeMake(FLOOR(_minimumInteritemSpacing + (zoomValue * _minimumInteritemSpacing)), FLOOR(_minimumLineSpacing + (zoomValue * _minimumLineSpacing)));
}

- (CGFloat)minimumLineSpacing {
    return _minimumLineSpacing;
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    if (_minimumLineSpacing == minimumLineSpacing) {
        return;
    }
    _minimumLineSpacing = minimumLineSpacing;
    [self layout];
}

- (CGFloat)minimumInteritemSpacing {
    return _minimumInteritemSpacing;
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
    if (_minimumInteritemSpacing == minimumInteritemSpacing) {
        return;
    }
    _minimumInteritemSpacing = minimumInteritemSpacing;
    [self layout];
}

- (NSInteger)numberOfColumns {
    return _numberOfColumns;
}

- (NSInteger)numberOfRows {
    return _numberOfRows;
}

- (NSInteger)maxNumberOfRows {
    return _maxNumberOfRows;
}

- (void)setMaxNumberOfRows:(NSInteger)maxNumberOfRows {
    if (_maxNumberOfRows == maxNumberOfRows) {
        return;
    }
    _maxNumberOfRows = maxNumberOfRows;
    [self layout];
}

- (NSInteger)maxNumberOfColumns {
    return _maxNumberOfColumns;
}

- (void)setMaxNumberOfColumns:(NSInteger)maxNumberOfColumns {
    if (_maxNumberOfColumns == maxNumberOfColumns) {
        return;
    }
    _maxNumberOfColumns = maxNumberOfColumns;
    [self layout];
}

- (BOOL)animates {
    return _flags.animates;
}

- (void)setAnimates:(BOOL)animates {
    _flags.animates = animates;
}

- (BOOL)allowsMultipleSelection {
    return _flags.allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _flags.allowsMultipleSelection = allowsMultipleSelection;
}

- (BOOL)allowsEmptySelection {
    return _flags.allowsEmptySelection;
}

- (void)setAllowsEmptySelection:(BOOL)allowsEmptySelection {
    _flags.allowsEmptySelection = allowsEmptySelection;
}

- (BOOL)allowsReordering {
    return _flags.allowsReordering;
}

- (void)setAllowsReordering:(BOOL)allowsReordering {
    _flags.allowsReordering = allowsReordering;
}

- (BOOL)allowsTypeSelect {
    return _flags.allowsTypeSelect;
}

- (void)setAllowsTypeSelect:(BOOL)allowsTypeSelect {
    _flags.allowsTypeSelect = allowsTypeSelect;
}

- (BOOL)isSelectable {
    return _flags.selectable;
}

- (void)setSelectable:(BOOL)selectable {
    _flags.selectable = selectable;
}

- (BOOL)isFirstResponder {
    return _flags.isFirstResponder;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    _flags.isFirstResponder = 1;
    return YES;
}

- (BOOL)resignFirstResponder {
    _flags.isFirstResponder = 0;
    return YES;
}

- (BOOL)isOpaque {
    return _backgroundColors ? ([_backgroundColors firstObjectPassingTest:^BOOL(NSColor * _Nonnull obj) {
        return obj.alphaComponent < 1.0;
    }] ? NO : YES) : NO;
}

- (BOOL)isFlipped {
    return YES;
}

- (BOOL)allowsVibrancy {
    return NO;
}

@end
