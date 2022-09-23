//
//  SSSearchField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/12/14.
//
//

#import "SSSearchField.h"
#import "SSSearchFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSSearchField

+ (Class)cellClass {
    return [SSSearchFieldCell class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[[SSSearchFieldCell alloc] initTextCell:@" "] autorelease];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)origCoder {
    if (![origCoder isKindOfClass:[NSKeyedUnarchiver class]]) {
        self = [super initWithCoder:origCoder];
    } else {
        NSKeyedUnarchiver *coder = (id)origCoder;
        NSString *oldClassName = [[self.superclass cellClass] className];
        Class oldClass = [coder classForClassName: oldClassName];
        if(!oldClass)
            oldClass = [super.superclass cellClass];
        [coder setClass: [self.class cellClass] forClassName: oldClassName];
        self = [super initWithCoder: coder];
        [coder setClass: oldClass forClassName: oldClassName];
    }
    
    return self;
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        [super prepareForInterfaceBuilder];
    }
    
    self.cell = [[[SSSearchFieldCell alloc] initTextCell:@" "] autorelease];
}

#endif

@end
