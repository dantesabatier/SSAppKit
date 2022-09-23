//
//  SSPopover.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/10/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSPopover.h"
#import "SSPopoverWindow.h"
#import "SSPopoverView.h"
#import "SSViewController.h"
#if TARGET_OS_IPHONE
#import <graphics/SSGraphics.h>
#import <foundation/NSObject+SSAdditions.h>
#else
#import <SSGraphics/SSGraphics.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#endif
#import "QuartzCore/QuartzCore.h"

NSNotificationName SSPopoverWillShowNotification = @"SSPopoverWillShowNotification";
NSNotificationName SSPopoverDidShowNotification = @"SSPopoverDidShowNotification";
NSNotificationName SSPopoverWillCloseNotification = @"SSPopoverWillCloseNotification";
NSNotificationName SSPopoverDidCloseNotification = @"SSPopoverDidCloseNotification";

static CGSize const kSSPopoverDefaultContentSize = {380.0, 180.0};
static CGRect const kSSPopoverDefaultContentRect = {{0, 0}, {380.0, 120.0}};

@interface SSPopover ()
#if TARGET_OS_IPHONE

#else
<NSWindowDelegate>
#endif

@end

@implementation SSPopover

- (instancetype)init {
    self = [super init];
    if (self) {
        _popoverView = [[SSPopoverView alloc] initWithFrame:kSSPopoverDefaultContentRect];
#if TARGET_OS_IPHONE
        _popoverView.shadow = ({
            NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
            shadow.shadowBlurRadius = 6.0;
            shadow.shadowOffset = CGSizeZero;
            shadow.shadowColor = [UIColor blackColor];
            shadow;
        });
#else
        _positioningWindow = [[SSPopoverWindow alloc] initWithContentRect:kSSPopoverDefaultContentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
        _positioningWindow.contentView = _popoverView;
        _positioningWindow.delegate = self;
#endif
        _flags.animates = 1;
        _behavior = SSPopoverBehaviorTransient;
        _preferredEdge = CGRectMaxXEdge;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    
    _positioningView = nil;
    [_positioningWindow release];
    [_contentViewController release];
    [_popoverView release];
    
    [super ss_dealloc];
}

- (void)layout {
    CGFloat extraLength = (_popoverView.arrowSize.height*(CGFloat)2.0) + _popoverView.borderWidth;
    SSView *contentView = (SSView *)((SSViewController *)_contentViewController).view;
    CGSize contentSize = _contentSize;
    if (SSSizeIsEmpty(contentSize)) {
        contentSize = contentView.frame.size;
    }
    
    if (SSSizeIsEmpty(contentSize)) {
        contentSize = kSSPopoverDefaultContentSize;
    }
        
    if (!isnan(extraLength)) {
        contentSize.width += extraLength;
        contentSize.height += extraLength;
    }
    
    _popoverView.subviews = @[];
    _popoverView.frame = CGRectMake(CGRectGetMinX(_popoverView.frame), CGRectGetMinY(_popoverView.frame), contentSize.width, contentSize.height);
    
    if (contentView) {
        contentView.frame = CGRectMake(FLOOR(CGRectGetMinX(_popoverView.frame) + (extraLength*(CGFloat)0.5)), FLOOR(CGRectGetMinY(_popoverView.frame) + (extraLength*(CGFloat)0.5)), FLOOR(CGRectGetWidth(_popoverView.frame) - extraLength), FLOOR(contentSize.height - extraLength));
        [_popoverView addSubview:contentView];
    }
}

- (IBAction)performClose:(id)sender {
#if TARGET_OS_IPHONE
    [_popoverView removeFromSuperview];
#else
    [_positioningWindow makeFirstResponder:_positioningWindow];
    if ([_positioningView.window.childWindows containsObject:_positioningWindow]) {
        [_positioningView.window removeChildWindow:_positioningWindow];
        [_positioningWindow close];
    }
#endif
    
    _flags.shown = 0;
    _flags.closing = 0;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSPopoverDidCloseNotification object:self];
}

#if TARGET_OS_IPHONE
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(__kindof UIView *)positioningView preferredEdge:(CGRectEdge)preferredEdge;
#else
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(__kindof NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;
#endif 
{
    _positioningView = positioningView;
    _preferredEdge = (CGRectEdge)preferredEdge;
    
    self.positioningRect = positioningRect;
    
    if (!_flags.shown) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SSPopoverWillShowNotification object:self];
#if TARGET_OS_IPHONE
        _popoverView.alpha = 1.0;
        [_contentViewController viewWillAppear:_flags.animates];
        [_positioningView addSubview:_popoverView];
#else
        _positioningWindow.alphaValue = 1.0;
        
        [_contentViewController viewWillAppear];
        
        [_positioningWindow makeFirstResponder:_positioningWindow];
        [_positioningView.window addChildWindow:_positioningWindow ordered:NSWindowAbove];
        [_positioningWindow makeKeyAndOrderFront:nil];
#endif
        _flags.shown = 1;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SSPopoverDidShowNotification object:self];
    }
}

