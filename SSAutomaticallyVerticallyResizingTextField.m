//
//  SSAutomaticallyVerticallyResizingTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSAutomaticallyVerticallyResizingTextField.h"
#import <SSFoundation/NSArray+SSAdditions.h>

@implementation SSAutomaticallyVerticallyResizingTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ((NSTextFieldCell *)self.cell).wraps = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		((NSTextFieldCell *)self.cell).wraps = YES;
    }
    return self;
}

- (void)sizeToFit {
	CGRect frame = self.frame;
	frame.size.height = CGFLOAT_MAX;
    frame.size = [self.cell cellSizeForBounds:frame];
    frame.origin.y -= frame.size.height - self.frame.size.height;
    self.frame = CGRectIntegral(frame);
    
    [self.constraints firstObjectPassingTest:^BOOL(NSLayoutConstraint * _Nonnull obj) {
        return obj.firstAttribute == NSLayoutAttributeHeight;
    }].constant = CGRectGetHeight(frame);
}

- (void)setStringValue:(NSString *)aString {
	super.stringValue = aString;
	[self sizeToFit];
}

- (void)setObjectValue:(id<NSCopying>)obj {
    super.objectValue = obj;
    [self sizeToFit];
}

@end
