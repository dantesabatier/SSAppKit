//
//  SSThemedScrollView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 11/24/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SSThemedView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSThemedScrollView : NSScrollView <SSThemedView> {
@private
    id <SSTheme> _theme;
}

@property (nullable, nonatomic, strong) id <SSTheme> theme;

@end

NS_ASSUME_NONNULL_END
