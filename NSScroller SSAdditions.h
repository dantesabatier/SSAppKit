//
//  NSScroller+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 2/9/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

typedef NS_ENUM(NSInteger, SSScrollerArrowsSetting) {
	SSScrollerArrowsTogether = 0,
	SSScrollerArrowsApart = 1,
};

@interface NSScroller (SSAdditions)

@property (nonatomic, assign, readonly) SSScrollerArrowsSetting arrowsSetting;
@property (nonatomic, assign, readonly) BOOL isVertical;
@property (nonatomic, assign, readonly) BOOL isOverlaid;
@property (nonatomic, assign, readonly) BOOL isOutsideControl;

@end