- (void)close {
    if (_flags.closing || !_flags.shown || ([_delegate respondsToSelector:@selector(popoverShouldClose:)] && ![_delegate popoverShouldClose:self]))
        return;
    
    _flags.closing = 1;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SSPopoverWillCloseNotification object:self];
    
    if (!_flags.animates) {
        [self performClose:self];
    } else {
#if TARGET_OS_IPHONE
        [UIView animateWithDuration:0.25 animations:^{
            _popoverView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self performClose:self];
        }];
#else
        [NSAnimationContext currentContext].duration = 0.5;
        (_positioningWindow.animator).alphaValue = 0;
        [self performLatestRequestOfSelector:@selector(performClose:) withObject:self afterDelay:[NSAnimationContext currentContext].duration inModes:@[NSRunLoopCommonModes]];
#endif
    }
}

#pragma mark NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification {
    
}

- (void)windowDidResignKey:(NSNotification *)notification {
#if TARGET_OS_IPHONE
    
#else
    if (_behavior == SSPopoverBehaviorApplicationDefined || (_behavior == SSPopoverBehaviorSemitransient && !NSApplication.sharedApplication.isActive) || ![NSApp.keyWindow isEqual:_positioningView.window])
        return;
#endif
    
    [self close];
}

#pragma mark getters & setters

- (id <SSPopoverDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSPopoverDelegate>)delegate {
    if (_delegate == delegate)
        return;
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(popoverWillShow:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:_delegate name:SSPopoverWillShowNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverDidShow:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:_delegate name:SSPopoverDidShowNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverWillClose:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:_delegate name:SSPopoverWillCloseNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverDidClose:)]) {
            [[NSNotificationCenter defaultCenter] removeObserver:_delegate name:SSPopoverDidCloseNotification object:self];
        }
        
        _delegate = nil;
    }
    
    if (delegate) {
        _delegate = delegate;
        
        if ([_delegate respondsToSelector:@selector(popoverWillShow:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(popoverWillShow:) name:SSPopoverWillShowNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverDidShow:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(popoverDidShow:) name:SSPopoverDidShowNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverWillClose:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(popoverWillClose:) name:SSPopoverWillCloseNotification object:self];
        }
        
        if ([_delegate respondsToSelector:@selector(popoverDidClose:)]) {
            [[NSNotificationCenter defaultCenter] addObserver:_delegate selector:@selector(popoverDidClose:) name:SSPopoverDidCloseNotification object:self];
        }
    }
}

- (id)contentViewController {
    return _contentViewController;
}

- (void)setContentViewController:(id)contentViewController {
    if (_contentViewController == contentViewController) {
        return;
    }
    
    SSNonAtomicRetainedSet(_contentViewController, contentViewController);
    
    [self layout];
}

- (SSPopoverAppearance)appearance {
    return _appearance;
}

