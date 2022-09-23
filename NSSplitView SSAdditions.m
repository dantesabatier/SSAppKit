//
//  NSSplitView+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 30/01/17.
//
//

#import "NSSplitView+SSAdditions.h"
#import <SSFoundation/NSObject+SSAdditions.h>

@implementation NSSplitView (SSAdditions)

- (void)toogleSubview:(__kindof NSView *)subview animated:(BOOL)animated {
    SEL selector = [self isSubviewCollapsed:subview] ? NSSelectorFromString(@"_uncollapseArrangedView:animated:") : NSSelectorFromString(@"_collapseArrangedView:animated:");
    if ([self respondsToSelector:selector]) {
        NSMethodSignature *signature = [NSSplitView instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self;
        invocation.selector = selector;
        [invocation setArgument:&subview atIndex:2];
        [invocation setArgument:&animated atIndex:3];
        [invocation invoke];
    }
}

- (void)setDividerColor:(NSColor *)dividerColor {
    ((void(*)(id, SEL, NSColor *))SSObjectPerformSupersequentMethodImplementation(self, _cmd, SSObjectGetMethodImplementationOfSelector(self, _cmd))) (self, _cmd, dividerColor);
}

@end
