//
//  SSAnchoredButtonCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 8/24/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSAnchoredButtonCell.h"
#import "NSColor+SSAdditions.h"
#import "NSImage+SSAdditions.h"

@interface SSAnchoredButtonCell()

- (NSColor *)imageColor;
- (NSShadow *)contentShadow;
- (NSRect)highlightRectForBounds:(NSRect)bounds;

@end

@implementation SSAnchoredButtonCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setBordered:YES];
	}
	return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
	[super drawWithFrame:cellFrame inView:controlView];
	
	if (self.highlighted) {
		[[NSColor colorWithCalibratedWhite:0 alpha:0.35] set];
		NSRectFillUsingOperation([self highlightRectForBounds:cellFrame], NSCompositeSourceOver);
	}
}

- (void)drawBezelWithFrame:(NSRect)cellFrame inView:(NSView *)controlView 
{
	NSGradient * fillGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.992 alpha:1], (CGFloat)0.0, [NSColor colorWithCalibratedWhite:0.949 alpha:1], (CGFloat)0.45454, [NSColor colorWithCalibratedWhite:0.901 alpha:1], (CGFloat)0.45454, [NSColor colorWithCalibratedWhite:0.901 alpha:1], (CGFloat)1.0, nil] autorelease];
	
	[fillGradient drawInRect:cellFrame angle:90];
	
	[[NSColor colorWithCalibratedWhite:0 alpha:0.2] drawPixelThickLineAtPosition:0 withInset:0 inRect:cellFrame inView:controlView horizontal:NO flip:YES];
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] drawPixelThickLineAtPosition:1 withInset:1 inRect:cellFrame inView:controlView horizontal:NO flip:NO];
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] drawPixelThickLineAtPosition:1 withInset:1 inRect:cellFrame inView:controlView horizontal:NO flip:YES];
	[[NSColor colorWithCalibratedWhite:0.792 alpha:1] drawPixelThickLineAtPosition:0 withInset:0 inRect:cellFrame inView:controlView horizontal:YES flip:NO];
}

- (void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView 
{
	if ([[image name] isEqualToString:NSImageNameActionTemplate]) 
		image.size = NSMakeSize(10, 10);
	
	NSImage *newImage = image;
	if (image.isTemplate && !((self.showsStateBy == NSContentsCellMask) && (self.integerValue == 1))) {
		newImage = [image imageByTintingToColor:[self imageColor]];
		[newImage setTemplate:NO];
		[[self contentShadow] set];
	}
	
	[super drawImage:newImage withFrame:NSOffsetRect(frame, 0.0, 1.0) inView:controlView];
}

#pragma mark private methods

- (NSShadow *)contentShadow
{
	NSShadow *contentShadow = [[NSShadow alloc] init];
	contentShadow.shadowOffset = NSMakeSize(0, -1);
	contentShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.75];
	return [contentShadow autorelease];
}

- (NSColor *)imageColor 
{
	return self.isEnabled ? [NSColor colorWithCalibratedWhite:0.282 alpha:1] : [[NSColor colorWithCalibratedWhite:0.282 alpha:1] colorWithAlphaComponent:0.6];
}

- (NSRect)highlightRectForBounds:(NSRect)bounds 
{
	return bounds;
}

#pragma mark getters & setters

- (NSRect)titleRectForBounds:(NSRect)bounds 
{
	return NSOffsetRect([super titleRectForBounds:bounds], 0, 1);
}

- (NSColor *)textColor 
{
	return self.isEnabled ? [NSColor colorWithCalibratedWhite:0 alpha:1] : [[NSColor colorWithCalibratedWhite:0 alpha:1] colorWithAlphaComponent:0.6];
}

- (NSControlSize)controlSize 
{
	return NSSmallControlSize;
}

- (void)setControlSize:(NSControlSize)size 
{
	
}

@end
