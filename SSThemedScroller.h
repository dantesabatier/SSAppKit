//
//  SSThemedScroller.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSDetachableScroller.h"
#import "SSThemedView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSThemedScroller : SSDetachableScroller <SSThemedView> {
@private
    CGColorRef _backgroundColor;
    id <SSTheme> _theme;
}

@property (nullable, nonatomic, strong) id <SSTheme> theme;
@property (nullable, readonly) CGColorRef backgroundColor;
@property (readonly, getter=isThemed) BOOL themed;

@end

NS_ASSUME_NONNULL_END
