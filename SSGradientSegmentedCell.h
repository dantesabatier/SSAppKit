//
//  SSGradientSegmentedCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSGradientSegmentedCell : NSSegmentedCell 

- (void)drawBackgroundWithFrame:(CGRect)cellFrame inView:(NSView *)controlView;
- (void)drawSegmentsWithFrame:(CGRect)cellFrame inView:(NSView *)controlView;
- (void)drawBackgroundForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView;
- (void)drawSelectionForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView;
- (void)drawImageForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView;
- (void)drawLabelForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView;
- (void)drawArrowMenuForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView;
- (NSDictionary *)labelAttributesForSegment:(NSInteger)segment;
- (NSGradient *)backgroundGradientForSegment:(NSInteger)segment;
@property (nullable, readonly) NSColor *borderColor;
@property (nullable, readonly) NSColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
