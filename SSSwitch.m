//
//  SSSwitch.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSwitch.h"
#import "SSGradientButtonCell.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "SSAppKitUtilities.h"
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSString.h>
#import <SSGraphics/SSUtilities.h>

static char _SSSwitchValueObservationContext;

static NSString *const SSSwitchOffsetAnimationKey = @"offset";

@interface SSSwitch (Private)

- (void)_drawKnobInSlotRect:(CGRect)bounds radius:(CGFloat)radius;

@end

@implementation SSSwitch

+ (void)initialize {
	[self exposeBinding:NSValueBinding];
}

+ (id)defaultAnimationForKey:(NSString *)key {
	if ([key isEqualToString:SSSwitchOffsetAnimationKey]) {
		CABasicAnimation *animation = [CABasicAnimation animation];
        animation.duration = 0.15;
		return animation;
	}
    return [super defaultAnimationForKey:key];
}

+ (Class)cellClass {
	return [SSGradientButtonCell class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.bezelStyle = NSRoundedBezelStyle;
        } else {
            self.bezelStyle = NSTexturedSquareBezelStyle;
        }  
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        if (!self.cell) {
            self.cell = [[[self.class.cellClass alloc] init] autorelease];
        }
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.bezelStyle = NSRoundedBezelStyle;
        } else {
            self.bezelStyle = NSTexturedSquareBezelStyle;
        }
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_title release];
	[_alternateTitle release];

	[super ss_dealloc];
}

- (void)prepareForInterfaceBuilder {
    SSGradientButtonCell *cell = [[[SSGradientButtonCell alloc] init] autorelease];
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        cell.bezelStyle = NSRoundedBezelStyle;
    } else {
        cell.bezelStyle = NSTexturedSquareBezelStyle;
    }
    self.cell = cell;
}

NS_INLINE CGRect _SSGetSwitchInsetTextRect(CGRect textRect) {
	return NSInsetRect(textRect, 0, CGRectGetHeight(textRect)/7.0);
}

NS_INLINE void _SSSwitchGetPartRects(SSSwitch *self, CGRect bounds, CGRect *textRects, CGRect *backgroundRect) {
    textRects[1] = CGRectZero;
    textRects[0] = CGRectZero;
    *backgroundRect = bounds;
    
    if (self.title || self.alternateTitle) {
        NSDivideRect(bounds, textRects, backgroundRect, CGRectGetWidth(bounds)*(CGFloat)0.275, NSMinXEdge);
        textRects[1] = _SSGetSwitchInsetTextRect(NSOffsetRect(textRects[0], CGRectGetWidth(*backgroundRect), 0));
        textRects[0] = _SSGetSwitchInsetTextRect(textRects[0]);
    }
    
    (*backgroundRect).size.width -= CGRectGetWidth(*textRects);
    *backgroundRect = NSInsetRect(*backgroundRect, CGRectGetWidth(bounds)*(CGFloat)0.01, 0);
}

NS_INLINE CGRect _SSGetSwitchInsetBackgroundRect(CGRect backgroundRect) {
	return NSInsetRect(backgroundRect, 1.0, 1.0);
}

NS_INLINE CGFloat _SSGetSwitchBackgroundRadiusForRect(CGRect rect) {
	return CGRectGetHeight(rect)*(CGFloat)0.1;
}

NS_INLINE CGRect _SSGetSwitchKnobRectForInsetBackground(CGRect slotRect, CGFloat floatValue) {
	CGFloat knobWidth = CGRectGetWidth(slotRect)*(CGFloat)0.44;
	CGSize knobSize = CGSizeMake(knobWidth, CGRectGetHeight(slotRect));
	CGPoint knobCenter = CGPointMake(CGRectGetMinX(slotRect) + (knobWidth*(CGFloat)0.5) + (floatValue*(CGRectGetWidth(slotRect)-knobWidth)), CGRectGetMidY(slotRect));
	return SSSizeCenteredAroundPoint(knobSize, knobCenter);
}

#pragma mark events

