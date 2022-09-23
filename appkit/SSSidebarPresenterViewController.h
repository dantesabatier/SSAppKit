//
//  SSSidebarPresenterViewController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 16/02/16.
//
//

#import "SSSidebarViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSSidebarPresenterViewControllerObserver <NSObject>

- (void)sidebarPresenterViewControllerDidChange:(SSSidebarPresenterViewController *)sidebarPresenterViewController;

@end

@interface SSSidebarPresenterViewController : UIViewController

@property (nullable, nonatomic, readonly, ss_strong) UIImageView *backgroundImageView;
@property (nullable, nonatomic, readonly, ss_strong) __kindof UIViewController <SSSidebarViewController> *presentedSidebarViewController;
- (void)presentSidebarViewController:(__kindof UIViewController <SSSidebarViewController> *)sidebarViewController animated:(BOOL)animated completion:(void (^__nullable)(void))completion;
- (void)dismissSidebarViewControllerAnimated:(BOOL)animated completion:(void (^__nullable)(void))completion;

@end

@interface UIViewController (SSSidebarPresenterViewControllerAdditions)

@property (nullable, nonatomic, readonly, ss_weak) __kindof SSSidebarPresenterViewController *sidebarPresenterViewController;
- (IBAction)presentSidebarViewController:(nullable id)sender;
- (IBAction)dismissSidebarViewController:(nullable id)sender;
- (IBAction)toggleSidebarViewController:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
