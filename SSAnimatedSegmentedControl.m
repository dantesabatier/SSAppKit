//
//  SSAnimatedSegmentedControl.m
//  SSAppKit
//
//  Created by Dante Sabatier on 10/19/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSAnimatedSegmentedControl.h"
#import "SSGradientSegmentedCell.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>

@interface SSAnimatedSegmentedCell : SSGradientSegmentedCell 

@end

@implementation SSAnimatedSegmentedCell

- (void)drawBackgroundWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    
}

- (void)drawSegmentsWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    
}

- (void)drawSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
	[self drawImageForSegment:segment inFrame:frame withView:controlView];
	[self drawLabelForSegment:segment inFrame:frame withView:controlView];
	[self drawArrowMenuForSegment:segment inFrame:frame withView:controlView];
}

- (void)drawImageForSegment:(NSInteger)segment inFrame:(CGRect)frame withView:(NSView *)controlView {
    NSImage *image = [self imageForSegment:segment];
    if (!image)
        return;
	
    NSColor *tintColor = [NSColor whiteColor];
    NSColor *shadowColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.33];
    if ([self isSelectedForSegment:segment]) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            tintColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
        } else {
            tintColor = [NSColor blackColor];
        }
            
        shadowColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.9];
    }
    
    image = [image imageByTintingToColor:tintColor];
    
    [NSGraphicsContext saveGraphicsState];
    
	NSShadow *imageShadow = [[[NSShadow alloc] init] autorelease];
    imageShadow.shadowColor = shadowColor;
    imageShadow.shadowOffset = CGSizeMake(0, -1.0);
    imageShadow.shadowBlurRadius = 1.0;
	[imageShadow set];
	
	CGRect imageRect = CGRectIntegral(SSRectCenteredSize(frame, image.size));
	CGRect fromRect = CGRectZero;
	fromRect.size = image.size;
    
    CGFloat fraction = [self isEnabledForSegment:segment] && controlView.window.isActive ? 1.0 : 0.5;
    [image drawInRect:imageRect fromRect:fromRect operation:NSCompositeSourceOver fraction:fraction respectFlipped:YES hints:nil];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSDictionary *)labelAttributesForSegment:(NSInteger)segment {
    BOOL selected = [self isSelectedForSegment:segment];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = selected ? [NSColor whiteColor] : [NSColor colorWithCalibratedWhite:0.0 alpha:0.33];
    shadow.shadowOffset = CGSizeMake(0, -1.0);
    shadow.shadowBlurRadius = 1.0;
    
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	attrs[NSForegroundColorAttributeName] = selected ? [NSColor colorWithCalibratedRed:0.16 green:0.17 blue:0.18 alpha:0.91] : [NSColor whiteColor];
    attrs[NSFontAttributeName] = self.font;//[NSFont fontWithName:self.font.fontName size:[NSFont systemFontSizeForControlSize:self.controlSize]];
	attrs[NSShadowAttributeName] = shadow;
	
	[shadow release];
	
	return attrs;
}

@end

@interface SSKnobAnimation : NSAnimation {
    NSInteger start, range;
}

@end

@implementation SSKnobAnimation

