//
//  NSTreeController+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSTreeController+SSAdditions.h"

@implementation NSTreeController(SSAdditions)

- (void)removeObject:(id)object {
    NSIndexPath *indexPath = [self indexPathToObject:object];
    if (indexPath) {
        [self removeObjectAtArrangedObjectIndexPath:indexPath];
    }
}

- (void)removeObjects:(NSArray *)objects {
    for (id object in objects) {
        [self removeObject:object];
    }
}

- (void)setSelectedObjects:(NSArray *)objects {
    if ([self.selectedObjects isEqualToArray:objects]) {
         return;
    }
    
	NSMutableArray *indexPaths = [NSMutableArray array];
	for (id object in objects) {
		NSIndexPath *indexPath = [self indexPathToObject:object];
		if (indexPath)
            [indexPaths addObject:indexPath];
	}
	
	[self setSelectionIndexPaths:indexPaths];
}

- (NSIndexPath *)_indexPathToObject:(id)object inTree:(NSTreeNode *)node {
	if (object) {
        for (NSTreeNode *currentNode in node.childNodes) {
            if (currentNode.representedObject == object) {
                return currentNode.indexPath;
            }
            
            NSIndexPath *indexPath = [self _indexPathToObject:object inTree:currentNode];
            if (indexPath) {
                return indexPath;
            }
        }
    }
	return nil;
}

- (NSIndexPath *)indexPathToObject:(id)object {
	return [self _indexPathToObject:object inTree:self.arrangedObjects];
}

- (NSTreeNode *)_nodeAtIndexPath:(NSIndexPath *)indexPath inTree:(NSTreeNode *)node {
	if (indexPath) {
        for (NSTreeNode *currentNode in node.childNodes) {
            if ([currentNode.indexPath compare:indexPath] == NSOrderedSame) {
                return currentNode;
            }
            
            NSTreeNode *node = [self _nodeAtIndexPath:indexPath inTree:currentNode];
            if (node) {
                return node;
            }
        }
    }
	return nil;
}

- (NSTreeNode *)nodeAtArrangedNodeIndexPath:(NSIndexPath *)indexPath {
    return [self _nodeAtIndexPath:indexPath inTree:self.arrangedObjects];
}

- (id)objectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath {
    return [self nodeAtArrangedNodeIndexPath:indexPath].representedObject;
}

@end
