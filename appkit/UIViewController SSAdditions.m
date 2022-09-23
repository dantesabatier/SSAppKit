//
//  UIViewController+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 09/02/15.
//
//

#import "UIViewController+SSAdditions.h"

@implementation UIViewController (SSAdditions)

- (id)representedObject {
    return SSGetAssociatedValueForKey(@"representedObject");
}

- (void)setRepresentedObject:(id)representedObject {
    SSSetAtomicRetainedAssociatedValueForKey(@"representedObject", representedObject);
}

- (nullable __kindof UIViewController *)presenterViewController {
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]] && ([((UINavigationController *)self.presentingViewController).presentedViewController isEqual:self.navigationController] || [((UINavigationController *)self.presentingViewController).presentedViewController isEqual:self])) {
        return ((UINavigationController *)self.presentingViewController).topViewController;
    }
    
    if ([self.presentingViewController isKindOfClass:[UITabBarController class]]) {
        if ([((UITabBarController *)self.presentingViewController).selectedViewController isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController *)((UITabBarController *)self.presentingViewController).selectedViewController).topViewController;
        }
        
        if ([((UITabBarController *)self.presentingViewController).moreNavigationController.topViewController isEqual:self]) {
            return ((UITabBarController *)self.presentingViewController).moreNavigationController;
        }
    }
    
    return self.presentingViewController;
}

- (void)__dismiss:(BOOL)animated __completion:(void(^ __nullable)(void))completion {
    __kindof UIViewController *presenterViewController = self.presenterViewController;
    SSDebugLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    SSDebugLog(@"%@ %@", presenterViewController.class, NSStringFromSelector(@selector(dismissViewControllerAnimated:completion:)));
    [presenterViewController dismissViewControllerAnimated:animated completion:completion];
}

- (IBAction)dismiss:(nullable id)sender {
    SSDebugLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
    [self __dismiss:YES __completion:nil];
}

@end

