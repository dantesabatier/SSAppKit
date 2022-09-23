//
//  SSInspectorView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSLayoutView.h"
#import "SSInspectorItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSInspectorView : SSLayoutView {
@private
    NSMutableDictionary <NSString *, id>*_cachedCells;
    NSMutableDictionary <NSString *, id>*_undefinedValues;
    NSArray <SSInspectorItem *> *_content;
    NSString *_autosaveName;
    CGFloat _minimumLineSpacing;
    NSEdgeInsets _contentInsets;
    NSColor *_backgroundColor;
    BOOL _autosaveExpandedItems;
}

@property (nullable, nonatomic, copy) NSArray <SSInspectorItem *> *content;
@property (nullable, nonatomic, copy) NSColor *backgroundColor;
@property (nonatomic, assign) NSEdgeInsets contentInsets;
@property (nullable, nonatomic, copy) NSString *autosaveName;
@property (nonatomic, assign) BOOL autosaveExpandedItems;
@property (nonatomic, assign) CGFloat minimumLineSpacing;
- (void)expandItem:(SSInspectorItem *)item;
- (void)collapseItem:(SSInspectorItem *)item;
- (void)reloadItem:(SSInspectorItem *)item;
- (BOOL)isExpandable:(SSInspectorItem *)item;
- (id)newCellForItem:(SSInspectorItem *)item;
- (nullable id)reusableCellForItem:(SSInspectorItem *)item;
- (CGRect)frameForItemAtIndex:(NSInteger)index;

@end

/*
 SSInspectorView key for setValue:forKey and valueForKey:
 */

extern NSString * const SSInspectorViewHeaderTitleAttributesKey; /*NSDictionary*/
extern NSString * const SSInspectorViewHeaderHeightKey; /*NSNumber containing CGFloat*/

NS_ASSUME_NONNULL_END