- (instancetype)initWithStart:(NSInteger)begin end:(NSInteger)end {
	self = [super init];
	if (self) {
		start = begin;
		range = end - begin;
	}
	return self;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress {
    NSInteger x = start + progress * range;
	super.currentProgress = progress;
    [self.delegate performSelector:@selector(setPosition:) withObject:@(x)];
}

@end

@interface SSAnimatedSegmentedControl() {
    CGFloat _offset;
    BOOL _tracking;
}

- (void)drawBackgroud:(CGRect)rect;
- (void)drawKnob:(CGRect)rect;
- (void)animateTo:(NSInteger)x;
- (void)setPosition:(NSNumber *)x;
- (void)offsetLocationByX:(CGFloat)x;

@end

@implementation SSAnimatedSegmentedControl

+ (Class)cellClass {
	return [SSAnimatedSegmentedCell class];
}

- (void)prepareForInterfaceBuilder {
    self.cell = [[[SSAnimatedSegmentedCell alloc] init] autorelease];
}

- (void)drawRect:(CGRect)dirtyRect { 
	[NSGraphicsContext saveGraphicsState];
	
	CGRect bounds = self.bounds;
	
    [self drawBackgroud:bounds];
	
	CGRect knobRect = bounds;
	knobRect.size.width = bounds.size.width / self.segmentCount;
	knobRect.origin.x = _offset;
    
    if (!_tracking) {
        CGRect segmentRect = bounds;
        segmentRect.size.width = bounds.size.width/self.segmentCount;
        for (NSInteger segment = 0; segment < self.segmentCount; segment++) {
            if (segment == self.selectedSegment) {
                break;
            }
            
            segmentRect.origin.x += CGRectGetWidth(segmentRect);
        }
        
        if (!NSContainsRect(segmentRect, knobRect)) {
            knobRect.origin.x = segmentRect.origin.x;
            
            _offset = knobRect.origin.x;
        } 
    }
		
    [self drawKnob:NSInsetRect(CGRectIntegral(knobRect), 1.0, 1.0)];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawBackgroud:(CGRect)rect {
    CGRect bounds = CGRectInset(rect, 1.0, 1.0);
    bounds.size.height -= 1.0;
    
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef space = SSColorSpaceGetDeviceRGB();
    CGPathRef path = SSPathCreateWithRoundedRect(bounds, 3.0, NULL);
    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            const CGFloat dropShadowComponents[] = {0.91, 0.91, 0.91, 0.8};
            CGColorRef dropShadowColor = CGColorCreate(space, dropShadowComponents);
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, dropShadowColor);
			CGColorRelease(dropShadowColor);
            
            CGContextBeginTransparencyLayer(ctx, NULL);
            {
                CGContextAddPath(ctx, path);
                CGContextClip(ctx);
                
                CGColorRef backgroundColor = CGColorCreate(space, (const CGFloat[]){0.1176, 0.1176, 0.1176, 0.70});
                CGGradientRef backgroundGradient = CGGradientCreateWithColorComponents(space, (const CGFloat[]){0.670, 0.670, 0.670, 0.33, 1.0, 1.0, 1.0, 0.33}, (const CGFloat[]){0, 1}, 2);
                CGContextSaveGState(ctx);
                {
                    CGContextSetFillColorWithColor(ctx, backgroundColor);
                    CGContextFillRect(ctx, boundingBox);
                    SSContextDrawLinearGradient(ctx, backgroundGradient, boundingBox, 90);
                }
                CGContextRestoreGState(ctx);
                CGColorRelease(backgroundColor);
                CGGradientRelease(backgroundGradient);
            }
            CGContextEndTransparencyLayer(ctx);
        }
        CGContextRestoreGState(ctx);
        
        const CGFloat innerShadowComponents[] = {0.0, 0.0, 0.0, 0.9};
        CGColorRef innerShadowColor = CGColorCreate(space, innerShadowComponents);
		
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, CGSizeMake(0, -1.0), CGRectGetHeight(boundingBox)*0.25);
        }
        CGContextRestoreGState(ctx);
        CGColorRelease(innerShadowColor);
    }
    CGContextRestoreGState(ctx);
    
    CGPathRelease(path);
    
#if 1
    CGRect segmentRect = bounds;
	segmentRect.size.width = bounds.size.width/self.segmentCount;
    for (NSInteger segment = 0; segment < self.segmentCount; segment ++) {
        if (![self isSelectedForSegment:segment]) {
            [self.cell drawSegment:segment inFrame:CGRectIntegral(segmentRect) withView:self];
        }
        
        segmentRect.origin.x += segmentRect.size.width;
    }
#endif
}

- (void)drawKnob:(CGRect)rect {
    CGRect bounds = CGRectInset(rect, 1.0, 1.0);
    bounds.size.height -= 1.0;
    
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef space = SSColorSpaceGetDeviceRGB();
	CGPathRef path = SSPathCreateWithRoundedRect(bounds, 2.5, NULL);
    
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat strokeComponents[] = {0.16, 0.16, 0.16, 0.3};
            CGColorRef strokeColor = CGColorCreate(space, strokeComponents);
            CGContextSetStrokeColorWithColor(ctx, strokeColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(strokeColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextAddPath(ctx, path);
        CGContextClip(ctx);
        
        CGRect knobBoundingBox = CGPathGetBoundingBox(path);
        CGPoint startPoint = CGPointZero;
        CGPoint endPoint = CGPointMake(0, CGRectGetMaxY(knobBoundingBox));
        
        if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_6) {
            SWAP(startPoint, endPoint);
        }
        
        CGGradientRef gradient = NULL;
        if (self.window.isActive) {
            switch (self.segmentStyle) {
                case NSSegmentStyleTexturedSquare:
                    gradient = SSAutorelease(CGGradientCreateWithColorComponents(space, (const CGFloat[]){0.933, 0.933, 0.933, 1.0, 0.886, 0.886, 0.886, 1.0, 0.729, 0.729, 0.729, 1.0, 0.627, 0.627, 0.627, 1.0}, (const CGFloat[]){0.0, 0.3, 0.6, 1.0}, 4));
                    break;
                default:
                    gradient = SSAutorelease(CGGradientCreateWithColorComponents(space, (const CGFloat[]){0.988235, 0.988235, 0.988235, 1.0, 0.988235, 0.988235, 0.988235, 1.0, 0.980392, 0.980392, 0.980392, 1.0, 0.901961, 0.901961, 0.901961, 1.0}, (const CGFloat[]){0.0, 0.3, 0.6, 1.0}, 4));
                    break;
            }
            
        } else {
            gradient = SSAutorelease(CGGradientCreateWithColorComponents(space, (const CGFloat[]){0.965, 0.965, 0.965, 1.0, 0.855, 0.855, 0.855, 1.0}, (const CGFloat[]){0.0, 1.0}, 2));
        }
        CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat glowComponents[4] = {0.92, 0.92, 0.92, 0.16};
            CGColorRef glowColor = CGColorCreate(space, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0f);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, path);
            const CGFloat innerShadowComponents[4] = {0.92, 0.92, 0.92, 0.86};
            CGColorRef innerShadowColor = CGColorCreate(space, innerShadowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, path, innerShadowColor, CGSizeMake(0, -1), 0);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
	CGPathRelease(path);
    
#if 0
    [self.cell drawSegment:(NSInteger)ROUND(_offset / CGRectGetWidth(bounds)) inFrame:bounds withView:self];
#endif
}

