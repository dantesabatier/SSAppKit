//
//  SSAnchoredBar.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSStyledView.h"

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface SSAnchoredBar : SSStyledView {
@private
    __ss_weak NSSplitView *_splitView;
    NSRectEdge _resizeHandlePosition;
    BOOL _resizable;
    BOOL _resizing;
}

@property (nullable, nonatomic, ss_weak) IBOutlet NSSplitView *splitView;
@property IBInspectable NSRectEdge resizeHandlePosition;
@property (getter=isResizable) IBInspectable BOOL resizable;
@property (readonly) NSRect handleRect;

@end

NS_ASSUME_NONNULL_END
