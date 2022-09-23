//
//  SSRubberBandView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 08/01/19.
//

#import "SSRubberBandView.h"

@implementation SSRubberBandView

- (void)drawRect:(CGRect)rect {
    if (NSIsEmptyRect(_selectionRect))
        return;
    
    [NSGraphicsContext saveGraphicsState];
    NSColor *selectionColor = [NSColor whiteColor];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:_selectionRect];
    path.lineWidth = 1.3;
    [NSBezierPath clipRect:_selectionRect];
    [[selectionColor colorWithAlphaComponent:0.33] setFill];
    [path fill];
    [selectionColor setStroke];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
}

- (CGRect)selectionRect {
    return _selectionRect;
}

- (void)setSelectionRect:(CGRect)selectionRect {
    if (NSEqualRects(_selectionRect, selectionRect))
        return;
    
    _selectionRect = selectionRect;
    
    self.needsDisplay = YES;
}

- (NSInteger)tag {
    return _tag;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag;
}

- (BOOL)isOpaque {
    return NO;
}

- (BOOL)isFlipped {
    return YES;
}

@end
