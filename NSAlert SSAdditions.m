//
//  NSAlert+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 9/13/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSAlert+SSAdditions.h"

#if (NS_BLOCKS_AVAILABLE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9))

@interface _SSAlertCompletionHandlerRunner : NSObject {
    NSAlert *_alert;
    void (^_completionHandler)(NSInteger returnCode);
}

@end

@implementation _SSAlertCompletionHandlerRunner

- (instancetype)initWithAlert:(NSAlert *)alert completionHandler:(void (^)(NSInteger returnCode))handler {
    self = [super init];
    if (self) {
        _alert = [alert ss_retain];
        _completionHandler = [handler copy];
    }
    
    return self;
}

- (void)dealloc {
    [_alert release];
    [_completionHandler release];
    
    [super ss_dealloc];
}

- (void)startOnWindow:(NSWindow *)parentWindow {
	[self ss_retain];
    
    [_alert beginSheetModalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSAssert(alert == _alert, @"Got an alert different from what I expected -- This should never happen");
    
    [self autorelease];
    
    if (_completionHandler) {
        _completionHandler(returnCode);
    }
}

@end

#endif

@implementation NSAlert (SSAdditions)

#if (NS_BLOCKS_AVAILABLE && defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_9)) && !DEBUG
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger returnCode))handler {
    _SSAlertCompletionHandlerRunner *runner = [[_SSAlertCompletionHandlerRunner alloc] initWithAlert:self completionHandler:handler];
    [runner startOnWindow:window];
    [runner release];
}
#pragma clang diagnostic pop
#endif

@end

#if NS_BLOCKS_AVAILABLE

void SSBeginAlertSheet(NSString *title, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, NSWindow *docWindow, void (^completionHandler)(NSInteger returnCode), NSString *msgFormat, ...) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = title;
    
    if (msgFormat) {
        va_list args;
        va_start(args, msgFormat);
        NSString *informativeText = [[NSString alloc] initWithFormat:msgFormat arguments:args];
        va_end(args);
        
        alert.informativeText = informativeText;
        [informativeText release];
    }
    
    if (defaultButton)
        [alert addButtonWithTitle:defaultButton];
    if (alternateButton)
        [alert addButtonWithTitle:alternateButton];
    if (otherButton)
        [alert addButtonWithTitle:otherButton];
    
    [alert beginSheetModalForWindow:docWindow completionHandler:completionHandler];
    [alert release]; // retained by the runner while the sheet is up
}

#endif
