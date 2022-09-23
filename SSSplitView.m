//
//  SSSplitView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2012 Dante Sabatier. All rights reserved.
//


#import "SSSplitView.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <QuartzCore/CAMediaTimingFunction.h>

static CGFloat _SVDefaultUncollapsedSize = 120.0;

#define dimpleDimension ((CGFloat)4.0)

@interface SSSplitView() 

- (CGFloat)minimumSizeOfSubviewAt:(NSInteger)dividerIndex;
- (CGFloat)maximumSizeOfSubviewAt:(NSInteger)dividerIndex;

@end

@implementation SSSplitView

@synthesize minValues = _minValues;
@synthesize maxValues = _maxValues;
@synthesize isCollapsibleSubviewCollapsed = _isCollapsibleSubviewCollapsed;
@synthesize collapsibleSubview = _collapsibleSubview;
@synthesize isAnimating = _animating;
@synthesize color = _color;
@synthesize defaultUncollapsedSize = _defaultUncollapsedSize;

#pragma mark life cycle

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.delegate = super.delegate;
        super.delegate = (id)self;
		
		_collapsibleDividerIndex = 0;
		_collapsibleSubviewIndex = 1;
        _defaultUncollapsedSize = _SVDefaultUncollapsedSize;
        _maxValues = [[NSMutableDictionary alloc] init];
        _minValues = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collapsibleDividerIndex = 0;
        _collapsibleSubviewIndex = 1;
        _defaultUncollapsedSize = _SVDefaultUncollapsedSize;
        _maxValues = [[NSMutableDictionary alloc] init];
        _minValues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
	super.delegate = _secondaryDelegate;
	
    [super encodeWithCoder:coder];
    
    self.delegate = super.delegate;
    super.delegate = (id)self;
}

- (void)dealloc {
    _secondaryDelegate = nil;
	_collapsibleSubview = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:_secondaryDelegate];
	
	[_color release];
	[_minValues release];
	[_maxValues release];

	[super ss_dealloc];
}

- (void)awakeFromNib {
    if (self.collapsibleSubview) {
        _collapsibleSubviewIndex = [self.subviews indexOfObject:self.collapsibleSubview];
        _collapsibleDividerIndex = (self.subviews.count != 2) ? (_collapsibleSubviewIndex - 1) : 0;
        _resizableSubview = (self.subviews)[!_collapsibleSubviewIndex ? 1 : (_collapsibleSubviewIndex - 1)];
    }
}

- (void)prepareForInterfaceBuilder {
    
}

