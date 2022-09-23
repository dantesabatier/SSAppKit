//
//  UIBarButtonItem+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 12/04/16.
//
//

#import "UIViewController+SSAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (SSAdditions)

- (instancetype)initWithCustomBackBarButtonItemWithTarget:(id)target action:(SEL)action SS_DEPRECATED;
- (instancetype)initWithCustomBackBarButtonItemForViewController:(__kindof UIViewController *)viewController title:(nullable NSString *)title;
- (instancetype)initWithCustomBackBarButtonItemForViewController:(__kindof UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
