//
//  UIView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 13/03/13.
//
//

#import "UIResponder+SSAdditions.h"
#import <base/SSGeometry.h>

NS_ASSUME_NONNULL_BEGIN

#define SSViewAutoresizingAll (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin)
#define SSViewAutoresizingFlexibleSize (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)
#define SSViewAutoresizingFlexibleMargins (UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin)

@interface UIView (SSAdditions)

@property (nullable, nonatomic, readonly, ss_weak) __kindof UIViewController *viewController;
@property (nullable, nonatomic, readonly, copy) UIImage *imageRepresentation;
@property (nullable, nonatomic, ss_strong) __kindof UIView *presentingView;
#if defined(__IPHONE_6_0)
@property (nullable, nonatomic, ss_strong) NSShadow *shadow NS_AVAILABLE_IOS(6_0);
#endif
@property (nullable, nonatomic, readonly) __kindof UIScrollView *enclosingScrollView;
@property (nonatomic, readonly) CGRect visibleRect;
@property (nonatomic, readonly) CGRect clippingVisibleRect;
@property CGSize frameSize;
@property (nonatomic, readonly) CGFloat scale;
@property (nullable, nonatomic, readwrite, copy) NSArray<__kindof UIView *> *subviews;
- (BOOL)scrollRectToVisible:(CGRect)rect;
- (BOOL)centerRectInVisibleArea:(CGRect)rect;
- (CGFloat)distanceFromTouches:(NSArray <UITouch *> *)touches;
- (void)addConstraintsWithFormat:(NSString *)format views:(NSArray <__kindof UIView *>*)views;
- (IBAction)dismissController:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
