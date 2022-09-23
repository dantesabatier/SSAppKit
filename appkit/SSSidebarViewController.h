//
//  SSSidebarViewController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 16/02/16.
//
//

#import "UIViewController+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@class SSSidebarPresenterViewController;

@protocol SSSidebarViewController <NSObject>

@property (nullable, nonatomic, readonly, ss_weak) __kindof UIViewController *selectedContentViewController;
@property (nonatomic, getter=isShown) BOOL shown;

@end

@interface SSSidebarViewController : UIViewController <SSSidebarViewController>

@property (nullable, nonatomic, readonly, ss_strong) NSArray <__kindof UIViewController *> *contentViewControllers;
@property (nullable, nonatomic, readonly, ss_weak) __kindof UIViewController *selectedContentViewController;
@property (nullable, nonatomic, readonly, ss_weak) __kindof SSSidebarPresenterViewController *sidebarPresenterViewController;
@property (nonatomic, getter=isShown) BOOL shown;
- (instancetype)initWithContentViewControllers:(NSArray <__kindof UIViewController *> *)contentViewControllers sidebarPresenterViewController:(__kindof SSSidebarPresenterViewController *)sidebarPresenterViewController;

@end

NS_ASSUME_NONNULL_END
