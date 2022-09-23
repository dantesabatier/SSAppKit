//
//  SSCollectionItemView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 10/08/12.
//
//

#import "SSCollectionItemView.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import <SSGraphics/SSColor.h>
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSPath.h>

@implementation SSCollectionItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_selectionColor release];
    
    [super ss_dealloc];
}

- (void)drawRect:(CGRect)dirtyRect {
    if (_selected) {
        CGFloat scale = self.scale;
        CGFloat borderWidth = 1.0*scale;
        CGContextRef ctx = SSContextGetCurrent();
        CGPathRef path = CGPathCreateWithRect(CGRectIntegral(CGRectInset(self.bounds, borderWidth, borderWidth)), NULL);
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            CGContextClip(ctx);
            CGColorRef selectionColor = SSColorGetCGColor(self.selectionColor);
            BOOL isActive = YES;
            BOOL needsDisplayWhenWindowResignsKey = YES;
            BOOL allowsVibrancy = NO;
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
            isActive = self.window.isActive;
            needsDisplayWhenWindowResignsKey = self.needsDisplayWhenWindowResignsKey;
#if defined(__MAC_10_10)
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                allowsVibrancy = self.effectiveAppearance.allowsVibrancy;
            }
#endif
#endif
            if ((needsDisplayWhenWindowResignsKey && !isActive) || (allowsVibrancy && !isActive)) {
                selectionColor = [NSColor secondarySelectedControlColor].CGColor;
            }

            CGColorRef fillColor = CGColorCreateCopyWithAlpha(selectionColor, 0.33);
            CGContextSetFillColorWithColor(ctx, fillColor);
            CGContextFillRect(ctx, CGPathGetBoundingBox(path));
            CGColorRelease(fillColor);
            
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, path);
                CGContextSetStrokeColorWithColor(ctx, selectionColor);
                CGContextSetLineWidth(ctx, borderWidth);
                CGContextStrokePath(ctx);
            }
            CGContextRestoreGState(ctx);
        }
        CGContextRestoreGState(ctx);
        CGPathRelease(path);
    }
}

#pragma mark getters & setters

- (BOOL)isSelected {
    return _selected;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.needsDisplay = YES;
}

- (NSColor *)selectionColor {
    if (!_selectionColor) {
        _selectionColor = [[NSColor alternateSelectedControlColor] copy];
    }
    return _selectionColor;
}

- (void)setSelectionColor:(NSColor *)selectionColor {
    SSNonAtomicCopiedSet(_selectionColor, selectionColor);
    self.needsDisplay = YES;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
