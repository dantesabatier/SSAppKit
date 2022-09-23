//
//  SSTexturedSlider.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTexturedSlider.h"
#import "SSTexturedSliderCell.h"
#import <SSBase/SSDefines.h>

@implementation SSTexturedSlider

+ (Class)cellClass {
	return [SSTexturedSliderCell class];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (![aDecoder isKindOfClass:[NSKeyedUnarchiver class]])
        self = [super initWithCoder:aDecoder];
	else {
		NSKeyedUnarchiver *coder = (id)aDecoder;
		NSString *oldClassName = [[self.superclass cellClass] className];
		Class oldClass = [coder classForClassName: oldClassName];
		if (!oldClass)
			oldClass = [super.superclass cellClass];
		[coder setClass: [self.class cellClass] forClassName: oldClassName];
		self = [super initWithCoder: coder];
		[coder setClass: oldClass forClassName: oldClassName];
	}
	
	return self;
}

- (void)prepareForInterfaceBuilder {
    self.cell = [[[SSTexturedSliderCell alloc] init]  autorelease];
}

- (BOOL)becomeFirstResponder {
	[self.cell setShowsFirstResponder:YES];
	
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[self.cell setShowsFirstResponder:NO];
	
	return [super resignFirstResponder];
}

- (void)setNeedsDisplayInRect:(CGRect)invalidRect {
    [super setNeedsDisplayInRect:self.bounds];
}

@end
