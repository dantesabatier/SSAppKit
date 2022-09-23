//
//  SSSourceListCheckCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 2/17/13.
//
//

#import "SSSourceListCheckCell.h"
#import <SSBase/SSDefines.h>

@implementation SSSourceListCheckCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	if (self) {
        _buttonCell.buttonType = NSSwitchButton;
        _buttonCell.imagePosition = NSImageOnly;
        _buttonCell.imageScaling = NSImageScaleProportionallyDown;
        _buttonCell.bordered = NO;
    }
    return self;
}

- (CGRect)buttonRectForBounds:(CGRect)bounds {
    CGRect buttonRect = [super buttonRectForBounds:bounds];
    buttonRect.origin.x = CGRectGetMinX(bounds);
    return buttonRect;
}

- (CGRect)imageRectForBounds:(CGRect)bounds {
    CGRect imageRect = [super imageRectForBounds:bounds];
    imageRect.origin.x = FLOOR(CGRectGetMaxX([self buttonRectForBounds:bounds]) + 3.0);
    return imageRect;
}

- (CGRect)badgeRectForBounds:(CGRect)bounds {
    CGRect badgeRect = [super badgeRectForBounds:bounds];
    badgeRect.origin.x = FLOOR(CGRectGetMaxX(bounds) - CGRectGetWidth(badgeRect));
    return badgeRect;
}

@end
