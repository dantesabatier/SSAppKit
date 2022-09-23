//
//  SSSidebarPresenterViewController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 16/02/16.
//
//

#import "SSSidebarPresenterViewController.h"
#import <foundation/NSArray+SSAdditions.h>
#import <base/SSGeometry.h>

#define SSSidebarPresenterViewControllerImageViewTag 1254
#define SSSidebarPresenterViewControllerSidebarViewTag 1255
#define SSSidebarPresenterViewControllerContentViewTag 1256
#define SSSidebarPresenterViewControllerSidebarViewMinimumRelativeValue -15
#define SSSidebarPresenterViewControllerSidebarViewMaximumRelativeValue 15
#define SSSidebarPresenterViewControllerContentViewMinimumRelativeValue -25
#define SSSidebarPresenterViewControllerContentViewMaximumRelativeValue 25
#define SSSidebarPresenterViewControllerAnimationDuration 0.35

@interface SSSidebarPresenterViewController () <UIGestureRecognizerDelegate>

@end

@implementation SSSidebarPresenterViewController

- (void)dealloc
{
    self.presentedSidebarViewController = nil;
    
    [super ss_dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.bounds] autorelease];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = SSViewAutoresizingAll;
    imageView.tag = SSSidebarPresenterViewControllerImageViewTag;
    
    UIView *sidebarView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    sidebarView.autoresizingMask = SSViewAutoresizingAll;
    sidebarView.tag = SSSidebarPresenterViewControllerSidebarViewTag;
    
    UIView *contentView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
    contentView.autoresizingMask = SSViewAutoresizingAll;
    contentView.tag = SSSidebarPresenterViewControllerContentViewTag;
    
    self.view.subviews = @[imageView, sidebarView, contentView];
    
    //TODO:add pan gestures recognizer
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark actions

