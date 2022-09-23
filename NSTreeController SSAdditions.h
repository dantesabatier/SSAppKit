//
//  NSTreeController+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTreeController(SSAdditions)

@property (readwrite, copy) NSArray *selectedObjects;
- (nullable NSIndexPath *)indexPathToObject:(id)object;
- (nullable id)objectAtArrangedObjectIndexPath:(NSIndexPath *)indexPath;
- (nullable NSTreeNode *)nodeAtArrangedNodeIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
