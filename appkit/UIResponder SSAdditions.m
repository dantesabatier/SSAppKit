//
//  UIResponder+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 05/10/14.
//
//

#import "UIResponder+SSAdditions.h"
#import "UIApplication+SSAdditions.h"

@implementation UIResponder (SSAdditions)

- (void)centerSelectionInVisibleArea:(id)sender {
    
}

- (void)presentError:(NSError *)error completion:(void (^ __nullable)(void))completion {
    [self.nextResponder presentError:error completion:completion];
}

- (void)presentError:(NSError *)error {
    [self.nextResponder presentError:error];
}

@end
