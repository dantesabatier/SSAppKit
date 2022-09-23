//
//  Scroller.h
//  Massive Mail
//
//  Created by Dante Sabatier on 18/01/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSGradientScroller : NSScroller {
@private
    NSGradient *_knobSlotGradient;
    NSGradient *_activeKnobGradient;
    NSGradient *_inactiveKnobGradient;
    NSGradient *_activeButtonGradient;
    NSGradient *_highlightButtonGradient;
    NSGradient *_inactiveButtonGradient;
    NSGradient *_activeArrowGradient;
    NSGradient *_inactiveArrowGradient;
    NSColor *_activeKnobOutlineColor;
    NSColor *_inactiveKnobOutlineColor;
    NSColor *_activeLineColor;
    NSColor *_highlightLineColor;
    NSColor *_inactiveLineColor;
}

@property (nullable, nonatomic, strong) NSGradient *knobSlotGradient;
@property (nullable, nonatomic, strong) NSGradient *activeKnobGradient;
@property (nullable, nonatomic, strong) NSGradient *inactiveKnobGradient;
@property (nullable, nonatomic, strong) NSGradient *activeButtonGradient;
@property (nullable, nonatomic, strong) NSGradient *highlightButtonGradient;
@property (nullable, nonatomic, strong) NSGradient *inactiveButtonGradient;
@property (nullable, nonatomic, strong) NSGradient *activeArrowGradient;
@property (nullable, nonatomic, strong) NSGradient *inactiveArrowGradient;
@property (nullable, nonatomic, strong) NSColor *activeKnobOutlineColor;
@property (nullable, nonatomic, strong) NSColor *inactiveKnobOutlineColor;
@property (nullable, nonatomic, strong) NSColor *activeLineColor;
@property (nullable, nonatomic, strong) NSColor *highlightLineColor;
@property (nullable, nonatomic, strong) NSColor *inactiveLineColor;

@end

NS_ASSUME_NONNULL_END
