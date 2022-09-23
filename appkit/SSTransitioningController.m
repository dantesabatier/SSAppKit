//
//  SSTransitioningController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/16.
//
//

#import "SSTransitioningController.h"

@interface SSTransitioningController ()

@property (nonatomic, readwrite, getter=isPresenting, assign) BOOL presenting;

@end

@implementation SSTransitioningController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0.25;
    }
    return self;
}

#pragma mark UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presenting = YES;
    return self;
}

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presenting = NO;
    return self;
}

@end
