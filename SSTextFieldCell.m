//
//  SSTextFieldCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/12/13.
//
//

#import "SSTextFieldCell.h"
#import <SSBase/SSDefines.h>

@implementation SSTextFieldCell

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    [super drawWithFrame:[self titleRectForBounds:cellFrame] inView:controlView];
}

- (void)editWithFrame:(CGRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent*)theEvent {
	[super editWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(CGRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
	[super selectWithFrame:[self titleRectForBounds:aRect] inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (CGRect)titleRectForBounds:(CGRect)bounds {
    if (self.wraps)
        return [super titleRectForBounds:bounds];
    CGRect titleRect = bounds;
    titleRect.size.height = FLOOR([self.stringValue sizeWithAttributes:@{NSFontAttributeName : self.font}].height + 2.0);
    titleRect.origin.y = FLOOR(CGRectGetMidY(bounds) - (CGRectGetHeight(titleRect)*(CGFloat)0.5));
    return titleRect;
}

@end
