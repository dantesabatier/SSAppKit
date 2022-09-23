//
//  SSAppKitUtilities.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSAppKitUtilities.h"
#if TARGET_OS_IPHONE
#import <foundation/NSBundle+SSAdditions.h>
#else
#import <SSFoundation/NSBundle+SSAdditions.h>
#endif

static BOOL _SSAppKitIsLoaded = NO;
static NSBundle *__resourcesBundle = nil;

__attribute__((constructor)) 
static void SSAppKitInit(void) {
    @autoreleasepool {
        if (!_SSAppKitIsLoaded) {
            _SSAppKitIsLoaded = YES;
        }
    }
}

__attribute__((destructor)) 
static void SSAppKitDestroy(void) {
    [__resourcesBundle release];
}

NSBundle *SSAppKitGetResourcesBundle() {
    if (!__resourcesBundle) {
#if TARGET_OS_IPHONE
        __resourcesBundle = [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SSAppKitResources" withExtension:@"bundle"]] ss_retain];
#else
        __resourcesBundle = [[NSBundle bundleWithIdentifier:@"com.sabatiersoftware.ssappkit"] ss_retain];
#endif
    }
    return __resourcesBundle;
}

id SSAppKitGetImageResourceNamed(NSString *name) {
    return [SSAppKitGetResourcesBundle() imageForResource:name];
}
