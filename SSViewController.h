//
//  SSViewController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/18/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <foundation/NSObject+SSAdditions.h>
#import "UIViewController+SSAdditions.h"
#else
#import <Cocoa/Cocoa.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if TARGET_OS_IPHONE
@interface SSViewController : UIViewController
#else
@interface SSViewController : NSViewController
#endif

@end

NS_ASSUME_NONNULL_END