- (void)drawGradientDividerInRect:(CGRect)aRect {
    CGRect bounds = [self centerScanRect:aRect];
    NSString *backgroundImageName = nil;
    NSString *dimpleImageName = nil;
    
    if (self.isVertical) {
        backgroundImageName = @"panesplitter-vert-bg";
        dimpleImageName = @"panesplitter-vert-dimple";
    } else {
        backgroundImageName = @"panesplitter-horiz-bg";
        dimpleImageName = @"panesplitter-horiz-dimple";
    }
    
    NSImage *backgroundImage = SSAppKitGetImageResourceNamed(backgroundImageName);
    NSImage *dimpleImage = SSAppKitGetImageResourceNamed(dimpleImageName);
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    context.patternPhase = CGPointMake(CGRectGetMinX([self convertRect:bounds toView:nil]), CGRectGetMaxY([self convertRect:bounds toView:nil]));
    
    [[NSColor colorWithPatternImage:backgroundImage] set];
    NSRectFill(bounds);
    
    [dimpleImage drawInRect:SSRectCenteredSize(bounds, dimpleImage.size) fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    [context restoreGraphicsState];
}

- (void)drawDividerInRect:(CGRect)aRect {
    if (self.dividerThickness < 1.01) {
        if (self.color) {
            if (self.color.alphaComponent < 1.0) {
                [self.color setFill];
                NSRectFill(aRect);
            } else
                [self.color drawSwatchInRect:aRect];
        } else
            [super drawDividerInRect:aRect];
    } else
        [self drawGradientDividerInRect:aRect];
}

#pragma mark resizing

- (void)adjustSubviews {
    [super adjustSubviews];
	[self.window invalidateCursorRectsForView:self];
}

- (void)resizeSubviewsWithArguments:(id)arguments {
	CGFloat position = [arguments[@"position"] floatValue];
	CGFloat minimumSize = [arguments[@"minimumSize"] floatValue];
	CGFloat maximumSize = [arguments[@"maximumSize"] floatValue];
	
	[self setPosition:position ofDividerAtIndex:_collapsibleDividerIndex];
	
	(_minValues)[@(_collapsibleSubviewIndex)] = @(minimumSize);
	(_maxValues)[@(_collapsibleSubviewIndex)] = @(maximumSize);
    
	[self adjustSubviews];
    
	if (self.isCollapsibleSubviewCollapsed) {
        if ([_secondaryDelegate respondsToSelector:@selector(splitViewDidCollapseSubview:)])
            [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewDidCollapseSubview:self];
    } else {
        if ([_secondaryDelegate respondsToSelector:@selector(splitViewDidExpandSubview:)])
            [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewDidExpandSubview:self];
    }
	
	_animating = NO;
}

- (IBAction)toggleCollapse:(id)sender {
	if (!_collapsibleSubview || !_resizableSubview || _animating)
        return;
    
	_animating = YES;
	
	CGFloat minimumSize = [self minimumSizeOfSubviewAt:_collapsibleSubviewIndex];
	CGFloat maximumSize = [self maximumSizeOfSubviewAt:_collapsibleSubviewIndex];
    
    [_minValues removeObjectForKey:@(_collapsibleSubviewIndex)];
    [_maxValues removeObjectForKey:@(_collapsibleSubviewIndex)];
	
	NSTimeInterval animationDuration = 0;
    if ([_secondaryDelegate respondsToSelector:@selector(animationDurationForCollapsibleSubviewOfSplitView:)])
        animationDuration = [(id <SSSplitViewDelegate>) _secondaryDelegate animationDurationForCollapsibleSubviewOfSplitView:self];
	
    if (_uncollapsedSize <= 1.0) {
        _uncollapsedSize = self.isVertical ? CGRectGetWidth(_collapsibleSubview.frame) : CGRectGetHeight(_collapsibleSubview.frame);
    }
    
	if (_uncollapsedSize <= 1.0) {
		_uncollapsedSize = _defaultUncollapsedSize ? _defaultUncollapsedSize : (minimumSize ? minimumSize : _SVDefaultUncollapsedSize);
		_isCollapsibleSubviewCollapsed = YES;
	}
    
    if (maximumSize && maximumSize < _uncollapsedSize) {
        _uncollapsedSize = maximumSize;
    }
    
    //SSDebugLog(@"%@(%@) %@ %@ subview:%ld max:%.1f min:%.1f default:%.1f effective:%.1f", self.class, self.autosaveName, NSStringFromSelector(_cmd), _isCollapsibleSubviewCollapsed ? @"Expanding" : @"Collapsing", _collapsibleSubviewIndex, maximumSize, minimumSize, _defaultUncollapsedSize, _uncollapsedSize);
    
	CGFloat dividersSize = self.dividerThickness;
	CGFloat baseOrigin = 0;
	CGFloat position = 0;
    CGSize collapsibleSubviewSize = NSZeroSize;
    CGSize resizableSubviewSize = NSZeroSize;
    
	if (self.isVertical) {
		CGFloat constantHeight = CGRectGetHeight(_collapsibleSubview.frame);
		
		if (!_isCollapsibleSubviewCollapsed) {
            if ([_secondaryDelegate respondsToSelector:@selector(splitViewWillCollapseSubview:)]) {
                [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewWillCollapseSubview:self];
            }
            
            collapsibleSubviewSize = CGSizeMake(baseOrigin, constantHeight);
            resizableSubviewSize = CGSizeMake((CGRectGetWidth(_resizableSubview.frame) + _uncollapsedSize), constantHeight);
            
			_isCollapsibleSubviewCollapsed = YES;
            
			position = !_collapsibleSubviewIndex ? 0.0 : CGRectGetWidth(self.bounds) - dividersSize;
		} else {
            if ([_secondaryDelegate respondsToSelector:@selector(splitViewWillExpandSubview:)]) {
                [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewWillExpandSubview:self];
            }
            
			collapsibleSubviewSize = CGSizeMake(_uncollapsedSize, constantHeight);
            resizableSubviewSize = CGSizeMake((CGRectGetWidth(_resizableSubview.frame) - _uncollapsedSize) - dividersSize, constantHeight);
			
			_isCollapsibleSubviewCollapsed = NO;
			
			position = !_collapsibleSubviewIndex ? _uncollapsedSize : (CGRectGetWidth(self.bounds) - _uncollapsedSize - dividersSize);
		}
	} else {
		CGFloat constantWidth = CGRectGetWidth(_collapsibleSubview.frame);
		
		if (!_isCollapsibleSubviewCollapsed) {
            if ([_secondaryDelegate respondsToSelector:@selector(splitViewWillCollapseSubview:)]) {
                [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewWillCollapseSubview:self];
            }
			
            collapsibleSubviewSize = CGSizeMake(constantWidth, baseOrigin);
            resizableSubviewSize = CGSizeMake(constantWidth, (CGRectGetHeight(_resizableSubview.frame) + _uncollapsedSize));
			
			_isCollapsibleSubviewCollapsed = YES;
			
			position = !_collapsibleSubviewIndex ? 0.0 : CGRectGetHeight(self.bounds) - dividersSize;
		} else {
            if ([_secondaryDelegate respondsToSelector:@selector(splitViewWillExpandSubview:)]) {
                [(id <SSSplitViewDelegate>)_secondaryDelegate splitViewWillExpandSubview:self];
            }
            
			collapsibleSubviewSize = CGSizeMake(constantWidth, _uncollapsedSize);
            resizableSubviewSize = CGSizeMake(constantWidth, (CGRectGetHeight(_resizableSubview.frame) - _uncollapsedSize) - dividersSize);
			
			_isCollapsibleSubviewCollapsed = NO;
            
			position = !_collapsibleSubviewIndex ? _uncollapsedSize : (CGRectGetHeight(self.bounds) - _uncollapsedSize - dividersSize);
		}
	}
    
    id collapsibleSubview = _collapsibleSubview;
    id resizableSubview = _resizableSubview;
    if (animationDuration > 0) {
        collapsibleSubview = _collapsibleSubview.animator;
        resizableSubview = _resizableSubview.animator;
    }
    
#if defined(__MAC_10_7)
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = animationDuration;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [collapsibleSubview setFrameSize:collapsibleSubviewSize];
        [resizableSubview setFrameSize:resizableSubviewSize];
    } completionHandler:^{
        [self resizeSubviewsWithArguments:@{@"position": @(position), @"minimumSize": @(minimumSize), @"maximumSize": @(maximumSize)}];
    }];
