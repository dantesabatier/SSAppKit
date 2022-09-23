//
//  SSSourceListCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSourceListCell.h"
#import "NSImage+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSTableView+SSAdditions.h"
#import <SSBase/SSDefines.h>

@implementation SSSourceListCell

- (id)copyWithZone:(NSZone *)zone {
    SSSourceListCell *cell = (SSSourceListCell *) [super copyWithZone:zone];
    cell->_image = [_image ss_retain];
	cell->_subtitle = [_subtitle ss_retain];
	cell->_badgeLabel = [_badgeLabel ss_retain];
    cell->_badgeColor = [_badgeColor ss_retain];
	
    return cell;
}

- (void)dealloc {
	[_image release];
	[_subtitle release];
	[_badgeLabel release];
    [_badgeColor release];
    
	[super ss_dealloc];
}

- (void)drawBadgeLabelWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
	CGRect badgeRect = [self badgeRectForBounds:cellFrame];
	if (NSIsEmptyRect(badgeRect))
        return;
	
	BOOL isActive = controlView.window.isActive;
	NSColor *textColor = [NSColor whiteColor];
	NSColor *badgeColor = self.badgeColor;
	if (isActive && self.isHighlighted) {
		if (!badgeColor) {
            if ([NSColor currentControlTint] == NSBlueControlTint) {
                textColor = [NSColor colorWithCalibratedRed:0.51 green:0.58 blue:0.72 alpha:0.9];
            } else {
                textColor = [NSColor colorWithCalibratedRed:0.58 green:0.64 blue:0.70 alpha:0.9];
            } 
        }
	} else {
        if (self.isHighlighted) {
            textColor = [NSColor disabledControlTextColor];
        }
	}
	
	if (self.isHighlighted) {
        if (!badgeColor) {
            badgeColor = [NSColor whiteColor];
        }
    } else {
        if (!isActive) {
            badgeColor = [NSColor disabledControlTextColor];
        } else {
            if (!badgeColor) {
                if ([NSColor currentControlTint] == NSBlueControlTint) {
                    badgeColor = [NSColor colorWithCalibratedRed:0.53 green:0.60 blue:0.74 alpha:0.9];
                } else {
                    badgeColor = [NSColor colorWithCalibratedRed:0.53 green:0.60 blue:0.66 alpha:0.9];
                }
            }
        }
	}
	
	NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    context.shouldAntialias = YES;
	
    NSString *badgeLabel = self.badgeLabel;
	NSDictionary *attributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:11.0], NSForegroundColorAttributeName: textColor};
    CGSize labelSize = [badgeLabel sizeWithAttributes:attributes];
    
    NSBezierPath *badgePath = [NSBezierPath bezierPathWithRoundedRect:badgeRect radius:(CGRectGetHeight(badgeRect)*(CGFloat)0.5)];
    
	[badgeColor setFill];
    [badgePath fill];
    
    CGRect labelRect = CGRectMake(FLOOR(NSMidX(badgeRect) - (labelSize.width*(CGFloat)0.5)), FLOOR(CGRectGetMidY(badgeRect) - (labelSize.height*(CGFloat)0.5)), labelSize.width, labelSize.height);
	
	[badgeLabel drawWithRect:labelRect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:attributes];
	
	[context restoreGraphicsState];
}

- (void)drawSubtitleWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    CGRect rect = [self subtitleRectForBounds:cellFrame];
    if (NSIsEmptyRect(rect))
        return;
    
    BOOL isActive = controlView.window.isActive;
    BOOL isFirstResponder = (isActive && controlView.window.firstResponder == controlView);
    NSColor *textColor = (self.isHighlighted && isFirstResponder) ? [NSColor whiteColor] : [NSColor grayColor];
    
    [self.subtitle drawWithRect:rect options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:10], NSForegroundColorAttributeName: textColor}];
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    NSImage *image = self.image;
	if (image) {
        NSColor *shadowColor = [NSColor whiteColor];
        NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0.392 green:0.443 blue:0.505 alpha:1.0];
        if (self.isHighlighted) {
            shadowColor = [NSColor colorWithCalibratedWhite:0 alpha:0.33];
            backgroundColor = [NSColor whiteColor];
        }
        
        CGFloat fraction = self.isEnabled ? 1.0 : 0.5;
        CGRect imageRect = [self imageRectForBounds:cellFrame];
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        context.imageInterpolation = NSImageInterpolationHigh;
        
        if (image.isTemplate)
            image = [image imageByTintingToColor:backgroundColor];
        
        NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
        imageShadow.shadowOffset = CGSizeMake(0.0, -1.0);
        imageShadow.shadowColor = shadowColor;
        [imageShadow set];
        
        [image drawInRect:imageRect fromRect:CGRectZero operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
        
        [context restoreGraphicsState];
	}
    
    [self drawSubtitleWithFrame:cellFrame inView:controlView];
	[self drawBadgeLabelWithFrame:cellFrame inView:controlView];
    [super drawWithFrame:cellFrame inView:controlView];
}

#if defined(__MAC_10_10)
- (NSCellHitResult)hitTestForEvent:(NSEvent *)event inRect:(CGRect)cellFrame ofView:(NSView *)controlView
#else
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(CGRect)cellFrame ofView:(NSView *)controlView
#endif 
{
    NSPoint point = [controlView convertPoint:event.locationInWindow fromView:nil];
    if (NSMouseInRect(point, [self titleRectForBounds:cellFrame], controlView.isFlipped))
        return NSCellHitContentArea | NSCellHitEditableTextArea;
    
    if (NSMouseInRect(point, [self imageRectForBounds:cellFrame], controlView.isFlipped))
        return NSCellHitContentArea;
	
    return NSCellHitNone;
}

