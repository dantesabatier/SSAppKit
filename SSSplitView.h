//
//  SSSplitView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2012 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class SSSplitView;
@protocol SSSplitViewDelegate <NSSplitViewDelegate>

@optional
- (void)splitViewWillCollapseSubview:(SSSplitView *)splitView;
- (void)splitViewDidCollapseSubview:(SSSplitView *)splitView;
- (void)splitViewWillExpandSubview:(SSSplitView *)splitView;
- (void)splitViewDidExpandSubview:(SSSplitView *)splitView;
- (NSTimeInterval)animationDurationForCollapsibleSubviewOfSplitView:(SSSplitView *)splitView;

@end

@interface SSSplitView : NSSplitView {
@private
    __ss_weak NSView *_collapsibleSubview;
    NSMutableDictionary *_minValues;
    NSMutableDictionary *_maxValues;
    NSView *_resizableSubview;
    NSColor *_color;
    CGFloat _uncollapsedSize;
    CGFloat _defaultUncollapsedSize;
    NSInteger _collapsibleDividerIndex;
    NSInteger _collapsibleSubviewIndex;
    BOOL _animating;
    BOOL _isCollapsibleSubviewCollapsed;
    id _secondaryDelegate;
}

@property (nullable, nonatomic, ss_weak) IBOutlet NSView *collapsibleSubview;
@property (nullable, nonatomic, strong) NSDictionary *minValues;
@property (nullable, nonatomic, strong) NSDictionary *maxValues;
@property (nullable, nonatomic, strong) NSColor *color;
@property CGFloat defaultUncollapsedSize;
@property (readonly) BOOL isCollapsibleSubviewCollapsed;
@property (readonly) BOOL isAnimating;

- (IBAction)toggleCollapse:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