#else
    [NSAnimationContext beginGrouping];
    [NSAnimationContext currentContext].duration = animationDuration;
    
    [collapsibleSubview setFrameSize:collapsibleSubviewSize];
    [resizableSubview setFrameSize:resizableSubviewSize];
    
    [NSAnimationContext endGrouping];
    
    [self performLatestRequestOfSelector:@selector(resizeSubviewsWithArguments:) withObject:@{@"position": @(position), @"minimumSize": @(minimumSize), @"maximumSize": @(maximumSize)} afterDelay:animationDuration inModes:@[NSDefaultRunLoopMode, NSModalPanelRunLoopMode]];
#endif
    
}

#pragma mark events

- (void)mouseDown:(NSEvent *)theEvent {
	[super mouseDown:theEvent];
    
	if (self.collapsibleSubview) {
		CGFloat collapsibleViewSize = self.isVertical ? CGRectGetWidth((self.collapsibleSubview).frame) : CGRectGetHeight((self.collapsibleSubview).frame);
		if (!self.isAnimating && (collapsibleViewSize != _uncollapsedSize))
            _uncollapsedSize = collapsibleViewSize;
	}
}

#pragma mark NSSplitView delegate

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
	return self.collapsibleSubview ? (dividerIndex == _collapsibleDividerIndex) : NO;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
	return subview == self.collapsibleSubview;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:shouldCollapseSubview:forDoubleClickOnDividerAtIndex:)]) {
        return [_secondaryDelegate splitView:self shouldCollapseSubview:subview forDoubleClickOnDividerAtIndex:dividerIndex];
    }
	return (self.dividerStyle != NSSplitViewDividerStyleThin && [self splitView:self shouldHideDividerAtIndex:dividerIndex]);
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)]) {
         return [_secondaryDelegate splitView:self constrainMinCoordinate:proposedMinimumPosition ofSubviewAt:dividerIndex];
    }
    
	CGFloat minimumPositionFromThisView = proposedMinimumPosition;
	CGFloat maximumPositionFromNextView = proposedMinimumPosition;
	
	// Min from this subview
	CGFloat minValue = [self minimumSizeOfSubviewAt:dividerIndex];
	if (minValue != 0) {
		NSView *subview = (self.subviews)[dividerIndex];
		CGFloat originCoord = self.isVertical ? subview.frame.origin.x : subview.frame.origin.y;
		
		minimumPositionFromThisView = originCoord + minValue;
	}
	
	// Min from the next subview
	NSInteger nextViewIndex = dividerIndex + 1;
	if (self.subviews.count > nextViewIndex) {
		CGFloat maxValue = [self maximumSizeOfSubviewAt:nextViewIndex];
		if (maxValue != CGFLOAT_MAX) {
			NSView *subview = (self.subviews)[nextViewIndex];
			CGFloat endCoord = self.isVertical ? subview.frame.origin.x + subview.frame.size.width : subview.frame.origin.y + subview.frame.size.height;
			
			//FIXME:This could cause trouble when over constrained
			maximumPositionFromNextView = endCoord - maxValue - self.dividerThickness;
		}
	}
	
	CGFloat newMin = MAX(minimumPositionFromThisView, maximumPositionFromNextView);
	
	if (newMin > proposedMinimumPosition)
		return newMin;
	
	return proposedMinimumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)]) {
        return [_secondaryDelegate splitView:self constrainMaxCoordinate:proposedMaximumPosition ofSubviewAt:dividerIndex];
    }
    
	CGFloat maximumPositionFromThisView = proposedMaximumPosition;
	CGFloat maximumPositionFromNextView = proposedMaximumPosition;
	
	// Max from this subview
	CGFloat maxValue = [self maximumSizeOfSubviewAt:dividerIndex];
	if (maxValue != CGFLOAT_MAX) {
		NSView *subview = (self.subviews)[dividerIndex];
		CGFloat originCoord = self.isVertical ? subview.frame.origin.x : subview.frame.origin.y;
		
		maximumPositionFromThisView = originCoord + maxValue;
	}
	
	// Max from the next subview
	NSInteger nextViewIndex = dividerIndex + 1;
	if (self.subviews.count > nextViewIndex) {
		CGFloat minValue = [self minimumSizeOfSubviewAt:nextViewIndex];
		if (minValue != 0) {
			NSView *subview = (self.subviews)[nextViewIndex];
			CGFloat endCoord = self.isVertical ? subview.frame.origin.x + subview.frame.size.width : subview.frame.origin.y + subview.frame.size.height;
			//FIXME:This could cause trouble when over constrained
			maximumPositionFromNextView = endCoord - minValue - self.dividerThickness;
		}
	}
	
	CGFloat newMax = MIN(maximumPositionFromThisView, maximumPositionFromNextView);
	if (newMax < proposedMaximumPosition)
        return newMax;
	return proposedMaximumPosition;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)]) {
        return [_secondaryDelegate splitView:self constrainSplitPosition:proposedPosition ofSubviewAt:dividerIndex];
    }
	return proposedPosition;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(CGSize)oldSize {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:resizeSubviewsWithOldSize:)]) {
        [_secondaryDelegate splitView:self resizeSubviewsWithOldSize:oldSize];
    } else {
        CGFloat dividerThickness = self.dividerThickness;
        CGFloat constantWidth = MAX(CGRectGetWidth(self.frame), 0);
        CGFloat constantHeight = MAX(CGRectGetHeight(self.frame), 0);
        NSView *collapsibleSubview = self.collapsibleSubview;
        if (!collapsibleSubview) collapsibleSubview = (self.subviews)[0];
        NSInteger collapsibleSubviewIndex = [self.subviews indexOfObject:collapsibleSubview];
        NSView *resizableSubview = (self.subviews)[collapsibleSubviewIndex ? 0 : 1];
        NSUInteger resizebleSubviewIndex = [self.subviews indexOfObject:resizableSubview];
        CGRect collapsibleViewFrame = collapsibleSubview.frame;
        CGRect resizableViewFrame = resizableSubview.frame;
        
        if (self.isVertical) {
            collapsibleViewFrame.size.height = constantHeight;
            collapsibleViewFrame.size.width = MAX(collapsibleViewFrame.size.width, 0);
            
            resizableViewFrame.size.height = constantHeight;
            resizableViewFrame.size.width = MAX(constantWidth - collapsibleViewFrame.size.width - dividerThickness, 0);
            
            if (resizebleSubviewIndex) {
                resizableViewFrame.origin.x = collapsibleViewFrame.size.width + dividerThickness;
            } else {
                collapsibleViewFrame.origin.x = resizableViewFrame.size.width + dividerThickness;
            }
        } else {
            collapsibleViewFrame.size.width = constantWidth;
            collapsibleViewFrame.size.height = MAX(CGRectGetHeight(collapsibleViewFrame), 0);
            
            resizableViewFrame.size.width = constantWidth;
            resizableViewFrame.size.height = MAX(constantHeight - CGRectGetHeight(collapsibleViewFrame) - dividerThickness, 0);
            
            if (resizebleSubviewIndex) {
                resizableViewFrame.origin.y = CGRectGetHeight(collapsibleViewFrame) + dividerThickness;
            } else {
                collapsibleViewFrame.origin.y = CGRectGetHeight(resizableViewFrame) + dividerThickness;
            }
        }
        
        collapsibleSubview.frame = CGRectIntegral(collapsibleViewFrame);
        resizableSubview.frame = CGRectIntegral(resizableViewFrame);
        
        [self adjustSubviews];
    }
}

