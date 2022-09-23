//
//  NSTableView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/13.
//
//

#import "NSTableView+SSAdditions.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import "SSSourceListButtonCell.h"

@implementation NSTableView (SSAdditions)

- (NSArrayController *)contentController {
	NSArrayController *contentController = SSGetAssociatedValueForKey(@"associatedContentController");
    if (!contentController) {
        contentController = [self infoForBinding:NSContentBinding][NSObservedObjectKey];
        if (!contentController) {
            NSArray *columns = self.tableColumns;
            for (NSTableColumn *column in columns) {
                if (![column.dataCell isKindOfClass:[NSTextFieldCell class]]) {
                    continue;
                }
                
                contentController = [column infoForBinding:NSValueBinding][NSObservedObjectKey];
                if (contentController) {
                    break;
                }
            }
        }
        
        SSSetAssociatedValueForKey(@"associatedContentController", contentController, OBJC_ASSOCIATION_ASSIGN);
    }
    
	return contentController;
}

@end

CGSize SSTableViewGetProposedCellImageSizeForRowStyle(NSTableView *self, SSTableViewRowSizeStyle rowSizeStyle) {
    CGSize imageSize = NSZeroSize;
    switch (rowSizeStyle) {
        case SSTableViewRowSizeStyleDefault: {
            NSInteger defaultStyle = 0;
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
                NSNumber *tableViewDefaultSizeMode = ([[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain])[@"NSTableViewDefaultSizeMode"];
                if (tableViewDefaultSizeMode) {
                    defaultStyle = tableViewDefaultSizeMode.integerValue;
                } else {
                    defaultStyle = 2;
                }
            }
            
            imageSize = SSTableViewGetProposedCellImageSizeForRowStyle(self, defaultStyle);
        }
            break;
        case SSTableViewRowSizeStyleCustom: {
            CGFloat rowHeight = self.rowHeight;
            if ((rowHeight >= 16) && (rowHeight < 24)) {
                imageSize = SSSizeMakeSquare(16.0);
            } else if ((rowHeight >= 24) && (rowHeight < 34)) {
                imageSize =SSSizeMakeSquare(18.0);
            } else {
                imageSize = SSSizeMakeSquare(32.0);
            }
        }
            break;
        case SSTableViewRowSizeStyleSmall:
            imageSize = SSSizeMakeSquare(16.0);
            break;
        case SSTableViewRowSizeStyleMedium:
            imageSize =SSSizeMakeSquare(18.0);
            break;
        case SSTableViewRowSizeStyleLarge:
            imageSize = SSSizeMakeSquare(32.0);
            break;
    }
    return imageSize;
}

CGSize SSTableViewGetProposedCellImageSize(NSTableView *self) {
    NSInteger rowSizeStyle = 0;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        rowSizeStyle = self.rowSizeStyle;
#endif
    return SSTableViewGetProposedCellImageSizeForRowStyle(self, rowSizeStyle);
}

BOOL SSTableViewMouseDownInButtonRect(NSTableView *self) {
    NSInteger clickedColumn = self.clickedColumn;
    NSInteger clickedRow = self.clickedRow;
    if (NSLocationInRange(clickedRow, NSMakeRange(0, self.numberOfRows)) && NSLocationInRange(clickedColumn, NSMakeRange(0, self.numberOfColumns))) {
        NSCell *cell = [self preparedCellAtColumn:clickedColumn row:clickedRow];
        if ([cell isKindOfClass:[SSSourceListButtonCell class]]) {
            return NSPointInRect([self convertPoint:self.window.currentEvent.locationInWindow fromView:nil], [(SSSourceListButtonCell *)cell buttonRectForBounds:[self frameOfCellAtColumn:clickedColumn row:clickedRow]]);
        }
    }
    return NO;
}

BOOL SSTableViewMouseDownInImageRect(NSTableView *self) {
    NSInteger clickedColumn = self.clickedColumn;
    NSInteger clickedRow = self.clickedRow;
    if (NSLocationInRange(clickedRow, NSMakeRange(0, self.numberOfRows)) && NSLocationInRange(clickedColumn, NSMakeRange(0, self.numberOfColumns))) {
        return NSPointInRect([self convertPoint:self.window.currentEvent.locationInWindow fromView:nil], [[self preparedCellAtColumn:clickedColumn row:clickedRow] imageRectForBounds:[self frameOfCellAtColumn:clickedColumn row:clickedRow]]);
    }
    return NO;
}