- (void)setAppearance:(SSPopoverAppearance)appearance {
    if (_appearance == appearance) {
         return;
    }
    
    _appearance = appearance;
    
    switch (appearance) {
        case SSPopoverAppearanceMinimal:
            _popoverView.fillColor = SSAutorelease(SSColorCreateDeviceGray(0.909804, 0.909804));
            _popoverView.borderColor = SSAutorelease(SSColorCreateDeviceGray(0.909804, 0.33));
            break;
        case SSPopoverAppearanceHUD:
            _popoverView.fillColor = SSAutorelease(SSColorCreateDeviceGray(0.0, 0.33));
            _popoverView.borderColor = SSAutorelease(SSColorCreateDeviceGray(1.0, 0.33));
            break;
    }
    
    _popoverView.borderWidth = 1.0;
    
    [self layout];
}

- (SSPopoverBehavior)behavior {
    return _behavior;
}

- (void)setBehavior:(SSPopoverBehavior)behavior {
    _behavior = behavior;
}

- (CGSize)contentSize {
    return _contentSize;
}

- (void)setContentSize:(CGSize)contentSize {
    if (CGSizeEqualToSize(_contentSize, contentSize)) {
        return;
    }
    
    _contentSize = contentSize;
    
    [self layout];
}

- (CGRect)positioningRect {
    return _positioningRect;
}

- (void)setPositioningRect:(CGRect)positioningRect {
#if 0
    if (CGRectEqualToRect(_positioningRect, positioningRect))
        return;
#endif
    
    _positioningRect = positioningRect;
    
    positioningRect.origin = [_positioningView convertPoint:positioningRect.origin toView:nil];
#if TARGET_OS_IPHONE
#else
    if (_positioningView.isFlipped) {
        positioningRect.origin.y -= CGRectGetHeight(positioningRect);
    }
#if defined(__MAC_10_7)
    if ([_positioningView.window respondsToSelector:@selector(convertRectToScreen:)]) {
         positioningRect = [_positioningView.window convertRectToScreen:positioningRect];
    }
#else
    positioningRect.origin = [_positioningView.window convertBaseToScreen:positioningRect.origin];
#endif
#endif
    
    SSRectPosition (^proposedArrowPositionForRectEdgeInRects)(CGRectEdge edge, CGRect baseRect, CGRect rect) = ^SSRectPosition(CGRectEdge edge, CGRect baseRect, CGRect rect) {
        static const NSInteger numberOfRects = 9;
        static const NSInteger columns = 3;
        static const NSInteger rows = 3;
        CGSize size = CGSizeMake(CGRectGetWidth(baseRect)/(CGFloat)columns, CGRectGetHeight(baseRect)/(CGFloat)rows);
        CGRect (^positioningRectAtIndex)(NSInteger index) = ^CGRect(NSInteger index) {
            NSInteger column = index % columns;
            NSInteger row = (index - column) / columns;
            return CGRectMake(column * size.width, row * size.height, size.width, size.height);
        };
        
        __block NSUInteger positioningRectIndex = NSNotFound;
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfRects)];
        [indexes enumerateIndexesWithOptions:NSEnumerationConcurrent usingBlock:^(NSUInteger idx, BOOL *stop) {
            if (CGRectIntersectsRect(rect, positioningRectAtIndex(idx))) {
                positioningRectIndex = idx;
                *stop = YES;
            }
        }];
        
        SSRectPosition position = (SSRectPosition)edge;
        switch (positioningRectIndex) {
            case 0:
                position = SSRectPositionBottomLeft;
                //position = SSRectPositionLeftBottom;
                break;
            case 1:
                position = SSRectPositionBottom;
                break;
            case 2:
                position = SSRectPositionBottomRight;
                //position = SSRectPositionRightBottom;
                break;
            case 3:
                position = SSRectPositionLeft;
                break;
            case 4:
                position = (SSRectPosition)edge;
                break;
            case 5:
                position = SSRectPositionRight;
                break;
            case 6:
                position = SSRectPositionTopLeft;
                //position = SSRectPositionLeftTop;
                break;
            case 7:
                position = SSRectPositionTop;
                break;
            case 8:
                position = SSRectPositionTopRight;
                //position = SSRectPositionRightTop;
                break;
            default:
                position = (SSRectPosition)edge;
                break;
        }
        
        return position;
    };
    
    CGRect popoverBounds = _popoverView.frame;
    SSWindow *parentWindow = (SSWindow *)_positioningView.window;
    CGRect parentFrame = parentWindow.frame;
