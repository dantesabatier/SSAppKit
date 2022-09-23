//
//  SSOutlineView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSOutlineView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@class SSOutlineView;
@protocol SSOutlineViewDelegate <NSOutlineViewDelegate>

@optional
- (BOOL)outlineView:(SSOutlineView *)outlineView isItemAutoExpandable:(id)item;

@end

@interface SSOutlineView : NSOutlineView {
@private
    BOOL _viewHasCustomBackgroundColor;
}

@property (nullable, ss_weak) id<SSOutlineViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
