//
//  SSTransitioningController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/16.
//
//

#import "UIView+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSTransitioningControllerDelegate;

@interface SSTransitioningController : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nullable, nonatomic, ss_weak) id <SSTransitioningControllerDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, readonly, getter=isPresenting, assign) BOOL presenting;

@end

@protocol SSTransitioningControllerDelegate <NSObject>

@optional
- (void)transitioningController:(__kindof SSTransitioningController *)transitioningController willAnimateTransitioningFromView:(__kindof UIView *)fromView toView:(__kindof UIView *)toView;

@end

NS_ASSUME_NONNULL_END
