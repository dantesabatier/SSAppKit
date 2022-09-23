//
//  SSSourceListButtonCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSourceListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSSourceListButtonCell : SSSourceListCell {
@package
	NSButtonCell *_buttonCell;
}

@property (nullable, readonly, copy) NSButtonCell *buttonCell;
- (CGRect)buttonRectForBounds:(CGRect)bounds;

@end

NS_ASSUME_NONNULL_END
