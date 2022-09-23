//
//  SSInspectorCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSInspectorCell.h"
#import "SSInspectorHeaderView.h"
#import "SSValidatedButton.h"
#import <QuartzCore/QuartzCore.h>
#import <SSBase/SSGeometry.h>

@interface SSInspectorCell ()
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_12)) || ((TARGET_OS_EMBEDDED || TARGET_OS_IPHONE) && defined(__IPHONE_10_0)))
<CAAnimationDelegate>
#endif

@end

@implementation SSInspectorCell

#pragma mark life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _flags.animates = 0;
        _flags.expanded = 1;
        _expandedHeight = CGRectGetHeight(frame);
        
        _headerView = [[SSInspectorHeaderView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - 17.0, CGRectGetWidth(frame), 17.0)];
        _headerView.target = self;
        _headerView.action = @selector(toggle:);
        
        [self addSubview:_headerView];
        
        _contentViewPlaceholder = [[NSView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame) - 17.0)];
        
        [self addSubview:_contentViewPlaceholder];
        
        if (islessequal(_expandedHeight, CGRectGetHeight(_headerView.frame))) {
            SSDebugLog(@"%@(%@) %@, Warning!, invalid content size…", self.class, _headerView.title, NSStringFromSelector(_cmd));
        }
	}
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	_delegate = nil;
    _inspectorItem = nil;
    
    [_contentViewPlaceholder release];
	[_headerView release];

	[super ss_dealloc];
}

#pragma mark layout

- (void)layout {
    [super layout];
    
    if (_flags.animating) {
        return;
    }
    
    [self sizeToFit];
    
    CGRect headerFrame;
    CGRect contentFrame;
    CGRectDivide(self.bounds, &headerFrame, &contentFrame, CGRectGetHeight(_headerView.frame), CGRectMinYEdge);
    
    _headerView.frame = headerFrame;
    _contentViewPlaceholder.frame = contentFrame;
    _contentViewPlaceholder.presentingView.frame = _contentViewPlaceholder.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (_flags.expanded) {
        if (islessequal(_expandedHeight, CGRectGetHeight(_headerView.frame))) {
            SSDebugLog(@"%@(%@) %@, Warning!, invalid content size…", self.class, _headerView.title, NSStringFromSelector(_cmd));
        }
        return CGSizeMake(CGRectGetWidth(self.frame), _expandedHeight);
    }
    return CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(_headerView.frame));
}

#pragma mark actions

- (void)toggle:(id)sender {
    if (_flags.animates && _flags.animating) {
        return;
    }
    
    if (_flags.expanded && [self.delegate respondsToSelector:@selector(inspectorCellWillCollapse:)]) {
        [self.delegate inspectorCellWillCollapse:self];
    } else if ([self.delegate respondsToSelector:@selector(inspectorCellWillExpand:)]) {
        [self.delegate inspectorCellWillExpand:self];
    }
    
    if (!sender || ![sender infoForBinding:SSValueBinding]) {
        _flags.expanded = !_flags.expanded;
    }
    
	CGRect frame = self.frame;
	CGSize size = self.headerView.frame.size;
    if (_flags.expanded) {
        size.height = _expandedHeight;
    }
    
    if (!self.superview.isFlipped) {
        frame.origin.y += (frame.size.height - size.height);
    }
    
	frame.size = size;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        _flags.animating = 0;
        if (_flags.expanded) {
            if ([self.delegate respondsToSelector:@selector(inspectorCellDidExpand:)]) {
                [self.delegate inspectorCellDidExpand:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(inspectorCellDidCollapse:)]) {
                [self.delegate inspectorCellDidCollapse:self];
            }
        }
    }];
    
    NSView *view = _flags.animates ? self.animator : self;
    view.frame = frame;
    
    //NSView *contentView = _flags.animates ? _contentViewPlaceholder.presentingView.animator : _contentViewPlaceholder.presentingView;
    //contentView.alphaValue = _flags.expanded ? 1.0 : 0.0;
    [CATransaction commit];
}

#pragma mark SSButtonValidations

- (BOOL)validateButton:(id <SSValidatedButton>)button {
    NSButton *validatedButton = (NSButton *)button;
    SEL action = validatedButton.action;
    if (action == @selector(toggle:)) {
        if (!_flags.animating) {
            validatedButton.state = _flags.expanded;
        }
    }
	return YES;
}

#pragma mark NSView

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    if (!_flags.expanded) {
        NSView *contentView = _contentViewPlaceholder.presentingView;
        [contentView setFrameSize:CGSizeMake(CGRectGetWidth(self.frame), MAX(CGRectGetHeight(contentView.frame), _expandedHeight))];
    }
}

#pragma mark getters & setters

- (id<SSInspectorCellDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSInspectorCellDelegate>)delegate {
    _delegate = delegate;
}

- (SSInspectorHeaderView *)headerView {
    return _headerView;
}

- (id)contentView {
    return _contentViewPlaceholder.presentingView;
}

- (void)setContentView:(id)contentView {
    id presentingView = _contentViewPlaceholder.presentingView;
    if ([presentingView isEqual:contentView]) {
        return;
    }
    
    [presentingView removeFromSuperview];
    
    _contentViewPlaceholder.presentingView = contentView;
    
    [self layout];
}

- (SSInspectorItem *)inspectorItem {
    return _inspectorItem;
}

- (void)setInspectorItem:(SSInspectorItem *)inspectorItem {
    _inspectorItem = inspectorItem;
}

- (BOOL)animates {
    return _flags.animates;
}

- (void)setAnimates:(BOOL)animates {
    _flags.animates = animates;
}

- (BOOL)isAnimating {
    return _flags.animating;
}

- (BOOL)isExpanded {
    return _flags.expanded;
}

- (BOOL)isFlipped {
    return YES;
}

@end
