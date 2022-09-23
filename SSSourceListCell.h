//
//  SSSourceListCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTextFieldCell.h"
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSSourceListCell : SSTextFieldCell {
@package
    NSImage *_image;
    NSString *_subtitle;
    NSString *_badgeLabel;
    NSColor *_badgeColor;
}

@property (nullable, strong) NSImage *image;
@property (nullable, copy) NSString *subtitle;
@property (nullable, copy) NSString *badgeLabel;
@property (nullable, strong) NSColor *badgeColor;

- (void)drawSubtitleWithFrame:(CGRect)cellFrame inView:(NSView *)controlView;
- (void)drawBadgeLabelWithFrame:(CGRect)cellFrame inView:(NSView *)controlView;
- (CGRect)subtitleRectForBounds:(CGRect)bounds;
- (CGRect)badgeRectForBounds:(CGRect)bounds;

@end

NS_ASSUME_NONNULL_END
