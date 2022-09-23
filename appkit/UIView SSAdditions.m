//
//  UIView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 13/03/13.
//
//

#import "UIView+SSAdditions.h"
#import <graphics/SSColor.h>
#import <foundation/NSObject+SSAdditions.h>
#import <foundation/NSArray+SSAdditions.h>
#import "UIViewController+SSAdditions.h"

@interface UIView ()

@end

@implementation UIView (SSAdditions)

- (nullable __kindof UIViewController *)viewController {
    __kindof UIViewController *viewController = nil;
    __kindof UIResponder *responder = self;
    while (responder != nil) {
        responder = responder.nextResponder;
        if ([responder isKindOfClass:[UIViewController class]] && ([self isDescendantOfView:((UIViewController *)responder).view] || [self isEqual:((UIViewController *)responder).view])) {
            viewController = (UIViewController *)responder;
            break;
        }
    }
    return viewController;
}

- (UIImage *)imageRepresentation {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, self.scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIView *)presentingView {
    return  [self.subviews firstObjectPassingTest:^BOOL(__kindof UIView * _Nonnull obj) {
        return !obj.isHidden;
    }];
}

- (void)setPresentingView:(UIView *)presentingView {
    if (self.presentingView == presentingView) {
        return;
    }
    
    if (presentingView) {
        presentingView.frame = self.bounds;
        
        if (![self.subviews containsObject:presentingView]) {
            [self addSubview:presentingView];
        }  
    }
    
    for (UIView *subview in self.subviews) {
        subview.hidden = subview != presentingView;
    }
}

#if defined(__IPHONE_6_0)

- (NSShadow *)shadow {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = self.layer.shadowRadius;
    shadow.shadowOffset = self.layer.shadowOffset;
    shadow.shadowColor = [UIColor colorWithCGColor:self.layer.shadowColor];
    
    return [shadow autorelease];
}

- (void)setShadow:(NSShadow *)shadow {
    self.layer.shadowColor = SSColorGetCGColor(shadow.shadowColor);
    self.layer.shadowOffset = shadow.shadowOffset;
    self.layer.shadowRadius = shadow.shadowBlurRadius;
    self.layer.shadowOpacity = shadow ? 1.0 : 0.0;
    self.layer.masksToBounds = shadow ? NO : YES;
}

#endif

- (UIScrollView *)enclosingScrollView {
    UIScrollView *scrollView = nil;
    UIView *superview = self.superview;
    while (superview) {
        if ([superview isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)superview;
            break;
        }
        superview = superview.superview;
    }
    return scrollView;
}

- (CGRect)visibleRect {
    return [self isKindOfClass:[UIScrollView class]] ? CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(1.0/((UIScrollView *)self).zoomScale, 1.0/((UIScrollView *)self).zoomScale)) : CGRectIntersection(self.bounds, self.superview.bounds);
}

- (CGRect)clippingVisibleRect {
    UIScrollView *enclosingScrollView = self.enclosingScrollView;
    return (enclosingScrollView && enclosingScrollView.bounces) ? enclosingScrollView.visibleRect : self.visibleRect;
}

- (CGSize)frameSize {
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)size {
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), size.width, size.height);
}

- (void)setSubviews:(NSArray<__kindof UIView *> *)subviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (__kindof UIView *view in subviews) {
        [self addSubview:view];
    }
}

- (BOOL)scrollRectToVisible:(CGRect)rect {
    UIScrollView *enclosingScrollView = nil;
    if ([self isKindOfClass:[UIScrollView class]]) {
        enclosingScrollView = (UIScrollView *)self;
    } else {
        enclosingScrollView = self.enclosingScrollView;
    }
    
    if (!enclosingScrollView) {
        return NO;
    }
    
    [enclosingScrollView scrollRectToVisible:rect animated:NO];
    
    return YES;
}

- (BOOL)centerRectInVisibleArea:(CGRect)rect {
    BOOL didScroll = NO;
    CGRect visibleRect = self.visibleRect;
    if (!CGRectContainsRect(visibleRect, rect)) {
        CGFloat difference = CGRectGetHeight(visibleRect) - CGRectGetHeight(rect);
        if (difference > 0) {
            rect = CGRectInset(rect, 0.0, -(difference*(CGFloat)0.5));
            if (CGRectGetMinY(rect) < CGRectGetMinY(self.bounds)) {
                rect.origin.y = CGRectGetMinY(self.bounds);
            } else if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.bounds)) {
                rect.origin.y = CGRectGetMaxY(self.bounds);
            }
        } else {
            rect.size.height = CGRectGetHeight(visibleRect);
        }
        
        didScroll = [self scrollRectToVisible:rect];
    }
    return didScroll;
}

- (CGFloat)scale {
    return [[UIScreen mainScreen] scale];
}

- (CGFloat)distanceFromTouches:(NSArray <UITouch *> *)touches {
    return (touches.count > 1) ? SSPointGetDistanceToPoint([touches[0] locationInView:self], [touches[1] locationInView:self]) : 0.0;
}

- (void)addConstraintsWithFormat:(NSString *)format views:(NSArray <__kindof UIView *>*)views {
    NSMutableDictionary <NSString *, __kindof UIView *>*dictionary = [[NSMutableDictionary alloc] initWithCapacity:views.count];
    [views enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        dictionary[[NSString stringWithFormat:@"v%@", @(idx).stringValue]] = view;
    }];
    //self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:dictionary]];
}

- (IBAction)dismissController:(nullable id)sender {
    [self.viewController dismiss:sender];
}

@end
