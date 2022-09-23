//
//  UIWindow+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/04/16.
//
//

#import "UIWindow+SSAdditions.h"

@implementation UIWindow (SSAdditions)

- (nullable __kindof UIViewController *)leafViewControllerFromRootViewController:(__kindof UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return [self leafViewControllerFromRootViewController:((UINavigationController *)rootViewController).visibleViewController];
    }
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        if (((UITabBarController *)rootViewController).moreNavigationController.topViewController.view.window) {
            return [self leafViewControllerFromRootViewController:((UITabBarController *)rootViewController).moreNavigationController.topViewController];
        } else if (((UITabBarController *)rootViewController).selectedViewController) {
            return [self leafViewControllerFromRootViewController:((UITabBarController *)rootViewController).selectedViewController];
        }
    }
    
    if (rootViewController.presentedViewController) {
        return [self leafViewControllerFromRootViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

- (nullable __kindof UIViewController *)leafViewController {
    return [self leafViewControllerFromRootViewController:self.rootViewController];
}

@end