- (void)mouseDown:(NSEvent *)event {
    if (!self.isEnabled) {
        return;
    }
    
	CGRect textRects[2], backgroundRect;
	_SSSwitchGetPartRects(self, self.bounds, textRects, &backgroundRect);
	
	CGRect slotRect = _SSGetSwitchInsetBackgroundRect(backgroundRect);
	CGRect knobRect = _SSGetSwitchKnobRectForInsetBackground(slotRect, self.offset);
	NSInteger state = self.state;
	CGPoint hitPoint = [self convertPoint:event.locationInWindow fromView:nil];
	if (![self mouse:hitPoint inRect:knobRect]) {
        if ((state == NSOffState && CGRectGetMaxX(knobRect) < hitPoint.x) || (state == NSOnState && CGRectGetMinX(knobRect) > hitPoint.x)) {
            self.state = !state;
        }
            
		return;
	}
	
	[self.cell setHighlighted:YES];
	
	BOOL loop = YES, dragging = NO;
	
	CGPoint mouseLocation;
	
	while (loop) {
		event = [self.window nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)];
		mouseLocation = [self convertPoint:event.locationInWindow fromView:nil];
		
		CGFloat newFloat, newPosition;
		CGFloat minPosition = CGRectGetMinX(slotRect) + CGRectGetWidth(knobRect)/(CGFloat)2.0;
		CGFloat maxPosition = CGRectGetMaxX(slotRect) - CGRectGetWidth(knobRect)/(CGFloat)2.0;
		
		switch (event.type) {
			case NSLeftMouseDragged: {
				dragging = YES;
				newPosition = mouseLocation.x - (hitPoint.x-NSMidX(knobRect));
				
                if (newPosition <= minPosition) {
                    newFloat = 0.0;
                } else if (newPosition >= maxPosition) {
                    newFloat = 1.0;
                } else {
                    newFloat = (newPosition-minPosition)/(maxPosition - minPosition);
                }
                
				self.offset = newFloat;
				break;
			}
            case NSLeftMouseUp: {
				[self.cell setHighlighted:NO];
				
				if (dragging) {
					CGFloat value = (state ? 1.0 : 0.0) + ((state ? -1 : 1) * 0.25);
					self.state = ((self.offset >= value) ? NSOnState : NSOffState);
                } else {
                    self.state = !state;
                }
                
				loop = NO;
				break;
			}
            default:
                break;
		}
	}
}

#pragma mark drawing

- (void)drawRect:(CGRect)frame {
	CGRect textRects[2], backgroundRect;
	_SSSwitchGetPartRects(self, self.bounds, textRects, &backgroundRect);
	
	if ([self needsToDrawRect:textRects[0]] || [self needsToDrawRect:textRects[1]]) {
        if (_title || _alternateTitle) {
            NSShadow *textShadow = [[NSShadow alloc] init];
            textShadow.shadowColor = [NSColor colorWithCalibratedWhite:1.0 alpha:0.92];
            textShadow.shadowOffset = CGSizeMake(0, -1.0);
            textShadow.shadowBlurRadius = 0.0;
            
            [NSGraphicsContext saveGraphicsState];
            [textShadow set];
            
            CGColorRef textColor = NSColor.textColor.CGColor;
            NSFont *font = [NSFont boldSystemFontOfSize:16];
            CGRect bounds = self.bounds;
            CGContextRef ctx = SSContextGetCurrent();
            CGContextSaveGState(ctx);
            {
                CGContextTranslateCTM(ctx, 0, bounds.size.height);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
                SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)_alternateTitle, CGRectIntegral(textRects[0]), kCTTextAlignmentCenter, (__bridge CTFontRef)font, textColor);
            }
            CGContextRestoreGState(ctx);
            
            [NSGraphicsContext restoreGraphicsState];
            
            [NSGraphicsContext saveGraphicsState];
            [textShadow set];
            
            CGContextSaveGState(ctx);
            {
                CGContextTranslateCTM(ctx, 0, bounds.size.height);
                CGContextScaleCTM(ctx, 1.0, -1.0);
                CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
                SSContextDrawTextAlignedInRect(ctx, (__bridge CFStringRef)_title, CGRectIntegral(textRects[1]), kCTTextAlignmentCenter, (__bridge CTFontRef)font, textColor);
            }
            CGContextRestoreGState(ctx);
            
            [NSGraphicsContext restoreGraphicsState];
            [textShadow release];
        }
	}
	
	//CGFloat radius = _SSSwitchBackgroundRadiusForRect(backgroundRect);
	//NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:CGRectIntegral(backgroundRect) radius:radius];
	//NSGradient *backgroundGradient = [[[NSGradient alloc] initWithColors:@[[NSColor colorWithCalibratedWhite:0.670 alpha:0.33], [NSColor colorWithCalibratedWhite:1.0 alpha:0.33]]] autorelease];
	
	//[backgroundGradient drawInBezierPath:backgroundPath angle:90];
	
	CGRect insetBackgroundRect = _SSGetSwitchInsetBackgroundRect(backgroundRect);
	CGFloat interiorRadius = _SSGetSwitchBackgroundRadiusForRect(insetBackgroundRect);
	NSBezierPath *interiorPath = [NSBezierPath bezierPathWithRoundedRect:CGRectIntegral(insetBackgroundRect) radius:interiorRadius];
	NSGradient *interiorGradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.388 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.557 alpha:1.0], 0.3, [NSColor colorWithCalibratedWhite:0.670 alpha:1.0], 1.0, nil] autorelease];
    
	interiorPath.lineWidth = 2.0;
	[interiorPath addClip];
	[interiorGradient drawInBezierPath:interiorPath angle:90];
	[[NSColor colorWithCalibratedWhite:0.336 alpha:0.9] set];
	[interiorPath stroke];
	
	[NSGraphicsContext saveGraphicsState];
	//[backgroundPath setClip];
	// Draw the knob
	[self _drawKnobInSlotRect:insetBackgroundRect radius:interiorRadius];
	
	[NSGraphicsContext restoreGraphicsState];
}

