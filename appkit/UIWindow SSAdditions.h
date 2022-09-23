//
//  UIWindow+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 11/04/16.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (SSAdditions)

@property (nullable, nonatomic, readonly, unsafe_unretained) __kindof UIViewController *leafViewController;

@end

NS_ASSUME_NONNULL_END
