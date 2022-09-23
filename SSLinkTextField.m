//
//  SSLinkTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 22/05/14.
//
//

#import "SSLinkTextField.h"
#import "SSSourceListLinkCell.h"

@implementation SSLinkTextField

+ (Class)cellClass {
	return [SSSourceListLinkCell class];
}

- initWithCoder: (NSCoder *)origCoder {
	if (![origCoder isKindOfClass: [NSKeyedUnarchiver class]])
        self = [super initWithCoder: origCoder];
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

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
    NSEvent *event = NSApp.currentEvent;
    if (event && NSMouseInRect([self convertPoint:event.locationInWindow fromView:nil], [self.cell buttonRectForBounds:self.frame], self.isFlipped)) {
        return [super sendAction:theAction to:theTarget];
    }
    return NO;
}

@end
