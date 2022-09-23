//
//  NSWindow+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWindow(SSAdditions)

@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, assign, readonly) BOOL isActive;
@property (nonatomic, assign, readonly) BOOL inFullScreenMode;
- (void)animateToFrame:(CGRect)frameRect duration:(NSTimeInterval)duration;
- (void)flipToWindow:(NSWindow *)window withDuration:(CFTimeInterval)duration edge:(NSRectEdge)edge shadowed:(BOOL)shadowed;

@end

NS_ASSUME_NONNULL_END

