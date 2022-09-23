//
//  SSStyledTextFieldCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 1/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSStyledTextFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSStyledTextFieldCell

- (id)copyWithZone:(NSZone *)zone {
    SSStyledTextFieldCell *cell = (SSStyledTextFieldCell *) [super copyWithZone:zone];
    cell->_shadowColor = [_shadowColor ss_retain];
	
    return cell;
}

- (void)dealloc {
    [_shadowColor release];
    
    [super ss_dealloc];
}

- (void)drawInteriorWithFrame:(CGRect)cellFrame inView:(id)controlView {
	NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = self.shadowOffset;
    shadow.shadowColor = self.shadowColor;
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
	[shadow set];
    
	[super drawInteriorWithFrame:cellFrame inView:controlView];
	
	[context restoreGraphicsState];
	[shadow release]; 
}

- (NSColor *)shadowColor {
    return _shadowColor;
}

- (void)setShadowColor:(NSColor *)shadowColor {
    SSNonAtomicRetainedSet(_shadowColor, shadowColor);
}

- (CGSize)shadowOffset {
    return _shadowOffset;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
}

@end
