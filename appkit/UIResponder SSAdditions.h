//
//  UIResponder+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 05/10/14.
//
//

#import <UIKit/UIKit.h>
#import <foundation/NSObject+SSAdditions.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (SSAdditions)

- (void)centerSelectionInVisibleArea:(nullable id)sender;
- (void)presentError:(NSError *)error completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(8_0);
- (void)presentError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
