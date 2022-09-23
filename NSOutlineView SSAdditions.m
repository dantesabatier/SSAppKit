//
//  NSOutlineView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/13.
//
//

#import "NSOutlineView+SSAdditions.h"
#import "NSTableView+SSAdditions.h"
#import "SSSourceListViewItem.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSString+SSAdditions.h>
#import <SSFoundation/NSObject+SSAdditions.h>

@implementation NSOutlineView (SSAdditions)

- (NSTreeController *)contentController {
	NSTreeController *contentController = SSGetAssociatedValueForKey(@"associatedContentController");
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

- (id)selectedItem {
    return [self itemAtRow:self.selectedRow];
}

- (void)setSelectedItem:(id)selectedItem {
    if (selectedItem) {
        self.selectedItems = @[selectedItem];
    }
}

- (id)clickedItem {
    return (self.clickedRow != SSTableViewRowNotFound) ? [self itemAtRow:self.clickedRow] : nil;
}

- (NSArray *)selectedItems {
    return [self itemsAtRowsWithIndexes:self.selectedRowIndexes];
}

- (void)setSelectedItems:(NSArray *)selectedItems {
	NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
	for (id item in selectedItems) {
		NSInteger index = [self rowForItem:item];
        if (index != SSTableViewRowNotFound) {
            [indexes addIndex:index];
        }
	}
	[self selectRowIndexes:indexes byExtendingSelection:NO];
}

- (NSMenuItem *)menuItemForNode:(NSTreeNode *)node {
    id representedObject = node.representedObject;
    NSImage *sourceListItemImage = nil;
    if ([representedObject respondsToSelector:@selector(image)]) {
        sourceListItemImage = [[[representedObject image] copy] autorelease];
    } else {
        sourceListItemImage = [[[representedObject nonControllerMarkerValueForKey:@"image"] copy] autorelease];
    }
    
#if !defined(__MAC_10_7)
    sourceListItemImage.flipped = NO;
    sourceListItemImage.size = SSSizeMakeSquare(16.0);
#endif
	
    NSString *sourceListItemTitle = nil;
    if ([representedObject respondsToSelector:@selector(title)]) {
        sourceListItemTitle = [representedObject title];
    } else {
        sourceListItemTitle = [[representedObject nonControllerMarkerValueForKey:@"title"] stringByAppendingElipsisAfterCharacters:30];
    }
        
#if 0
    if ([representedObject respondsToSelector:@selector(badgeLabel)] && [representedObject badgeLabel]) {
        sourceListItemTitle = [sourceListItemTitle stringByAppendingFormat:@" (%@)", [representedObject badgeLabel]];
    }
#endif

	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    menuItem.image = sourceListItemImage;
    menuItem.title = sourceListItemTitle ? sourceListItemTitle : @"";
    menuItem.enabled = ([self.delegate respondsToSelector:@selector(outlineView:shouldSelectItem:)] ? [self.delegate outlineView:self shouldSelectItem:node] : YES);
    menuItem.indentationLevel = (node.indexPath.length - 1);
    menuItem.representedObject = representedObject;
	
	return [menuItem autorelease];
}

- (void)addChildNodes:(NSTreeNode *)node to:(NSMenu *)menu {
	for (NSTreeNode *currentNode in node.childNodes) {
		@autoreleasepool {
            NSMenuItem *menuItem = [self menuItemForNode:currentNode];
            if (!menuItem) {
                break;
            }
            
            [menu addItem:menuItem];
            
            [self addChildNodes:currentNode to:menu];
        }
	}
}

- (NSMenu *)sourceMenu {
	NSTreeNode *rootNode = self.contentController.arrangedObjects;
    if (NSIsControllerMarker(rootNode)) {
        return nil;
    }
    
	NSArray *childNodes = rootNode.childNodes;
    if (!childNodes.count) {
        return nil;
    }
    
	NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
	
    for (NSTreeNode *rootChild in childNodes) {
        @autoreleasepool {
            NSMenuItem *rootMenuItem = [self menuItemForNode:rootChild];
            if (!rootMenuItem) {
                break;
            }
            
            [menu addItem:rootMenuItem];
            
            [self addChildNodes:rootChild to:menu];
            
            if (rootChild != childNodes.lastObject) {
                [menu addItem:[NSMenuItem separatorItem]];
            }
        }
    }
    
	return [menu autorelease];
}

- (NSArray *)itemsAtRowsWithIndexes:(NSIndexSet *)indexes {
    NSMutableArray *items = [NSMutableArray array];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id item = [self itemAtRow:idx];
        if (!item) {
            *stop = YES;
        } else {
            [items addObject:item];
        }
    }];
    return items;
}

@end


