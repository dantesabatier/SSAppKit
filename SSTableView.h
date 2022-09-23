//
//  SSTableView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2007 Dante Sabatier. All rights reserved.
//

#import "NSTableView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@class SSTableView;
@protocol SSTableViewDelegate <NSTableViewDelegate>

@end

@protocol SSTableViewDataSource <NSTableViewDataSource>

@optional
- (NSColor *)tableView:(SSTableView *)tableView labelColorForRow:(NSInteger)row;
- (CGRect)tableView:(SSTableView *)tableView labelColorRectOfRow:(NSInteger)row;
- (NSImage *)tableView:(SSTableView *)tableView draggingImageForItemAtColumn:(NSTableColumn *)column row:(NSInteger)row;
- (CGRect)tableView:(SSTableView *)tableView draggingRectForItemAtColumn:(NSTableColumn *)column row:(NSInteger)row NS_AVAILABLE(10_7, NA);
- (BOOL)tableViewWantsCornerViewMenu:(SSTableView *)tableView;
- (NSString *)tableView:(SSTableView *)tableView menuItemTitleForColumn:(NSTableColumn *)column;
- (BOOL)tableView:(SSTableView *)tableView shouldAddMenuItemForColumn:(NSTableColumn *)column;
- (BOOL)tableView:(SSTableView *)tableView shouldAllowTogglingColumn:(NSTableColumn *)column;
- (BOOL)tableView:(SSTableView *)tableView shouldRemoveRowsAtIndexes:(NSIndexSet *)indexes;
- (void)tableView:(SSTableView *)tableView removeRowsAtIndexes:(NSIndexSet *)indexes;

@end

@interface SSTableView : NSTableView {
@private
	NSArray *_alternatingRowBackgroundColors;
	NSColor *_highlightColor;
	struct {
        unsigned int viewHasCustomBackgroundColor:1;
        unsigned int viewHasCustomHighlightColor:1;
    }_extendedFlags;
}

@property (nullable, weak) id <SSTableViewDelegate> delegate;
@property (nullable, weak) id <SSTableViewDataSource> dataSource;
@property (nullable, nonatomic, copy) NSArray <NSColor*> *alternatingRowBackgroundColors;
@property (nullable, nonatomic , strong) NSColor *highlightColor NS_AVAILABLE_MAC(10_7);
@property (nullable, nonatomic, readonly, weak) NSMenu *headersMenu;
@property (nullable, nonatomic, readonly, weak) NSMenu *sortMenu;

- (IBAction)delete:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
