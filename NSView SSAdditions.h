//
//  NSView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 8/17/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSGeometry.h>
#import "NSScrollView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

#define SSViewAutoresizingAll (NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewHeightSizable|NSViewMaxYMargin)

typedef NS_OPTIONS(NSUInteger, SSViewTransitionOptions) {
    SSViewTransitionNone = 0,
    SSViewTransitionCrossfade = 1UL << 1,
    SSViewTransitionFlip = 1UL << 2,
    SSViewTransitionSlideUp = 1UL << 3,
    SSViewTransitionSlideDown = 1UL << 4,
    SSViewTransitionSlideLeft = 1UL << 5,
    SSViewTransitionSlideRight = 1UL << 6,
};

@interface NSView (SSAdditions) <NSCopying>

@property (nullable, nonatomic, readonly, ss_weak) __kindof NSViewController *viewController;
@property (nullable, nonatomic, ss_strong) __kindof NSView *presentingView;
- (void)setPresentingView:(NSView *)presentingView animated:(BOOL)animated NS_AVAILABLE_MAC(10_6);
#if NS_BLOCKS_AVAILABLE
- (void)setPresentingView:(NSView *)presentingView options:(SSViewTransitionOptions)options completion:(void (^__nullable)(void))completion NS_AVAILABLE_MAC(10_6);
- (void)transitionFromView:(NSView *)fromView toView:(NSView *)toView options:(SSViewTransitionOptions)options completion:(void (^__nullable)(void))completion NS_AVAILABLE_MAC(10_6);
#endif
@property (nullable, nonatomic, readonly, ss_strong) NSImage *imageRepresentation;
@property (nonatomic, readonly, ss_strong) NSGradient *tableHeaderViewBackgroundGradient;
@property (nonatomic, readonly, assign) CGRect clippingVisibleRect;
@property (nonatomic, readonly, assign) BOOL needsDisplayWhenWindowResignsKey;
@property (nonatomic, assign) CGSize frameSize;
@property (nonatomic, readonly, assign) CGFloat scale;
@property (nonatomic, assign) CGPoint center;
- (BOOL)centerRectInVisibleArea:(CGRect)rect;
- (void)setNeedsDisplay;
@property (nonatomic, assign, readonly) BOOL effectiveAppearanceIsDark;
- (void)addConstraintsWithFormat:(NSString *)format views:(NSArray <NSView *>*)views;

@end

NS_ASSUME_NONNULL_END

