//
//  SSStyledView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSStyledView : NSView {
@package
    NSMutableDictionary *_colorEdges;
    SSRectCorner _rectCorners;
    NSInteger _tag;
    NSImage *_backgroundImage;
    NSColor *_backgroundColor;
    NSGradient *_backgroundGradient;
    NSGradient *_alternateBackgroundGradient;
    CGFloat _gradientAngle;
    CGFloat _cornerRadius;
}

@property (nullable, nonatomic, strong) NSImage *backgroundImage;
@property (nullable, nonatomic, strong) NSColor *backgroundColor;
@property (nullable, nonatomic, strong) NSGradient *backgroundGradient;
@property (nullable, nonatomic, strong) NSGradient *alternateBackgroundGradient;
@property (nonatomic, assign) CGFloat gradientAngle;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) SSRectCorner rectCorners;

- (nullable NSColor *)borderColorForEdge:(NSRectEdge)edge;
- (void)setBorderColor:(nullable NSColor *)color forEdge:(NSRectEdge)edge;
- (nullable NSColor *)insetColorForEdge:(NSRectEdge)edge;
- (void)setInsetColor:(nullable NSColor *)color forEdge:(NSRectEdge)edge;

@end

NS_ASSUME_NONNULL_END
