//
//  SSHoverViewSeparatorView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 15/12/16.
//
//

#import "SSHoverViewSeparatorView.h"
#import "UIView+SSAdditions.h"

@implementation SSHoverViewSeparatorView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [_viewsToSeparate release];
    [_separatorColor release];
    
    [super ss_dealloc];
}

- (NSInteger)orientation {
    return _orientation;
}

- (void)setOrientation:(NSInteger)orientation {
    if (orientation == _orientation) {
        return;
    }
    
    _orientation = orientation;
    [self setNeedsDisplay];
}

- (nullable UIColor *)separatorColor {
    return _separatorColor;
}

- (void)setSeparatorColor:(nullable UIColor *)separatorColor {
    if (separatorColor == _separatorColor) {
        return;
    }
    
    SSNonAtomicCopiedSet(_separatorColor, separatorColor);
    [self setNeedsDisplay];
}

- (CGFloat)separatorWidth {
    return _separatorWidth;
}

- (void)setSeparatorWidth:(CGFloat)separatorWidth {
    if (separatorWidth == _separatorWidth) {
        return;
    }
    
    _separatorWidth = separatorWidth;
    [self setNeedsDisplay];
}

- (nullable NSArray<UIView *> *)viewsToSeparate {
    return _viewsToSeparate;
}

- (void)setViewsToSeparate:(nullable NSArray<UIView *> *)viewsToSeparate {
    if (_viewsToSeparate == viewsToSeparate) {
        return;
    }
    
    SSNonAtomicCopiedSet(_viewsToSeparate, viewsToSeparate);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.separatorWidth || !self.separatorColor) {
        return;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self.separatorColor setStroke];
    CGContextSetLineWidth(ctx, self.separatorWidth);
    
    CGFloat xMax = CGRectGetWidth(rect);
    CGFloat yMax = CGRectGetHeight(rect);
    // offset separator position by half the separator width to draw on physical pixels
    // if the separator width is below 1pt
    CGFloat separatorOffset = self.separatorWidth < 1 ? self.separatorWidth / 2.0 : 0;
    
    for (UIView *view in self.viewsToSeparate) {
        if (view == self.viewsToSeparate.lastObject) {
            // no separator after last view
            break;
        }
        
        // draw separator after view
        // Convert frame to this coordinate space
        CGRect viewFrame = [view convertRect:view.bounds toView:self];
        CGPoint from, to;
        
        switch (self.orientation) {
            case 0: {
                CGFloat y = CGRectGetMaxY(viewFrame) + separatorOffset;
                from = CGPointMake(0, y);
                to = CGPointMake(xMax, y);
            }
                break;
            default: {
                CGFloat x = CGRectGetMaxX(viewFrame) + separatorOffset;
                from = CGPointMake(x, 0);
                to = CGPointMake(x, yMax);
            }
                break;
        }
        
        CGContextMoveToPoint(ctx, from.x, from.y);
        CGContextAddLineToPoint(ctx, to.x, to.y);
        CGContextStrokePath(ctx);
    }
}

@end
