//
//  SSSearchFieldCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/08/12.
//  Copyright (c) 2012 Tío. All rights reserved.
//

#import "SSSearchFieldCell.h"
#import "NSSearchFieldCell+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSPath.h>
#import <SSGraphics/SSUtilities.h>

@implementation SSSearchFieldCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.drawsBackground = NO;
        self.focusRingType = NSFocusRingTypeNone;
        self.textColor = self.textColor;
    }
    return self;
}

- (instancetype)initTextCell:(NSString *)aString {
    self = [super initTextCell:aString];
    if (self) {
        self.drawsBackground = NO;
        self.focusRingType = NSFocusRingTypeNone;
        self.textColor = self.textColor;
    }
    return self;
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
    NSColor *textColor = self.textColor;
    NSTextView *fieldEditor = (NSTextView *) [super setUpFieldEditorAttributes:textObj];
    fieldEditor.insertionPointColor = textColor;
    fieldEditor.textColor = textColor;
    fieldEditor.drawsBackground = NO;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:fieldEditor.selectedTextAttributes];
    attributes[NSBackgroundColorAttributeName] = [[self.textColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] colorWithAlphaComponent:0.150];
    
    fieldEditor.selectedTextAttributes = attributes;
    
    return fieldEditor;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    CGContextRef ctx = SSContextGetCurrent();
    if (!self.isEnabled)
        CGContextSetAlpha(ctx, 0.5);
    
    CGRect bounds = cellFrame;
    if (self.isBezeled) {
        bounds.origin.y += 1.0;
        bounds.size.height -= 2.0;
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGPathRef path = SSPathCreateWithRoundedRect(bounds, MIN(bounds.size.width, bounds.size.height)*(CGFloat)0.5, NULL);
        
        CGContextSaveGState(ctx);
        {
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                CGContextClip(ctx);
                
                const CGFloat dropShadowComponents[4] = {0.91, 0.91, 0.91, 0.33};
                CGColorRef dropShadowColor = CGColorCreate(colorSpace, dropShadowComponents);
                const CGFloat backgroundColorComponents[4] = {0.0, 0.0, 0.0, 0.150};
                CGColorRef backgroundColor = CGColorCreate(colorSpace, backgroundColorComponents);
                
                CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, dropShadowColor);
                CGContextSetFillColorWithColor(ctx, backgroundColor);
                CGContextFillRect(ctx, bounds);
                
                CGColorRelease(backgroundColor);
                CGColorRelease(dropShadowColor);
            }
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                const CGFloat innerShadowComponents[4] = {0, 0, 0, 1.0};
                CGColorRef holderInnerShadowColor = CGColorCreate(colorSpace, innerShadowComponents); 
                SSContextDrawInnerShadowWithColor(ctx, path, holderInnerShadowColor, CGSizeMake(0, -1), 3);
                CGColorRelease(holderInnerShadowColor);
            }
            CGContextRestoreGState(ctx);
        }
        CGContextRestoreGState(ctx);
        CGPathRelease(path);
        CGColorSpaceRelease(colorSpace);
    }
    
    [self drawInteriorWithFrame:bounds inView:controlView];
}

- (void)setTextColor:(NSColor *)color {
    super.textColor = color;
    
    self.searchButtonCell.image = self.searchButtonCellImage;
    self.cancelButtonCell.image = self.cancelButtonCellImage;
    self.searchButtonCell.alternateImage = self.searchButtonCell.image;
    self.cancelButtonCell.alternateImage = self.cancelButtonCell.image;
}

- (void)setPlaceholderString:(NSString *)string {
    super.placeholderAttributedString = [[[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: [[self.textColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] shadowWithLevel:0.16]}] autorelease];
}

@end