- (CGRect)splitView:(NSSplitView *)splitView effectiveRect:(CGRect)proposedEffectiveRect forDrawnRect:(CGRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:effectiveRect:forDrawnRect:ofDividerAtIndex:)]) {
        return [_secondaryDelegate splitView:self effectiveRect:proposedEffectiveRect forDrawnRect:drawnRect ofDividerAtIndex:dividerIndex];
    }
	return proposedEffectiveRect;
}

- (CGRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitView:additionalEffectiveRectOfDividerAtIndex:)]) {
        return [_secondaryDelegate splitView:self additionalEffectiveRectOfDividerAtIndex:dividerIndex];
    }
	return CGRectZero;
}

- (void)splitViewWillResizeSubviews:(NSNotification *)notification {
	if (!self.isAnimating) {
		if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitViewWillResizeSubviews:)]) {
			[_secondaryDelegate splitViewWillResizeSubviews:notification];
			return;
		}
	}
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
	if (!self.isAnimating) {
		if (_secondaryDelegate && [_secondaryDelegate respondsToSelector:@selector(splitViewDidResizeSubviews:)]) {
			[_secondaryDelegate splitViewDidResizeSubviews:notification];
			return;
		}
	}
}

#pragma mark helpers

- (CGFloat)minimumSizeOfSubviewAt:(NSInteger)dividerIndex {
	NSNumber *minNum = (self.minValues)[@(dividerIndex)];
	return minNum ? minNum.floatValue : 0.0;
}