- (void)presentSidebarViewController:(__kindof UIViewController <SSSidebarViewController> *)sidebarViewController animated:(BOOL)animated completion:(void (^)(void))completion;
{
    UIView *sidebarView = [self.view viewWithTag:SSSidebarPresenterViewControllerSidebarViewTag];
    sidebarView.center = SSRectGetCenterPoint(self.view.bounds);
    
    __kindof UIViewController *presentedSidebarViewController = self.presentedSidebarViewController;
    if (![sidebarViewController isEqual:presentedSidebarViewController]) {
        [presentedSidebarViewController.view removeFromSuperview];
        [presentedSidebarViewController willMoveToParentViewController:nil];
        [presentedSidebarViewController removeFromParentViewController];
        [presentedSidebarViewController didMoveToParentViewController:nil];
        
        for (UIMotionEffect *effect in sidebarView.motionEffects) {
            [sidebarView removeMotionEffect:effect];
        }
        
        UIInterpolatingMotionEffect *interpolationHorizontal = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis] autorelease];
        interpolationHorizontal.minimumRelativeValue = @(SSSidebarPresenterViewControllerSidebarViewMinimumRelativeValue);
        interpolationHorizontal.maximumRelativeValue = @(SSSidebarPresenterViewControllerSidebarViewMaximumRelativeValue);
        
        UIInterpolatingMotionEffect *interpolationVertical = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis] autorelease];
        interpolationVertical.minimumRelativeValue = @(SSSidebarPresenterViewControllerSidebarViewMinimumRelativeValue);
        interpolationVertical.maximumRelativeValue = @(SSSidebarPresenterViewControllerSidebarViewMaximumRelativeValue);
        
        [sidebarView addMotionEffect:interpolationHorizontal];
        [sidebarView addMotionEffect:interpolationVertical];
        
        [sidebarViewController willMoveToParentViewController:self];
        
        sidebarViewController.view.autoresizingMask = SSViewAutoresizingAll;
        sidebarViewController.view.frame = self.view.bounds;
        
        [sidebarView addSubview:sidebarViewController.view];
        
        [self addChildViewController:sidebarViewController];
        
        [sidebarViewController didMoveToParentViewController:self];
    }
    
    __kindof UIViewController *selectedContentViewController = sidebarViewController.selectedContentViewController;
    selectedContentViewController.view.autoresizingMask = SSViewAutoresizingAll;
    selectedContentViewController.view.frame = self.view.bounds;
    
    UIView *contentView = [self.view viewWithTag:SSSidebarPresenterViewControllerContentViewTag];
    contentView.shadow = ({
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        shadow.shadowBlurRadius = 6.0;
        shadow.shadowOffset = CGSizeZero;
        shadow.shadowColor = [UIColor blackColor];
        shadow;
    });
    
    CGAffineTransform transform = contentView.transform;
    CGFloat scale = sqrt(transform.a * transform.a + transform.c * transform.c);
    CGRect frame = contentView.frame;
    contentView.transform = CGAffineTransformIdentity;
    contentView.transform = CGAffineTransformMakeScale(scale, scale);
    contentView.frame = frame;
    contentView.subviews = @[selectedContentViewController.view];
    
    void (^end)(void) = ^{
        sidebarViewController.shown = presentedSidebarViewController ? YES : NO;
        
        if (completion) {
            completion();
        }
    };
    
    if (animated) {
        contentView.transform = CGAffineTransformIdentity;
        
        UIImageView *imageView = [self.view viewWithTag:SSSidebarPresenterViewControllerImageViewTag];
        imageView.transform = CGAffineTransformMakeScale(1.7, 1.7);
        
        sidebarView.transform = CGAffineTransformMakeScale(1.5, 1.5);
        sidebarView.alpha = 0.0;
        
        [sidebarViewController beginAppearanceTransition:YES animated:YES];
        sidebarViewController.view.hidden = NO;
        
        [self.view.window endEditing:YES];
        
        [UIView animateWithDuration:SSSidebarPresenterViewControllerAnimationDuration animations:^{
            contentView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
                contentView.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 30 + CGRectGetWidth(self.view.frame) : 30 + CGRectGetWidth(self.view.frame)), contentView.center.y);
            } else {
                contentView.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? 30 + CGRectGetHeight(self.view.frame) : 30 + CGRectGetWidth(self.view.frame)), contentView.center.y);
            }
            
            contentView.alpha = 1.0;
            sidebarView.alpha = 1.0;
            sidebarView.transform = CGAffineTransformIdentity;
            imageView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            for (UIMotionEffect *effect in contentView.motionEffects) {
                [contentView removeMotionEffect:effect];
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                UIInterpolatingMotionEffect *interpolationHorizontal = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis] autorelease];
                interpolationHorizontal.minimumRelativeValue = @(SSSidebarPresenterViewControllerContentViewMinimumRelativeValue);
                interpolationHorizontal.maximumRelativeValue = @(SSSidebarPresenterViewControllerContentViewMaximumRelativeValue);
                
                UIInterpolatingMotionEffect *interpolationVertical = [[[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis] autorelease];
                interpolationVertical.minimumRelativeValue = @(SSSidebarPresenterViewControllerContentViewMinimumRelativeValue);
                interpolationVertical.maximumRelativeValue = @(SSSidebarPresenterViewControllerContentViewMaximumRelativeValue);
                
                [contentView addMotionEffect:interpolationHorizontal];
                [contentView addMotionEffect:interpolationVertical];
            }];
            
            [sidebarViewController endAppearanceTransition];
            
            end();
        }];
    } else {
        end();
    }
    
    self.presentedSidebarViewController = sidebarViewController;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3 animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (void)dismissSidebarViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion;
{
    __kindof UIViewController <SSSidebarViewController> *presentedSidebarViewController = self.presentedSidebarViewController;
    __kindof UIViewController *selectedContentViewController = [presentedSidebarViewController selectedContentViewController];
    selectedContentViewController.view.frame = self.view.bounds;
    
    [presentedSidebarViewController beginAppearanceTransition:animated animated:animated];
    
    UIView *contentView = [self.view viewWithTag:SSSidebarPresenterViewControllerContentViewTag];
    UIView *currentView = contentView.subviews.firstObject;
    UIView *presentingView = selectedContentViewController.view;
    if (currentView != presentingView) {
        presentingView.alpha = 0.0;
        
        [contentView addSubview:presentingView];
        
        [UIView animateWithDuration:SSSidebarPresenterViewControllerAnimationDuration animations:^{
            currentView.alpha = 0.0;
            presentingView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [currentView removeFromSuperview];
        }];
    }
    
    void (^update)(void) = ^{
        contentView.transform = CGAffineTransformIdentity;
        contentView.frame = self.view.bounds;
        
        UIView *sidebarView = [self.view viewWithTag:SSSidebarPresenterViewControllerSidebarViewTag];
        sidebarView.transform = CGAffineTransformMakeScale(1.5, 1.5);
        sidebarView.alpha = 0.0;
        contentView.alpha = 1.0;
        
        UIImageView *imageView = [self.view viewWithTag:SSSidebarPresenterViewControllerImageViewTag];
        imageView.transform = CGAffineTransformMakeScale(1.7, 1.7);
        
        for (UIMotionEffect *effect in contentView.motionEffects) {
            [contentView removeMotionEffect:effect];
        }
    };
    
    void (^end)(void) = ^{
        contentView.shadow = nil;
        
        [presentedSidebarViewController endAppearanceTransition];
        
        presentedSidebarViewController.shown = NO;
        
        if (completion) {
            completion();
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:SSSidebarPresenterViewControllerAnimationDuration animations:^{
            update();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            end();
        }];
    } else {
        update();
        end();
    }
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3 animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

#pragma mark getters & setters

- (UIImageView *)backgroundImageView;
{
    return [self.view viewWithTag:SSSidebarPresenterViewControllerImageViewTag];
}

- (__kindof UIViewController <SSSidebarViewController> *)presentedSidebarViewController
{
    return [self associatedValueForKey:@"presentedSidebarViewController"];
}

- (void)setPresentedSidebarViewController:(__kindof UIViewController <SSSidebarViewController> *)presentedSidebarViewController
{
    [self setNonAtomicRetainedAssociatedValue:presentedSidebarViewController forKey:@"presentedSidebarViewController"];
}

@end

@implementation UIViewController (SSSidebarPresenterViewControllerAdditions)

- (__kindof UIViewController *)sidebarPresenterViewController
{
    SSSidebarPresenterViewController *sidebarPresenterViewController = nil;
    if ([self isKindOfClass:[SSSidebarPresenterViewController class]]) {
        return self;
    }
    
    __kindof UIViewController *parentViewController = self.parentViewController;
    while (parentViewController != nil) {
        if ([parentViewController isKindOfClass:[SSSidebarPresenterViewController class]]) {
            sidebarPresenterViewController = parentViewController;
            break;
        }
        parentViewController = parentViewController.parentViewController;
    }
    return sidebarPresenterViewController;
}

- (IBAction)presentSidebarViewController:(id)sender;
{
    SSSidebarPresenterViewController *sidebarPresenterViewController = self.sidebarPresenterViewController;
    [sidebarPresenterViewController presentSidebarViewController:sidebarPresenterViewController.presentedSidebarViewController animated:YES completion:nil];
}

- (IBAction)dismissSidebarViewController:(id)sender;
{
    [self.sidebarPresenterViewController dismissSidebarViewControllerAnimated:YES completion:nil];
}

- (IBAction)toggleSidebarViewController:(id)sender
{
    SSSidebarPresenterViewController *sidebarPresenterViewController = self.sidebarPresenterViewController;
    __kindof UIViewController <SSSidebarViewController> *presentedSidebarViewController = sidebarPresenterViewController.presentedSidebarViewController;
    if (presentedSidebarViewController.isShown) {
        [sidebarPresenterViewController dismissSidebarViewControllerAnimated:YES completion:nil];
    } else {
        [sidebarPresenterViewController presentSidebarViewController:presentedSidebarViewController animated:YES completion:nil];
    }
}

@end