- (void)animateTo:(NSInteger)x {
    SSKnobAnimation *animation = [[SSKnobAnimation alloc] initWithStart:_offset end:x];
	animation.delegate = (id)self;
	animation.duration = 0.15;
	animation.animationCurve = NSAnimationEaseInOut;
	animation.animationBlockingMode = NSAnimationBlocking;
    [animation startAnimation];
    [animation release];
}

- (void)setPosition:(NSNumber *)x {
    _offset = x.intValue;
	
    [self display];
}

- (void)setSelectedSegment:(NSInteger)selectedSegment {
    [self setSelectedSegment:selectedSegment animate:YES];
}

- (void)setSelectedSegment:(NSInteger)selectedSegment animate:(BOOL)animate {
    if (selectedSegment == self.selectedSegment)
        return;
    
    CGFloat maxX = self.frame.size.width - (self.frame.size.width / self.segmentCount);
    NSInteger x = selectedSegment > self.segmentCount ? maxX : selectedSegment * (self.frame.size.width / self.segmentCount);
    
    if (animate)
        [self animateTo:x];
    else [self setNeedsDisplay];
	
    super.selectedSegment = selectedSegment;
	
	[self sendAction:self.action to:self.target];
}

- (void)offsetLocationByX:(CGFloat)x {
    _offset = _offset + x;
	
    CGFloat maxX = self.frame.size.width - (self.frame.size.width / self.segmentCount);
    
    if (_offset < 0)
        _offset = 0;
    if (_offset > maxX)
        _offset = maxX;
    
    [self setNeedsDisplay];
}

- (void)mouseDown:(NSEvent *)event {
    _tracking = YES;
    
    NSPoint clickLocation = [self convertPoint:event.locationInWindow fromView:nil];
    CGFloat knobWidth = self.frame.size.width / self.segmentCount;
    CGRect knobRect = CGRectMake(_offset, 0, knobWidth, self.frame.size.height);
    
    if (NSPointInRect(clickLocation, self.bounds)) {
        NSPoint newDragLocation;
        NSPoint localLastDragLocation;
        localLastDragLocation = clickLocation;
        
        while (_tracking) {
            NSEvent *localEvent;
            localEvent = [self.window nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
            
            switch (localEvent.type) {
                case NSLeftMouseDragged: {
					if (NSPointInRect(clickLocation, knobRect)) {
                        newDragLocation = [self convertPoint:localEvent.locationInWindow fromView:nil];
                        
                        [self offsetLocationByX:(newDragLocation.x - localLastDragLocation.x)];
                        
                        localLastDragLocation = newDragLocation;
                        [self autoscroll:localEvent];
                    }
				}
                    break;
                case NSLeftMouseUp: {
                    NSInteger newSegment;
                    if (memcmp(&clickLocation, &localLastDragLocation, sizeof(NSPoint)) == 0) {
                        newSegment = (NSInteger)FLOOR(clickLocation.x / knobWidth);
                    } else {
                        newSegment = (NSInteger)ROUND(_offset / knobWidth);
                    }
					
                    [self animateTo:newSegment * knobWidth];
                    self.selectedSegment = newSegment;
                    [self.window invalidateCursorRectsForView:self];
                    
                    _tracking = NO;
				}
                    break;
                default:
                    break;
            }
        }
    };
    return;
}

@end