#pragma mark getters & setters

- (CGRect)titleRectForBounds:(CGRect)bounds {
    if (self.wraps)
        return [super titleRectForBounds:bounds];
    
	NSString *subtitle = self.subtitle;
    CGRect titleRect = bounds;
	titleRect.origin.x = MAX(FLOOR(CGRectGetMaxX([self imageRectForBounds:bounds]) + 3.0), CGRectGetMinX(bounds));
    titleRect.size.height = FLOOR([self.stringValue sizeWithAttributes:@{NSFontAttributeName : self.font}].height + 2.0);
	titleRect.origin.y = !subtitle.length ? FLOOR(CGRectGetMidY(bounds) - (CGRectGetHeight(titleRect)*(CGFloat)0.5)) : CGRectGetMinY(bounds);
	titleRect.size.width = MIN(CGRectGetWidth(bounds), MAX((CGRectGetMaxX(bounds) - (CGRectGetWidth([self badgeRectForBounds:bounds])*(CGFloat)1.5)) - CGRectGetMinX(titleRect), 0.0));
	
    return titleRect;
}

- (CGRect)subtitleRectForBounds:(CGRect)bounds {
    if (self.wraps)
        return CGRectZero;
    
    NSString *subtitle = self.subtitle;
	if (!subtitle.length)
        return CGRectZero;
    
    CGRect titleRect = [self titleRectForBounds:bounds];
    CGRect subtitleRect = titleRect;
    subtitleRect.size.height = MAX(FLOOR(CGRectGetHeight(bounds) - CGRectGetHeight(titleRect) - 2.0), FLOOR([subtitle sizeWithAttributes:@{NSFontAttributeName : [NSFont systemFontOfSize:10]}].height + 2.0));
    subtitleRect.size.width -= 2.0;
    subtitleRect.origin.x += 2.0;
    subtitleRect.origin.y += CGRectGetHeight(titleRect);
    return subtitleRect;
}

- (CGRect)imageRectForBounds:(CGRect)bounds {
    NSImage *image = self.image;
    if (!image)
        return CGRectZero;
    
    CGSize proposedImageSize = NSZeroSize;
    if ([self.controlView isKindOfClass:[NSTableView class]])
        proposedImageSize = SSTableViewGetProposedCellImageSize((NSTableView *)self.controlView);
    else
        proposedImageSize = SSSizeMakeSquare(16.0);
#if 0
    CGSize imageSize = image.size;
    if (SSSizeIsLessThanSize(imageSize, proposedImageSize))
        proposedImageSize = imageSize;
#endif
    
    if (SSSizeIsEmpty(proposedImageSize))
        SSDebugLog(@"%@ %@, Warning!, about to return an empty image rect", self.class, NSStringFromSelector(_cmd));
    
    return CGRectMake(CGRectGetMinX(bounds), FLOOR(CGRectGetMidY(bounds) - (proposedImageSize.height *(CGFloat)0.5)), proposedImageSize.width, proposedImageSize.height);
}

- (CGRect)badgeRectForBounds:(CGRect)bounds {
    if (self.wraps)
        return CGRectZero;
    
	NSString *badgeLabel = self.badgeLabel;
	if (!badgeLabel.length)
        return CGRectZero;
	
	NSDictionary *attributes = @{NSFontAttributeName: [NSFont boldSystemFontOfSize:11.0]};
    CGSize labelSize = [badgeLabel sizeWithAttributes:attributes];
    CGSize badgeSize = labelSize;
    badgeSize.height = 14.0;
    badgeSize.width = MAX(FLOOR((badgeSize.width + 10.0)), 22.0);
    
    return CGRectMake(FLOOR(CGRectGetMaxX(bounds) - badgeSize.width), FLOOR(CGRectGetMidY(bounds) - (badgeSize.height*(CGFloat)0.5)), badgeSize.width, badgeSize.height);
}

- (NSImage *)image {
    return _image;
}

- (void)setImage:(NSImage *)image {
    SSAtomicRetainedSet(_image, image);
}

- (NSString *)subtitle {
    return _subtitle;
}

- (void)setSubtitle:(NSString *)subtitle {
	if ([self.subtitle isEqualToString:subtitle])
        return;
	
    SSAtomicCopiedSet(_subtitle, subtitle);
}

- (NSString *)badgeLabel {
    return _badgeLabel;
}

- (void)setBadgeLabel:(NSString *)badgeLabel {
	if ([self.badgeLabel isEqualToString:badgeLabel])
        return;
	
    SSAtomicCopiedSet(_badgeLabel, badgeLabel);
}

- (NSColor *)badgeColor {
    return _badgeColor;
}

- (void)setBadgeColor:(NSColor *)badgeColor {
    SSAtomicRetainedSet(_badgeColor, badgeColor);
}

- (CGSize)cellSize {
	CGFloat badgeWidth = 0;
	if (self.badgeLabel.length)
        badgeWidth = MAX([self.badgeLabel sizeWithAttributes:@{NSFontAttributeName: [NSFont systemFontOfSize:10]}].width + 10.0, 14.0) + 8.0;
	
    CGSize cellSize = super.cellSize;
    cellSize.width += ((self.image ? self.image.size.width : 0) + 3) + badgeWidth;
    return cellSize;
}

@end
