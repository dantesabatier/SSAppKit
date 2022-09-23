//
//  SSAutomaticallyVerticallyResizingDarkTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 26/12/12.
//
//

#import "SSAutomaticallyVerticallyResizingDarkTextField.h"
#import "SSDarkTextFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSAutomaticallyVerticallyResizingDarkTextField

+ (Class)cellClass
{
	return SSDarkTextFieldCell.class;
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
    
    ((SSDarkTextFieldCell *)self.cell).wraps = YES;
	
	return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.cell = [[[SSDarkTextFieldCell alloc] initTextCell:@" "] autorelease];
        ((SSDarkTextFieldCell *)self.cell).wraps = YES;
    }
    return self;
}

@end