#if TARGET_OS_IPHONE
    CGRect screenBounds = parentWindow.screen.bounds;
#else
    CGRect screenBounds = parentWindow.screen.frame;
#endif
    CGPoint location = SSRectGetCenterPoint(positioningRect);
    CGSize arrowSize = _popoverView.arrowSize;
    CGFloat viewWidth = CGRectGetWidth(popoverBounds) - arrowSize.height*(CGFloat)2.0;
    CGFloat viewHeight = CGRectGetHeight(popoverBounds) - arrowSize.height*(CGFloat)2.0;
    CGFloat halfWidth = viewWidth*(CGFloat)0.5;
    CGFloat halfHeight = viewHeight*(CGFloat)0.5;
    
    SSRectPosition arrowPosition = proposedArrowPositionForRectEdgeInRects(SSRectGetInverseEdge(_preferredEdge), parentFrame, positioningRect);
    switch (arrowPosition) {
        case SSRectPositionBottom:
        case SSRectPositionTop:
            if (location.x - halfWidth < CGRectGetMinX(parentFrame)) {
                if (location.x + viewWidth < CGRectGetMaxX(screenBounds)) {
                    if (arrowPosition == SSRectPositionTop) {
                        arrowPosition = SSRectPositionTopLeft;
                    } else {
                        arrowPosition = SSRectPositionBottomLeft;
                    }
                }
            } else if (location.x + halfWidth >= CGRectGetMaxX(parentFrame)) {
                if (location.x - viewWidth >= CGRectGetMinX(screenBounds)) {
                    if (arrowPosition == SSRectPositionBottom) {
                        arrowPosition = SSRectPositionBottomRight;
                    } else {
                        arrowPosition = SSRectPositionTopRight;
                    }
                }
            }
            break;
        case SSRectPositionRight:
        case SSRectPositionLeft:
            if (location.y - halfHeight < CGRectGetMinY(parentFrame)) {
                if (location.y + viewHeight < CGRectGetMaxY(screenBounds)) {
                    if (arrowPosition == SSRectPositionLeft) {
                        arrowPosition = SSRectPositionLeftBottom;
                    } else {
                        arrowPosition = SSRectPositionRightBottom;
                    }
                }
            } else if (location.y + halfHeight >= CGRectGetMaxY(parentFrame)) {
                if (location.y - viewHeight >= CGRectGetMinY(screenBounds)) {
                    if (arrowPosition == SSRectPositionRight) {
                        arrowPosition = SSRectPositionRightTop;
                    } else {
                        arrowPosition = SSRectPositionLeftTop;
                    }
                }
            }
            break;
        default:
            break;
    }
    
    SSRectPosition rectPosition = SSRectGetInversePosition(arrowPosition, true);
    CGPoint origin = SSRectGetPointAtPosition(positioningRect, rectPosition, CGSizeZero);
    switch (arrowPosition) {
        case SSRectPositionLeft:
            origin.y -= halfHeight + arrowSize.width*(CGFloat)0.5;
            break;
        case SSRectPositionLeftTop:
            origin.y -= viewHeight + arrowSize.width;
            break;
        case SSRectPositionLeftBottom:
            break;
        case SSRectPositionRight:
            origin.x -= viewWidth + arrowSize.height;
            origin.y -= halfHeight + arrowSize.width*(CGFloat)0.5;
            break;
        case SSRectPositionRightTop:
            origin.x -= viewWidth + arrowSize.height;
            origin.y -= viewHeight + arrowSize.height;
            break;
        case SSRectPositionRightBottom:
            origin.x -= viewWidth + arrowSize.height;
            break;
        case SSRectPositionTop:
            origin.x -= halfWidth + arrowSize.width*(CGFloat)0.5;
            origin.y -= viewHeight + arrowSize.height*(CGFloat)0.5;
            break;
        case SSRectPositionTopRight:
            origin.x -= viewWidth + arrowSize.width;
            origin.y -= viewHeight + arrowSize.height*(CGFloat)0.5;
            break;
        case SSRectPositionTopLeft:
            origin.y -= viewHeight + arrowSize.height*(CGFloat)0.5;
            break;
        case SSRectPositionBottom:
            origin.x -= halfWidth + arrowSize.width*(CGFloat)0.5;
            origin.y -= arrowSize.height;
            break;
        case SSRectPositionBottomRight:
            origin.x -= viewWidth + arrowSize.width;
            origin.y -= arrowSize.height;
            break;
        case SSRectPositionBottomLeft:
            origin.y -= arrowSize.height;
            break;
        case SSRectPositionCenter:
            break;
    }
    
    _popoverView.arrowPosition = arrowPosition;
    
    CGRect frame = CGRectMake(FLOOR(origin.x), FLOOR(origin.y), CGRectGetWidth(popoverBounds), CGRectGetHeight(popoverBounds));
    CGRect imageBounds = frame;
    imageBounds.origin.y += CGRectGetHeight(imageBounds);
    imageBounds.origin = CGPointApplyAffineTransform(imageBounds.origin, CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, CGRectGetHeight(screenBounds)));
    
    CGColorRef (^backgroundColor)(CGImageRef screenshot) = ^CGColorRef(CGImageRef screenshot) {
        return SSAutorelease(SSColorCreateWithPatternImage(SSImageCreate(SSSizeScale(imageBounds.size, _popoverView.scale), ^(CGContextRef  _Nullable ctx) {
            CGFloat cornerRadius = _popoverView.cornerRadius;
            CGSize arrowSize = _popoverView.arrowSize;
            CGRect boundingBox = CGContextGetClipBoundingBox(ctx);
            CGRect bounds = CGRectInset(boundingBox, arrowSize.height, arrowSize.height);
            CGPathRef path = SSPathCreateWithArrow(bounds, SSRectAllCorners, cornerRadius, arrowSize, arrowPosition);
            CGColorRef fillColor = CGColorCreateCopy(_popoverView.fillColor);
            CGImageRef image = SSImageCreateWithBoxBlur(screenshot, 1.0);
            
            CGContextAddPath(ctx, path);
            CGContextClip(ctx);
            CGContextSetFillColorWithColor(ctx, fillColor);
            CGContextFillRect(ctx, boundingBox);
            CGContextSetAlpha(ctx, 0.16);
            CGContextDrawImage(ctx, boundingBox, image);
            
            CGImageRelease(image);
            CGColorRelease(fillColor);
            CGPathRelease(path);
        }), _popoverView.scale));
    };
    
