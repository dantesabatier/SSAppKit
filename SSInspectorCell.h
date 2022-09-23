//
//  SSInspectorCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSLayoutView.h"
#import "SSInspectorItem.h"

NS_ASSUME_NONNULL_BEGIN

@class SSInspectorHeaderView;
@class SSInspectorCell;
@protocol SSInspectorCellDelegate <NSObject>

@optional
- (void)inspectorCellWillCollapse:(SSInspectorCell *)inspectorCell;
- (void)inspectorCellDidCollapse:(SSInspectorCell *)inspectorCell;
- (void)inspectorCellWillExpand:(SSInspectorCell *)inspectorCell;
- (void)inspectorCellDidExpand:(SSInspectorCell *)inspectorCell;

@end

@interface SSInspectorCell : SSLayoutView {
@private
    SSInspectorHeaderView *_headerView;
    NSView *_contentViewPlaceholder;
    CGFloat _expandedHeight;
    struct {
        unsigned int animates:1;
        unsigned int animating:1;
        unsigned int expanded:1;
    } _flags;
    __ss_weak SSInspectorItem *_inspectorItem;
    __ss_weak id <SSInspectorCellDelegate> _delegate;
}

@property (nonatomic, ss_weak) id <SSInspectorCellDelegate> delegate;
@property (nullable, nonatomic, ss_weak) SSInspectorItem *inspectorItem;
@property (nonatomic, ss_strong) NSView *contentView;
@property (nonatomic, assign) BOOL animates;
@property (nonatomic, readonly, ss_strong) SSInspectorHeaderView *headerView;
@property (nonatomic, readonly, getter = isExpanded, assign) BOOL expanded;
@property (nonatomic, readonly, getter = isAnimating, assign) BOOL animating;
- (void)toggle:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
