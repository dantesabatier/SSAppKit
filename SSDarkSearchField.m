//
//  SSDarkSearchField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/12/14.
//
//

#import "SSDarkSearchField.h"
#import "SSDarkSearchFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSDarkSearchField

+ (Class)cellClass
{
    return [SSDarkSearchFieldCell class];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[[SSDarkSearchFieldCell alloc] initTextCell:@" "] autorelease];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)origCoder
{
    if (![origCoder isKindOfClass:[NSKeyedUnarchiver class]])
        self = [super initWithCoder:origCoder];
    else {
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

- (BOOL)allowsVibrancy
{
    return YES;
}

@end
