//
//  UIApplication+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 25/11/15.
//
//

#import "UIApplication+SSAdditions.h"
#import "UIWindow+SSAdditions.h"
#import <base/SSDefines.h>

@implementation UIApplication (SSAdditions)

- (void)presentError:(NSError *)error {
    if (!error) {
        NSLog(@"%@ %@ Called with a (null) error, users deserves better...", self.class, NSStringFromSelector(_cmd));
        error = [NSError errorWithDomain:@"SSAppKitErrorDomain" code:3245 userInfo:@{NSLocalizedDescriptionKey:SSLocalizedString(@"An unexpected error has occurred", @"error description")}];
    }
    
    NSString *message = nil;
    if (!(message = error.localizedFailureReason)) {
        message = error.localizedRecoverySuggestion;
    }
    
    if (message.length && error.localizedRecoverySuggestion && ![message isEqualToString:error.localizedRecoverySuggestion]) {
        message = [message stringByAppendingFormat:@"\n%@", error.localizedRecoverySuggestion];
    }
#if defined(__IPHONE_8_0)
    UIViewController *leafViewController = self.keyWindow.leafViewController;
    if (!leafViewController.presentedViewController) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"button title") style:UIAlertActionStyleDefault handler:nil]];
        [leafViewController presentViewController:alertController animated:YES completion:nil];
    }
#else
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription message:message delegate:nil cancelButtonTitle:SSLocalizedString(@"OK", @"button title") otherButtonTitles:nil] show];
#endif
}

- (void)presentError:(NSError *)error completion:(void (^ __nullable)(void))completion {
#if defined(__IPHONE_8_0)
    UIViewController *leafViewController = self.keyWindow.leafViewController;
    if (!leafViewController.presentedViewController) {
        if (!error) {
            NSLog(@"%@ %@ Called with a (null) error, users deserves better...", self.class, NSStringFromSelector(_cmd));
            error = [NSError errorWithDomain:@"SSAppKitErrorDomain" code:3245 userInfo:@{NSLocalizedDescriptionKey:SSLocalizedString(@"An unexpected error has occurred", @"error description")}];
        }
        
        NSString *message = nil;
        if (!(message = error.localizedFailureReason)) {
            message = error.localizedRecoverySuggestion;
        }
        
        if (message.length && error.localizedRecoverySuggestion && ![message isEqualToString:error.localizedRecoverySuggestion]) {
            message = [message stringByAppendingFormat:@"\n%@", error.localizedRecoverySuggestion];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"button title") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion();
            }
        }]];
        [leafViewController presentViewController:alertController animated:YES completion:nil];
    }
#endif
}

@end
