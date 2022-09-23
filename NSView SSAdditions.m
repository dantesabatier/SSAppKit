//
//  NSView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/17/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSView+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSScrollView+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSArray+SSAdditions.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/SSMainThreadProxy.h>
#import <QuartzCore/QuartzCore.h>

@implementation NSView (SSAdditions)

#if defined(__MAC_10_6)

- (id)copyWithZone:(NSZone *)zone {
    __ss_weak void (^__block process)(NSView *target, NSView *base) = ^(NSView *target, NSView *base) {
        NSArray *bindings = base.exposedBindings;
        for (NSString *binding in bindings) {
            NSDictionary *info = [base infoForBinding:binding];
            if (info[NSObservedObjectKey] && info[NSObservedKeyPathKey])
                [target bind:binding toObject:info[NSObservedObjectKey] withKeyPath:info[NSObservedKeyPathKey] options:info[NSOptionsKey]];
        }
        
        [target.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) {
            process(subview, (base.subviews)[idx]);
        }];
    };
    
    NSView *view = [[NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]] ss_retain];
    [view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) {
        process(subview, (self.subviews)[idx]);
    }];
    
    return view;
}

#endif

- (NSViewController *)viewController {
    __kindof NSViewController *viewController = nil;
    __kindof NSResponder *responder = self;
    while (responder != nil) {
        responder = responder.nextResponder;
        if ([responder isKindOfClass:[NSViewController class]] && ([self isDescendantOf:((NSViewController *)responder).view] || [self isEqual:((NSViewController *)responder).view])) {
            viewController = (NSViewController *)responder;
            break;
        }
    }
    return viewController;
}
/*
- (void)setViewController:(NSViewController *)viewController {
    NSViewController *associatedViewController = [self associatedValueForKey:@"associatedViewControllerValue"];
    if (associatedViewController) {
        self.nextResponder = associatedViewController.nextResponder;
        associatedViewController.nextResponder = nil;
    }
    
    [self setWeakAssociatedValue:nil forKey:@"associatedViewControllerValue"];
    
    if (viewController) {
        NSResponder *nextResponder = self.nextResponder;
        self.nextResponder = viewController;
        if (nextResponder != viewController) {
            viewController.nextResponder = nextResponder;
        }
    }
    
    [self setWeakAssociatedValue:viewController forKey:@"associatedViewControllerValue"];
}

- (void)setNextResponder:(NSResponder *)nextResponder {
    NSViewController *associatedViewController = [self associatedValueForKey:@"associatedViewControllerValue"];
    if (associatedViewController && (nextResponder != associatedViewController)) {
        associatedViewController.nextResponder = nextResponder;
    } else {
        ((void(*)(id, SEL, NSResponder *))SSObjectPerformSupersequentMethodImplementation(self, _cmd, SSObjectGetMethodImplementationOfSelector(self, _cmd))) (self, _cmd, nextResponder);
    }
}
*/
- (NSView *)presentingView {
    return [self.subviews firstObjectPassingTest:^BOOL(__kindof NSView * _Nonnull obj) {
        return !obj.isHidden;
    }];
}

- (void)setPresentingView:(NSView *)presentingView {
    if (self.presentingView == presentingView) {
        return;
    }
    
    if (presentingView) {
        presentingView.frame = self.bounds;
        
        if (![self.subviews containsObject:presentingView]) {
            [self addSubview:presentingView];
        }
    }
    
    for (NSView *subview in self.subviews) {
        subview.hidden = (subview != presentingView);
    }
}

- (void)setPresentingView:(NSView *)presentingView animated:(BOOL)animated {
#if NS_BLOCKS_AVAILABLE
    [self setPresentingView:presentingView options:animated ? SSViewTransitionCrossfade : SSViewTransitionNone completion:nil];
#endif
}

#if NS_BLOCKS_AVAILABLE

- (void)setPresentingView:(NSView *)presentingView options:(SSViewTransitionOptions)options completion:(void (^)(void))completion {
    [self transitionFromView:self.presentingView toView:presentingView options:options completion:completion];
}

