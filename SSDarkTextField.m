//
//  SSDarkTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 28/07/12.
//
//

#import "SSDarkTextField.h"
#import "SSDarkTextFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSDarkTextField

+ (Class)cellClass
{
	return [SSDarkTextFieldCell class];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[[SSDarkTextFieldCell alloc] initTextCell:@" "] autorelease];
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
