//
//  SSInsetTextField.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSInsetTextField.h"

@implementation SSInsetTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        ((NSTextFieldCell *)self.cell).backgroundStyle = NSBackgroundStyleRaised;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self) {
        ((NSTextFieldCell *)self.cell).backgroundStyle = NSBackgroundStyleRaised;
	}
	return self;
}

@end
