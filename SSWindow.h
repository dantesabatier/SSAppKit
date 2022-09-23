//
//  SSWindow.h
//  SSAppKit
//
//  Created by Dante Sabatier on 05/09/12.
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

#if TARGET_OS_IPHONE
@interface SSWindow : UIWindow
#else
@interface SSWindow : NSWindow
#endif

@end
