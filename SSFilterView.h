//
//  SSFilterView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSLayoutView.h"

NS_ASSUME_NONNULL_BEGIN

@class SSFilterView;
@protocol SSFilterViewDataSource <NSObject>

@optional
- (NSInteger)numberOfItemsInFilterView:(SSFilterView *)filterView;
- (NSString *)filterView:(SSFilterView *)filterView titleForItemAtIndex:(NSInteger)index;

@end

@protocol SSFilterViewDelegate <NSObject>

@optional
- (void)filterViewSelectionDidChange:(SSFilterView *)filterView;

@end

@interface SSFilterView : SSLayoutView {
@private
    NSInteger _numberOfItems;
    NSInteger _selectionIndex;
    struct {
        unsigned int dataSourceRespondsToNumberOfItems:1;
        unsigned int dataSourceRespondsToItemAtIndex:1;
        unsigned int delegateRespondsToSelectionDidChange:1;
    } _flags;
    __ss_weak id <SSFilterViewDelegate> _delegate;
    __ss_weak id <SSFilterViewDataSource> _dataSource;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSFilterViewDelegate> delegate;
@property (nullable, nonatomic, ss_weak) IBOutlet id <SSFilterViewDataSource> dataSource;
@property NSInteger selectionIndex;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
