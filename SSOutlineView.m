//
//  SSOutlineView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSOutlineView.h"
#import "NSTableView+SSAdditions.h"
#import "NSOutlineView+SSAdditions.h"
#import "NSTreeController+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import <SSFoundation/NSArray+SSAdditions.h>

@implementation SSOutlineView

#pragma mark NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = [item action];
    if (action == @selector(deselectAll:)) {
        return (self.selectedRowIndexes.count > 0) && !self.contentController.avoidsEmptySelection;
    } else if (action == @selector(selectAll:)) {
        return self.allowsMultipleSelection;
    }
    
	return YES;
}

#pragma mark NSOutlineView

- (void)reloadData {
	[super reloadData];
    
    id <SSOutlineViewDelegate> delegate = self.delegate;
    if (!delegate) {
        return;
    }
    
    NSTreeController *controller = self.contentController;
    if (!controller) {
        return;
    }
    
	NSTreeNode *rootNode = controller.arrangedObjects;
    if (NSIsControllerMarker(rootNode)) {
        return;
    }
    
    if ([delegate respondsToSelector:@selector(outlineView:isGroupItem:)]) {
        [NSAnimationContext beginGrouping];
        [NSAnimationContext currentContext].duration = 0;
        
        NSArray *childNodes = rootNode.childNodes;
        for (NSTreeNode *node in childNodes) {
            if ([delegate outlineView:self isGroupItem:node]) {
                if ([delegate respondsToSelector:@selector(outlineView:isItemAutoExpandable:)]) {
                    if ([delegate outlineView:self isItemAutoExpandable:node]) {
                        [self expandItem:node];
                    }
                } else {
                    [self expandItem:node];
                }
            }
        }
        
        [NSAnimationContext endGrouping];
    }
#if 1
    if ([delegate respondsToSelector:@selector(outlineView:shouldSelectItem:)]) {
        NSTreeNode *proposedNode = ((NSTreeNode *)rootNode.childNodes.firstObject).childNodes.firstObject;
        if (proposedNode) {
            NSIndexPath *selectionIndexPath = controller.selectionIndexPath;
            if (selectionIndexPath) {
                NSTreeNode *selectedNode = [controller nodeAtArrangedNodeIndexPath:selectionIndexPath];
                if (![delegate outlineView:self shouldSelectItem:selectedNode] && [delegate outlineView:self shouldSelectItem:proposedNode]) {
                     controller.selectionIndexPath = proposedNode.indexPath;
                }
            } else {
                if ([delegate outlineView:self shouldSelectItem:proposedNode]) {
                    controller.selectionIndexPath = proposedNode.indexPath;
                }
            }
        }
    }
#endif
}

- (void)drawBackgroundInClipRect:(CGRect)clipRect {
    if (self.usesAlternatingRowBackgroundColors) {
        [super drawBackgroundInClipRect:clipRect];
    } else {
        if (self.window.isActive) {
            [super drawBackgroundInClipRect:clipRect];
        } else {
            if (_viewHasCustomBackgroundColor) {
                if (self.needsDisplayWhenWindowResignsKey) {
                    [[NSColor colorWithCalibratedWhite:0.909804 alpha:1.0] setFill];
                    NSRectFill(clipRect);
                } else {
                    [super drawBackgroundInClipRect:clipRect];
                }
            } else {
                [super drawBackgroundInClipRect:clipRect];
            }
        }
    }
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToWindow {
    if (!self.window)
        return;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070

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

#else

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSDragOperation operation = NSDragOperationCopy;
    if (isLocal) {
         operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
        
    return mask;
}

#endif

#pragma mark getters && setters

- (void)setBackgroundColor:(NSColor *)color {
    _viewHasCustomBackgroundColor = color ? 1 : 0;
    
    super.backgroundColor = color;
    
    if (self.window.isVisible) {
        [self setNeedsDisplayInRect:self.visibleRect];
    } 
}

- (id <SSOutlineViewDelegate>)delegate {
    return (id <SSOutlineViewDelegate>)super.delegate;
}

- (void)setDelegate:(id<SSOutlineViewDelegate>)delegate {
    super.delegate = delegate;
}

@end
