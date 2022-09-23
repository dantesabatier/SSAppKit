//
//  SSBackButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 9/3/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSBackButton.h"
#import "SSBackButtonCell.h"

@implementation SSBackButton

+ (Class)cellClass {
	return SSBackButtonCell.class;
}

- (instancetype)initWithCoder:(NSCoder *)origCoder {
    if (![origCoder isKindOfClass:[NSKeyedUnarchiver class]]) {
        self = [super initWithCoder:origCoder];
    } else {
		NSKeyedUnarchiver *coder = (id)origCoder;
		NSString *oldClassName = [[self.superclass cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
        if (!oldClass) {
            oldClass = [super.superclass cellClass];
        }
		[coder setClass: [self.class cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}
	
	return self;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
