//
//  SSDarkTextFieldCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 28/07/12.
//
//

#import "SSDarkTextFieldCell.h"
#import "NSBezierPath+SSAdditions.h"
#import <SSGraphics/SSUtilities.h>

@implementation SSDarkTextFieldCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.textColor = [NSColor whiteColor];
        self.drawsBackground = NO;
        self.focusRingType = NSFocusRingTypeNone;
    }
    return self;
}

- (instancetype)initTextCell:(NSString *)aString
{
    self = [super initTextCell:aString];
    if (self) {
        self.textColor = [NSColor whiteColor];
        self.drawsBackground = NO;
        self.focusRingType = NSFocusRingTypeNone;
    }
    return self;
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
    NSColor *textColor = self.textColor;
    NSTextView *fieldEditor = (NSTextView *) [super setUpFieldEditorAttributes:textObj];
    fieldEditor.insertionPointColor = textColor;
    fieldEditor.textColor = textColor;
    fieldEditor.drawsBackground = NO;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:fieldEditor.selectedTextAttributes];
    attributes[NSBackgroundColorAttributeName] = [self.textColor colorWithAlphaComponent:0.150];
    
    fieldEditor.selectedTextAttributes = attributes;
    
    return fieldEditor;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    CGContextRef ctx = SSGraphicsGetCurrentContext();
    if (!self.isEnabled)
        CGContextSetAlpha(ctx, 0.5);
    
    NSRect backgroundRect = cellFrame;
    if (self.isBezeled) {
        backgroundRect.size.height -= 1.0;
        
        NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRect:backgroundRect];
        [[NSColor colorWithCalibratedWhite:0.000 alpha:0.150] set];
        [backgroundPath fill];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.000 alpha:0.300];
        shadow.shadowOffset = CGSizeZero;
        shadow.shadowBlurRadius = 3.0;
        
        [backgroundPath applyInnerShadow:shadow];
        
        NSRect innerShadowRect = NSInsetRect(backgroundRect, -2.0, 0.0);
        innerShadowRect.size.height *= 2.f;
        NSBezierPath *shadowPath = [NSBezierPath bezierPathWithRect:innerShadowRect];
        
        [shadowPath applyInnerShadow:shadow];
        
        NSRect dropShadowRect = backgroundRect;
        dropShadowRect.origin.y = NSMaxY(cellFrame) - 1.0;
        
        [[NSColor colorWithCalibratedWhite:1.000 alpha:0.100] set];
        [NSBezierPath fillRect:dropShadowRect];
    }
    
    [self drawInteriorWithFrame:backgroundRect inView:controlView];
}

@end
