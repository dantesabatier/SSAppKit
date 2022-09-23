//
//  SSDarkPopUpButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/28/12.
//
//

#import "SSDarkPopUpButton.h"
#import "SSDarkPopUpButtonCell.h"

@implementation SSDarkPopUpButton

+ (Class)cellClass
{
	return [SSDarkPopUpButtonCell class];
}

- (instancetype)initWithCoder:(NSCoder *)origCoder
{
	if (![origCoder isKindOfClass:[NSKeyedUnarchiver class]])
        self = [super initWithCoder:origCoder];
    else {
		NSKeyedUnarchiver *coder = (id)origCoder;
		NSString *oldClassName = [[self.superclass cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if (!oldClass) oldClass = [super.superclass cellClass];
		[coder setClass: [self.class cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}
	
	return self;
}

- (BOOL)allowsVibrancy
{
    return NO;
}

@end
