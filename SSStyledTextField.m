//
//  SSStyledTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 1/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSStyledTextField.h"
#import "SSStyledTextFieldCell.h"
#import "NSColor+SSAdditions.h"

@implementation SSStyledTextField

+ (Class)cellClass {
	return [SSStyledTextFieldCell class];
}

- (instancetype) initWithCoder: (NSCoder *)origCoder {
    if (![origCoder isKindOfClass: [NSKeyedUnarchiver class]]) {
        self = [super initWithCoder: origCoder];
    } else {
		NSKeyedUnarchiver *coder = (id)origCoder;
		NSString *oldClassName = [[self.superclass cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if(!oldClass)
			oldClass = [super.superclass cellClass];
		[coder setClass: [self.class cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
		
        self.shadowColor = [self.textColor.contrastingLabelColor colorWithAlphaComponent:0.7];
        self.shadowOffset = CGSizeMake(0, -1);
	}
	
	return self;
}

- (NSColor *)shadowColor {
    return ((SSStyledTextFieldCell *)self.cell).shadowColor;
}

- (void)setShadowColor:(NSColor *)shadowColor {
    ((SSStyledTextFieldCell *)self.cell).shadowColor = shadowColor;
    
    self.needsDisplay = YES;
}

- (CGSize)shadowOffset {
    return ((SSStyledTextFieldCell *)self.cell).shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    ((SSStyledTextFieldCell *)self.cell).shadowOffset = shadowOffset;
    
    self.needsDisplay = YES;
}

@end