#if TARGET_OS_IPHONE
    _popoverView.fillColor = backgroundColor(CGImageCreateWithImageInRect(SSAutorelease(SSImageCreate(screenBounds.size, ^(CGContextRef  _Nullable ctx) {
        [_positioningView.layer renderInContext:ctx];
    })), imageBounds));
    
    if (!CGRectEqualToRect(frame, _popoverView.frame)) {
        _popoverView.frame = frame;
        if (![_positioningView.subviews containsObject:_popoverView]) {
            [_positioningView addSubview:_popoverView];
        }
    }
#else
    _popoverView.fillColor = backgroundColor(SSAutorelease(CGWindowListCreateImage(imageBounds, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault)));
    
    if (!CGRectEqualToRect(frame, _positioningWindow.frame)) {
        [_positioningWindow setFrame:frame display:YES animate:_positioningWindow.isVisible];
    }
    
    if (![parentWindow.childWindows containsObject:_positioningWindow]) {
        [parentWindow addChildWindow:_positioningWindow ordered:NSWindowAbove];
        [_positioningWindow orderFront:nil];
    }
#endif
}

- (BOOL)animates {
    return _flags.animates;
}

- (void)setAnimates:(BOOL)animates {
    _flags.animates = animates;
}

- (BOOL)isShown {
    return _flags.shown;
}

@end
