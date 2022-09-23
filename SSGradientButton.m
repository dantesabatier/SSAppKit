//
//  SSGradientButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientButton.h"
#import "SSGradientButtonCell.h"

@implementation SSGradientButton

+ (Class)cellClass {
	return [SSGradientButtonCell class];
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
        
        ((SSGradientButtonCell *) self.cell).cornerRadius = 3.5;
	}
	return self;
}

@end
