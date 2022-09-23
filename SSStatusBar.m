//
//  SSStatusBar.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSStatusBar.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "SSAppKitUtilities.h"

@interface SSStatusBar ()

@end

@implementation SSStatusBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _cornerRadius = 4.0;
        _rectCorners = SSRectBottomCorners;
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            _backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.81176471 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.86666667 alpha:1.0]];
            _alternateBackgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.87843137254902 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.95686274509804 alpha:1.0]];
            [self setBorderColor:[NSColor colorWithCalibratedWhite:0.56862745098039 alpha:1.0] forEdge:NSMaxYEdge];
        } else {
            _backgroundImage = [SSAppKitGetImageResourceNamed(@"backgroundPattern") copy];
            _backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.513726 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.780392 alpha:1.0]];
            _alternateBackgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85098 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.929412 alpha:1.0]];
            [self setBorderColor:[NSColor colorWithCalibratedWhite:0.43137254901961 alpha:1.0] forEdge:NSMaxYEdge];
        }
        
        [self setInsetColor:[NSColor colorWithCalibratedWhite:0.85882352941176 alpha:1.0] forEdge:NSMaxYEdge];
    }
    return self;
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    _cornerRadius = 4.0;
    _rectCorners = SSRectBottomCorners;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        _backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.81176471 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.86666667 alpha:1.0]];
        _alternateBackgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.87843137254902 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.95686274509804 alpha:1.0]];
        [self setBorderColor:[NSColor colorWithCalibratedWhite:0.56862745098039 alpha:1.0] forEdge:NSMaxYEdge];
    } else {
        _backgroundImage = [SSAppKitGetImageResourceNamed(@"backgroundPattern") copy];
        _backgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.513726 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.780392 alpha:1.0]];
        _alternateBackgroundGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85098 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.929412 alpha:1.0]];
        [self setBorderColor:[NSColor colorWithCalibratedWhite:0.43137254901961 alpha:1.0] forEdge:NSMaxYEdge];
    }
    
    [self setInsetColor:[NSColor colorWithCalibratedWhite:0.85882352941176 alpha:1.0] forEdge:NSMaxYEdge];
}

#endif

- (NSColor *)borderColorForEdge:(NSRectEdge)edge {
    NSColor *color = [super borderColorForEdge:edge];
    if (color && !self.window.isActive && self.needsDisplayWhenWindowResignsKey) {
        color = [NSColor colorWithCalibratedWhite:0.65490196078431 alpha:1.0];
    }
    return color;
}

- (NSColor *)insetColorForEdge:(NSRectEdge)edge {
    NSColor *color = [super insetColorForEdge:edge];
    if (color && !self.window.isActive && self.needsDisplayWhenWindowResignsKey) {
        color = [NSColor colorWithCalibratedWhite:0.90588235294118 alpha:1.0];
    }
    return color;
}

@end
