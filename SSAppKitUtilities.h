//
//  SSAppKitUtilities.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIImage.h>
#import <base/SSDefines.h>
#else
#import <AppKit/NSImage.h>
#import <SSBase/SSDefines.h>
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSBundle *SSAppKitGetResourcesBundle(void);
#if TARGET_OS_IPHONE
extern UIImage *__nullable SSAppKitGetImageResourceNamed(NSString *imageName);
#else
extern NSImage *__nullable SSAppKitGetImageResourceNamed(NSString *imageName);
#endif

#define SSAppKitLocalizedString(key, comment) [SSAppKitGetResourcesBundle() localizedStringForKey:(key) value:@"" table:nil]

NS_ASSUME_NONNULL_END
