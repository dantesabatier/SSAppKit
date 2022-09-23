//
//  NSSplitView+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 30/01/17.
//
//

#import "NSView+SSAdditions.h"

@interface NSSplitView (SSAdditions)

//@property (readwrite, copy) NSColor *dividerColor;
- (void)setDividerColor:(NSColor *)dividerColor;
- (void)toogleSubview:(__kindof NSView *)subview animated:(BOOL)animated;

@end
