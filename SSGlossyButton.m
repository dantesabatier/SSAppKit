//
//  SSGlossyButton.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/12.
//
//

#import "SSGlossyButton.h"

#import "SSGlossyButtonCell.h"

@implementation SSGlossyButton

+ (Class)cellClass
{
	return [SSGlossyButtonCell class];
}

- (id)initWithCoder:(NSCoder *)origCoder
{
	if (![origCoder isKindOfClass:[NSKeyedUnarchiver class]])
        self = [super initWithCoder:origCoder];
	else
	{
		NSKeyedUnarchiver *coder = (id)origCoder;
		NSString *oldClassName = [[[self superclass] cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if(!oldClass)
			oldClass = [[super superclass] cellClass];
		[coder setClass: [self.class cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
        
        ((SSGlossyButtonCell *)self.cell).cornerRadius = 3.5;
	}
	
	return self;
}


@end
