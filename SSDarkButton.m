//
//  SSDarkButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 5/1/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDarkButton.h"
#import "SSDarkButtonCell.h"

@implementation SSDarkButton

+ (Class)cellClass 
{
	return [SSDarkButtonCell class];
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
        
        ((SSDarkButtonCell *) self.cell).cornerRadius = 3.5;
	}
	
	return self;
}

- (BOOL)allowsVibrancy
{
    return NO;
}

@end
