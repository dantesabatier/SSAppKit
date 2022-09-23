//
//  SSThemedView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/10/12.
//
//

#import <Foundation/Foundation.h>
#import "SSTheme.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSThemedView <NSObject>

@required
@property (nullable, nonatomic, strong) __kindof id <SSTheme> theme;

@optional

@end

NS_ASSUME_NONNULL_END
