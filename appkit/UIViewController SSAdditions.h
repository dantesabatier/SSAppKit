//
//  UIViewController+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 09/02/15.
//
//

#import "UIView+SSAdditions.h"
#import "UIWindow+SSAdditions.h"
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (SSAdditions)

@property (nullable, nonatomic, ss_strong) id representedObject;
@property (nullable, nonatomic, readonly, ss_strong) __kindof UIViewController *presenterViewController;
- (IBAction)dismiss:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
