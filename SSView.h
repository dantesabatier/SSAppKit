//
//  SSView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 18/09/12.
//
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import "UIView+SSAdditions.h"
#else
#import <Cocoa/Cocoa.h>
#import "NSView+SSAdditions.h"
#endif
#import "SSKeyValueBinding.h"

#if TARGET_OS_IPHONE
@interface SSView : UIView <SSKeyValueBinding>
#else
@interface SSView : NSView <SSKeyValueBinding>
#endif

@end
