//
//  SSDarkSearchFieldCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 10/08/12.
//
//

#import "SSDarkSearchFieldCell.h"
#import <SSGraphics/SSGraphics.h>

@implementation SSDarkSearchFieldCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.textColor = [NSColor whiteColor];
    }
    return self;
}

- (instancetype)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self) {
        self.textColor = [NSColor whiteColor];
    }
    return self;
}

@end