- (CGFloat)maximumSizeOfSubviewAt:(NSInteger)dividerIndex {
	NSNumber *maxNum = (self.maxValues)[@(dividerIndex)];
	return maxNum ? maxNum.floatValue : CGFLOAT_MAX;
}

#pragma mark getters & setters

- (void)setVertical:(BOOL)flag {
	super.vertical = flag;
	
	_uncollapsedSize = 0.0;
}

- (void)setDelegate:(id)value {
    if (_secondaryDelegate != self) {
        _secondaryDelegate = value;
    } else {
         _secondaryDelegate = nil;
    }
}

- (BOOL)isCollapsibleSubviewCollapsed {
    if (!self.collapsibleSubview) {
        return NO;
    }
    
	CGFloat uncollapsedLength = self.isVertical ? CGRectGetWidth(self.collapsibleSubview.frame) : CGRectGetHeight(self.collapsibleSubview.frame);
	_isCollapsibleSubviewCollapsed = ([self isSubviewCollapsed:self.collapsibleSubview] || (uncollapsedLength <= 1.0));
	
	return _isCollapsibleSubviewCollapsed;
}

- (CGFloat)dividerThickness {
    if (self.dividerStyle == NSSplitViewDividerStyleThin) {
        return super.dividerThickness;
    }
    CGFloat dividerThickness = 10.0;
#if 0
    if (self.isVertical) {
        dividerThickness = 8.0;
    }
#endif
	return dividerThickness;
}

- (NSDictionary *)minValues {
    return _minValues;
}

- (void)setMinValues:(NSDictionary *)minValues {
    _minValues.dictionary = minValues;
}

- (NSDictionary *)maxValues {
    return _maxValues;
}

- (void)setMaxValues:(NSDictionary *)maxValues {
    _maxValues.dictionary = maxValues;
}

@end
