//
//  SSFragmentsTransitioningController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/12/16.
//
//

#import "SSFragmentsTransitioningController.h"
#import <graphics/SSImage.h>
#import <foundation/NSValue+SSAdditions.h>
#import <quartz/CALayer+SSAdditions.h>

@implementation SSFragmentsTransitioningController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 3.0;
    }
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    if ([self.delegate respondsToSelector:@selector(transitioningController:willAnimateTransitioningFromView:toView:)]) {
        [self.delegate transitioningController:self willAnimateTransitioningFromView:fromView toView:toView];
    }
    
    BOOL isPresenting = self.isInverted ? !self.isPresenting : self.isPresenting;
    CGRect initialFrame = isPresenting ? fromView.frame : self.sourceRect;
    CGRect finalFrame = isPresenting ? self.sourceRect : fromView.frame;
    UIView *imageView = isPresenting ? fromView : toView;
    CGImageRef image = SSAutorelease(SSImageCreateFlipped(SSAutorelease(SSImageCreate(imageView.bounds.size, ^(CGContextRef  _Nullable ctx) {
        [imageView.layer renderInContext:ctx];
    })), true));
    
    CGFloat scale = toView.scale;
    CGRect imageBounds = toView.frame;
    NSTimeInterval duration = self.duration;
    
    CGFloat fragment = 5.0*scale;
    CGSize fragmentSize = SSSizeMakeSquare(fragment);
    NSInteger numberOfColumns = (NSInteger)CEIL(CGRectGetWidth(imageBounds)/fragmentSize.width);
    NSInteger numberOfRows = (NSInteger)CEIL(CGRectGetHeight(imageBounds)/fragmentSize.height);
    CGRect (^positioningRectAtIndex)(CGRect rect, NSInteger index) = ^CGRect(CGRect rect, NSInteger index) {
        NSInteger column = index % numberOfColumns;
        NSInteger row = (index - column) / numberOfColumns;
        return CGRectMake(FLOOR(CGRectGetMinX(rect) + (column * fragmentSize.width)), FLOOR(CGRectGetMinY(rect) + (row * fragmentSize.height)), fragmentSize.width, fragmentSize.height);
    };
    
    CALayer *animationLayer = [CALayer layer];
    animationLayer.bounds = imageBounds;
    animationLayer.position = imageBounds.origin;
    animationLayer.anchorPoint = CGPointZero;
#if 0
    animationLayer.shadowOffset = CGSizeZero;
    animationLayer.shadowOpacity = 1.0;
    animationLayer.shadowRadius = (CGFloat)MIN(MAX(FLOOR(fragmentSize.width*(CGFloat)0.03), 3.0), 6.0);
    animationLayer.shouldRasterize = YES;
    animationLayer.rasterizationScale = scale;
    animationLayer.zPosition = 100;
#endif
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [animationLayer removeFromSuperlayer];
        [transitionContext completeTransition:YES];
    }];
    
    NSInteger fragments = numberOfColumns*numberOfRows;
    NSInteger index = 0;
    while (index < fragments) {
        @autoreleasepool {
            CGRect fragmentBounds = positioningRectAtIndex(imageBounds, index);
            CALayer *fragmentLayer = [CALayer layer];
            fragmentLayer.bounds = fragmentBounds;
            fragmentLayer.position = fragmentBounds.origin;
            fragmentLayer.anchorPoint = CGPointZero;
            fragmentLayer.contents = (__bridge id)SSAutorelease(CGImageCreateWithImageInRect(image, SSRectScale(positioningRectAtIndex(CGRectZero, index), scale)));
            
            [animationLayer addSublayer:fragmentLayer];
            
            CGPoint randomPoint = CGPointMake((CGFloat)arc4random_uniform((u_int32_t)SQRT(POW(CGRectGetMinX(initialFrame) + CGRectGetMaxX(initialFrame), 2.0))), (CGFloat)arc4random_uniform((u_int32_t)SQRT(POW(CGRectGetMinY(initialFrame) + CGRectGetMaxY(initialFrame), 2.0))));
            CGMutablePathRef path = SSAutorelease(CGPathCreateMutable());
            if (isPresenting) {
                CGPathMoveToPoint(path, NULL, CGRectGetMinX(fragmentBounds), CGRectGetMinY(fragmentBounds));
                CGPathAddQuadCurveToPoint(path, NULL, CGRectGetMinX(fragmentBounds), (CGFloat)arc4random_uniform((u_int32_t)SQRT(POW(CGRectGetMinY(initialFrame) + CGRectGetMaxY(initialFrame), 2.0))), CGRectGetMidX(finalFrame), CGRectGetMidY(finalFrame));
            } else {
                CGPathMoveToPoint(path, NULL, randomPoint.x, randomPoint.y);
                CGPathAddQuadCurveToPoint(path, NULL, randomPoint.x, (CGFloat)arc4random_uniform((u_int32_t)SQRT(POW(CGRectGetMinY(finalFrame) + CGRectGetMaxY(finalFrame), 2.0))), CGRectGetMinX(fragmentBounds), CGRectGetMinY(fragmentBounds));
            }
            
            CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
            boundsAnimation.fromValue = isPresenting ? [NSValue valueWithRect:fragmentBounds] : [NSValue valueWithRect:SSRectMakeSquare(1.0*scale)];
            boundsAnimation.toValue = isPresenting ? [NSValue valueWithRect:SSRectMakeSquare(1.0*scale)] : [NSValue valueWithRect:fragmentBounds];
            
            CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            positionAnimation.path = path;
            positionAnimation.calculationMode = kCAAnimationPaced;
            
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.fromValue = isPresenting ? [NSValue valueWithCATransform3D:CATransform3DIdentity] : [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(RADIANS((CGFloat)((int)arc4random()%20) - 10)))];
            transformAnimation.toValue = isPresenting ? [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(RADIANS((CGFloat)((int)arc4random()%20) - 10)))] : [NSValue valueWithCATransform3D:CATransform3DIdentity];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = isPresenting ? @1.0 : @0.0;
            opacityAnimation.toValue = isPresenting ? @0.0 : @1.0;
            
            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animationGroup.fillMode = kCAFillModeForwards;
            animationGroup.removedOnCompletion = NO;
            animationGroup.animations = @[boundsAnimation, positionAnimation, transformAnimation, opacityAnimation];
            animationGroup.duration = duration;
            
            [fragmentLayer addAnimation:animationGroup forKey:nil];
        }
        
        index++;
    }
    
    UIView *animationView = isPresenting ? toView : fromView;
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:animationView];
    [animationView.layer addSublayer:animationLayer];
    
    [CATransaction commit];
}

@end
