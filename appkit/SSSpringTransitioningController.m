//
//  SSSpringTransitioningController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/16.
//
//

#import "SSSpringTransitioningController.h"

@implementation SSSpringTransitioningController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 1.0;
        self.damping = 0.4;
        self.velocity = 0.0;
    }
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = self.isPresenting ? toView : [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    if ([self.delegate respondsToSelector:@selector(transitioningController:willAnimateTransitioningFromView:toView:)]) {
        [self.delegate transitioningController:self willAnimateTransitioningFromView:fromView toView:toView];
    }
    
    CGRect initialFrame = self.isPresenting ? self.sourceRect : fromView.frame;
    CGRect finalFrame = self.isPresenting ? fromView.frame : self.sourceRect;
    CGFloat xScaleFactor = self.isPresenting ? CGRectGetWidth(initialFrame) / CGRectGetWidth(finalFrame) : CGRectGetWidth(finalFrame) / CGRectGetWidth(initialFrame);
    CGFloat yScaleFactor = self.isPresenting ? CGRectGetHeight(initialFrame) / CGRectGetHeight(finalFrame) : CGRectGetHeight(finalFrame) / CGRectGetHeight(initialFrame);
    CGAffineTransform transform = CGAffineTransformMakeScale(xScaleFactor, yScaleFactor);
    
    if (self.isPresenting) {
        fromView.transform = transform;
        fromView.center = SSRectGetCenterPoint(initialFrame);
        fromView.clipsToBounds = YES;
    }
    
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:fromView];
    
    [UIView animateWithDuration:self.duration delay:0.0 usingSpringWithDamping:self.damping initialSpringVelocity:self.velocity options:0 animations:^{
        fromView.transform = self.isPresenting ? CGAffineTransformIdentity : transform;
        fromView.center = SSRectGetCenterPoint(finalFrame);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