- (void)transitionFromView:(NSView *)fromView toView:(NSView *)toView options:(SSViewTransitionOptions)options completion:(void (^)(void))completion {
    if (!toView || (toView == self.presentingView)) {
        if (completion) {
            completion();
        }
        return;
    }
    
    if (!self.window.isVisible || (options == SSViewTransitionNone)) {
        self.presentingView = toView;
        if (completion) {
            completion();
        }
        return;
    }
    
    NSNumber *number = [self associatedValueForKey:@"transitioningFromViewValue"];
    if (number.boolValue) {
        return;
    }
    
    [self setNonAtomicRetainedAssociatedValue:@YES forKey:@"transitioningFromViewValue"];
    
    CGRect bounds = self.bounds;
    
    toView.frame = bounds;
    toView.hidden = NO;
    
    if (![self.subviews containsObject:toView]) {
        [self addSubview:toView];
    }
    
    fromView.frame = bounds;
    fromView.hidden = NO;
    
    if (![self.subviews containsObject:fromView]) {
        [self addSubview:fromView];
    }
    
    static const int zDistance = 850;
    NSTimeInterval duration = [NSAnimationContext currentContext].duration;
#if DEBUG
    NSUInteger modifierFlags = self.window.currentEvent.modifierFlags;
    if (modifierFlags & NSShiftKeyMask) {
        duration *= 2.0;
    }
        
    if ((modifierFlags & NSShiftKeyMask) && (modifierFlags & NSControlKeyMask)) {
        duration *= 4;
    }  
#endif
    static const uint32_t noEdge = -1;
    uint32_t destinationEdge = noEdge;
    if (options & SSViewTransitionSlideUp) {
        destinationEdge = CGRectMaxYEdge;
    } else if (options & SSViewTransitionSlideDown) {
        destinationEdge = CGRectMinYEdge;
    } else if (options & SSViewTransitionSlideLeft) {
        destinationEdge = CGRectMinXEdge;
    } else if (options & SSViewTransitionSlideRight) {
        destinationEdge = CGRectMaxXEdge;
    }
    
    NSView *temporaryView = [[[NSView alloc] initWithFrame:bounds] autorelease];
    temporaryView.autoresizingMask = SSViewAutoresizingAll;
    temporaryView.layer = [CALayer layer];
    temporaryView.wantsLayer = YES;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.presentingView = toView;
        [temporaryView removeFromSuperview];
        
        if (completion) {
            completion();
        }
        
        [self setNonAtomicRetainedAssociatedValue:nil forKey:@"transitioningFromViewValue"];
    }];
    
    NSBitmapImageRep *fromRep = [fromView bitmapImageRepForCachingDisplayInRect:fromView.bounds];
    [fromView cacheDisplayInRect:fromView.bounds toBitmapImageRep:fromRep];
    
    CALayer *fromLayer = [CALayer layer];
    fromLayer.zPosition = 100;
    fromLayer.doubleSided = NO;
    fromLayer.contents = (__bridge id)fromRep.CGImage;
    fromLayer.anchorPoint = CGPointZero;
    fromLayer.bounds = bounds;
    fromLayer.position = bounds.origin;
    
    NSMutableArray *fromAnimations = [NSMutableArray array];
    if (options & SSViewTransitionCrossfade) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @1.0;
        opacityAnimation.toValue = @0.0;
        
        [fromAnimations addObject:opacityAnimation];
    }
    
    if (options & SSViewTransitionFlip) {
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -zDistance;
        transform = CATransform3DRotate(transform, M_PI, 0.0, 1.0, 0.0);
        
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        
        [fromAnimations addObject:transformAnimation];
    }
    
    if (destinationEdge != noEdge) {
        CGRect fromRect = SSRectGetDestinationRectForEdge(bounds, SSRectGetInverseEdge(destinationEdge));
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithPoint:bounds.origin];
        positionAnimation.toValue = [NSValue valueWithPoint:fromRect.origin];
        
        [fromAnimations addObject:positionAnimation];
    }
    
    CAAnimationGroup *fromAnimationGroup = [CAAnimationGroup animation];
    fromAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    fromAnimationGroup.animations = fromAnimations;
    fromAnimationGroup.duration = duration;
    fromAnimationGroup.fillMode = kCAFillModeForwards;
    fromAnimationGroup.removedOnCompletion = NO;
    
    [fromLayer addAnimation:fromAnimationGroup forKey:nil];
    
    [temporaryView.layer addSublayer:fromLayer];
    
    NSBitmapImageRep *toRep = [toView bitmapImageRepForCachingDisplayInRect:toView.bounds];
    [toView cacheDisplayInRect:toView.bounds toBitmapImageRep:toRep];
    
    CALayer *toLayer = [CALayer layer];
    toLayer.zPosition = 100;
    toLayer.doubleSided = NO;
    toLayer.contents = (__bridge id)toRep.CGImage;
    toLayer.anchorPoint = CGPointZero;
    toLayer.bounds = bounds;
    toLayer.position = bounds.origin;
    
    NSMutableArray *toAnimations = [NSMutableArray array];
    if (options & SSViewTransitionCrossfade) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @0.0f;
        opacityAnimation.toValue = @1.0f;
        
        [toAnimations addObject:opacityAnimation];
        
        toLayer.opacity = [opacityAnimation.fromValue floatValue];
    }
    
    if (options & SSViewTransitionFlip) {
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -zDistance;
        transform = CATransform3DRotate(transform, 2*M_PI, 0.0, 1.0, 0.0);
        
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0)];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        
        [toAnimations addObject:transformAnimation];
        
        toLayer.transform = [transformAnimation.fromValue CATransform3DValue];
    }
    
    if (destinationEdge != noEdge) {
        CGRect toRect = SSRectGetDestinationRectForEdge(bounds, destinationEdge);
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithPoint:toRect.origin];
        positionAnimation.toValue = [NSValue valueWithPoint:bounds.origin];
        
        [toAnimations addObject:positionAnimation];
        
        toLayer.bounds = toRect;
        toLayer.position = toRect.origin;
    }
    
    CAAnimationGroup *toAnimationGroup = [CAAnimationGroup animation];
    toAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    toAnimationGroup.animations = toAnimations;
    toAnimationGroup.duration = duration;
    toAnimationGroup.fillMode = kCAFillModeForwards;
    toAnimationGroup.removedOnCompletion = NO;
    
    [toLayer addAnimation:toAnimationGroup forKey:nil];
    
    [temporaryView.layer addSublayer:toLayer];
    
    self.presentingView = temporaryView;
    
    [CATransaction commit];
}