#pragma mark NSView

- (void)viewDidMoveToWindow {
    if (!self.window) {
        return;
    }
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

#pragma mark bindings

- (void *)contextForBinding:(NSString *)binding {
    if ([binding isEqualToString:NSValueBinding]) {
        return &_SSSwitchValueObservationContext;
    }
    return nil;
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
    
    if ([binding isEqualToString:NSValueBinding]) {
        self.offset = (CGFloat)self.state;
    }
    
	[self setNeedsDisplay];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &_SSSwitchValueObservationContext) {
        [self.animator setOffset:(CGFloat)self.state];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
	[self setNeedsDisplay];
}

#pragma mark getters & setters

- (NSString *)title {
    return _title;
}

- (void)setTitle:(NSString *)title {
    SSNonAtomicRetainedSet(_title, title);
}

- (NSString *)alternateTitle {
    return _alternateTitle;
}

- (void)setAlternateTitle:(NSString *)alternateTitle {
    SSNonAtomicRetainedSet(_alternateTitle, alternateTitle);
}

#if defined(__MAC_10_14)
- (NSControlStateValue)state
#else
- (NSCellStateValue)state
#endif
{
#if defined(__MAC_10_14)
    return ([[self valueForBinding:NSValueBinding] boolValue] ? NSControlStateValueOn : NSControlStateValueOff);
#else
    return ([[self valueForBinding:NSValueBinding] boolValue] ? NSOnState : NSOffState);
#endif
}

#if defined(__MAC_10_14)
- (void)setState:(NSControlStateValue)value
#else
- (void)setState:(NSCellStateValue)value
#endif
{
	[self setValue:@(value) forBinding:NSValueBinding];
    [self sendAction:self.action to:self.target];
    [self setNeedsDisplay];
}

- (NSBezelStyle)bezelStyle {
    return ((SSGradientButtonCell *)self.cell).bezelStyle;
}

- (void)setBezelStyle:(NSBezelStyle)bezelStyle {
    ((SSGradientButtonCell *)self.cell).bezelStyle = bezelStyle;
    [self setNeedsDisplay];
}

- (CGFloat)offset {
    return _offset;
}

- (void)setOffset:(CGFloat)value {
	_offset = value;
	[self setNeedsDisplay];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
	return YES;
}

- (BOOL)isFlipped {
    return YES;
}

@end

@implementation SSSwitch (Private)

- (void)_drawKnobInSlotRect:(CGRect)slotRect radius:(CGFloat)radius {
	CGRect handleBounds = _SSGetSwitchKnobRectForInsetBackground(slotRect, self.offset);
    SSGradientButtonCell *cell = self.cell;
    cell.cornerRadius = radius;
	[cell drawBezelWithFrame:CGRectIntegral(handleBounds) inView:self];
}

@end
