//
//  SSDetachableScroller.h
//  SSAppKit
//
//  Created by Dante Sabatier on 3/7/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface SSDetachableScroller : NSScroller {
@private
    NSUInteger _numberOfIncrements;
}

@property NSUInteger numberOfIncrements;

@end