#endif

- (NSImage *)imageRepresentation {
    NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
	unsigned char *bitmapData = imageRep.bitmapData;
    if (bitmapData) {
        bzero(bitmapData, imageRep.bytesPerRow * imageRep.pixelsHigh);
    }
    
	[self cacheDisplayInRect:self.bounds toBitmapImageRep:imageRep];
	
	NSImage *image = [[NSImage alloc] init];
	[image addRepresentation:imageRep];
	return [image autorelease];
}

- (NSGradient *)tableHeaderViewBackgroundGradient {
    return [NSGradient tableHeaderViewBackgroundGradientAsKey:!self.needsDisplayWhenWindowResignsKey ? YES : self.window.isActive];
}

- (CGRect)clippingVisibleRect {
    return (self.enclosingScrollView && self.enclosingScrollView.bounces) ? self.superview.visibleRect : self.visibleRect;
}

- (BOOL)needsDisplayWhenWindowResignsKey {
    return (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) ? YES : NO;
}

- (BOOL)centerRectInVisibleArea:(CGRect)rect {
    BOOL didScroll = NO;
    CGRect visibleRect = self.visibleRect;
    if (!CGRectContainsRect(visibleRect, rect)) {
        CGFloat heightDifference = CGRectGetHeight(visibleRect) - CGRectGetHeight(rect);
        if (heightDifference > 0) {
            rect = CGRectInset(rect, 0.0, -(heightDifference/(CGFloat)2.0));
        } else {
            rect.size.height = CGRectGetHeight(visibleRect);
        }
        
        didScroll = [self scrollRectToVisible:rect];
    }
    return didScroll;
}

- (void)setNeedsDisplay {
    self.needsDisplay = YES;
}

- (CGSize)frameSize {
    return self.frame.size;
}

- (CGFloat)scale {
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        __kindof NSView *proxy = (NSView *)self.mainThreadProxy;
        return CGRectGetWidth([proxy convertRectToBacking:proxy.bounds])/CGRectGetWidth(proxy.bounds);
    } 
#endif
    return 1.0;
}

- (CGPoint)center {
    return SSRectGetCenterPoint(self.frame);
}

- (void)setCenter:(CGPoint)center {
    self.frame = SSRectCenteredAroundPoint(self.frame, center);
}

- (BOOL)effectiveAppearanceIsDark {
    BOOL effectiveAppearanceIsDark = NO;
#if defined(__MAC_10_10)
#if (defined(__MAC_10_14))
    if (@available(macOS 10.14, *)) {
        effectiveAppearanceIsDark = (self.effectiveAppearance.name == NSAppearanceNameDarkAqua);
    } else {
        effectiveAppearanceIsDark = (self.effectiveAppearance.name == NSAppearanceNameVibrantDark);
    }
#endif
    effectiveAppearanceIsDark = (self.effectiveAppearance.name == NSAppearanceNameVibrantDark);
#endif
    return effectiveAppearanceIsDark;
}

- (void)addConstraintsWithFormat:(NSString *)format views:(NSArray <NSView *>*)views {
    NSMutableDictionary <NSString *, NSView *>*dictionary = [[NSMutableDictionary alloc] initWithCapacity:views.count];
    [views enumerateObjectsUsingBlock:^(NSView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        dictionary[[NSString stringWithFormat:@"v%@", @(idx).stringValue]] = view;
    }];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:dictionary]];
}

@end

