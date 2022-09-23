//
//  SSControl.h
//  SSAppKit
//
//  Created by Dante Sabatier on 18/09/12.
//
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import <Cocoa/Cocoa.h>
#endif
#import "SSKeyValueBinding.h"

#if TARGET_OS_IPHONE
@interface SSControl : UIControl <SSKeyValueBinding>
#else
@interface SSControl : NSControl <SSKeyValueBinding>
#endif

@end
