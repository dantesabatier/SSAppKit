//
//  SSTexturedTableView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTexturedTableView.h"
#import "SSTexturedCornerView.h"
#import "SSTexturedHeaderCell.h"
#import "NSView+SSAdditions.h"

@implementation SSTexturedTableView

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    
    if (!self.superview)
        return;
    
    for (NSTableColumn *column in self.tableColumns) {
        NSTableHeaderCell *oldCell = column.headerCell;
        SSTexturedHeaderCell *cell = [[SSTexturedHeaderCell alloc] initTextCell:oldCell.stringValue];
        cell.font = oldCell.font;
        column.headerCell = cell;
        [cell release];
    }
	
    SSTexturedCornerView *cornerView = [[SSTexturedCornerView alloc] initWithFrame:self.cornerView.frame];
    self.cornerView = cornerView;
    [cornerView release];
    
    self.gridColor = [NSColor colorWithCalibratedWhite:0.8 alpha:1.0];
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    [self.headerView setNeedsDisplay:YES];
    [self.cornerView setNeedsDisplay:YES];
}

@end
