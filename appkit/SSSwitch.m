//
//  SSSwitch.m
//  SSAppKit
//
//  Created by Dante Sabatier on 27/01/16.
//
//

#import "SSSwitch.h"
#import "UIView+SSAdditions.h"
#import <graphics/SSGraphics.h>
#import <quartz/CADisplayLink+SSAdditions.h>

@interface SSSwitch ()

@property (nonatomic) CGFloat offset;

@end

@implementation SSSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.borderWidth = 1.0;
        
        [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)] autorelease]];
        [self addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragging:)] autorelease]];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = nil;
        self.opaque = NO;
        self.on = [coder decodeBoolForKey:@"on"];
        self.onColor = [coder decodeObjectForKey:@"onColor"];
        self.offColor = [coder decodeObjectForKey:@"offColor"];
        self.buttonColor = [coder decodeObjectForKey:@"buttonColor"];
        self.buttonBorderColor = [coder decodeObjectForKey:@"buttonBorderColor"];
        self.borderColor = [coder decodeObjectForKey:@"borderColor"];
        self.borderWidth = [coder decodeFloatForKey:@"borderWidth"] ? [coder decodeFloatForKey:@"borderWidth"] : 1.0;
        
        [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTouch:)] autorelease]];
        [self addGestureRecognizer:[[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragging:)] autorelease]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeBool:self.isOn forKey:@"on"];
    [coder encodeObject:self.onColor forKey:@"onColor"];
    [coder encodeObject:self.offColor forKey:@"offColor"];
    [coder encodeObject:self.buttonColor forKey:@"buttonColor"];
    [coder encodeObject:self.buttonBorderColor forKey:@"buttonBorderColor"];
    [coder encodeObject:self.borderColor forKey:@"borderColor"];
    [coder encodeFloat:self.borderWidth forKey:@"borderWidth"];
}

- (void)dealloc {
    [_onColor release];
    [_offColor release];
    [_buttonColor release];
    [_buttonBorderColor release];
    [_borderColor release];
    [_shadowColor release];
    
    [super ss_dealloc];
}

- (void)drawRect:(CGRect)rect {
    CGFloat scale = self.scale;
    CGFloat borderWidth = self.borderWidth;
    CGFloat lineWidth = borderWidth*scale;
    CGRect bounds = CGRectInset(self.bounds, lineWidth + borderWidth, lineWidth + borderWidth);
    CGContextRef ctx = SSContextGetCurrent();
    CGContextSaveGState(ctx);
    {
        if (!self.isEnabled) {
            CGContextSetAlpha(ctx, 0.5);
        }
        CGPathRef slotPath = SSPathCreateWithRoundedRect(bounds, CGRectGetHeight(bounds)*(CGFloat)0.5, NULL);
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, slotPath);
            CGContextSetFillColorWithColor(ctx, self.isOn ? self.onColor.CGColor : self.offColor.CGColor);
            CGContextFillPath(ctx);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, slotPath);
            CGContextSetLineWidth(ctx, lineWidth);
            CGContextSetStrokeColorWithColor(ctx, self.isOn ? self.onColor.CGColor : self.borderColor.CGColor);
            CGContextStrokePath(ctx);
        }
        CGContextRestoreGState(ctx);
        CGPathRelease(slotPath);
        
        CGRect knobBounds = SSRectMakeSquare(FLOOR(MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))));
        knobBounds.origin = CGPointMake(FLOOR(CGRectGetMinX(bounds) + (self.offset*(CGRectGetWidth(bounds)-CGRectGetWidth(knobBounds)))), FLOOR(CGRectGetMidY(bounds) - (CGRectGetHeight(knobBounds)*(CGFloat)0.5)));
        
        CGPathRef knobPath = SSPathCreateWithRoundedRect(knobBounds, CGRectGetHeight(knobBounds)*(CGFloat)0.5, NULL);
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, knobPath);
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, lineWidth), 1.0, self.shadowColor.CGColor);
            CGContextSetFillColorWithColor(ctx, self.buttonColor.CGColor);
            CGContextFillPath(ctx);
        }
        CGContextRestoreGState(ctx);
        
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, knobPath);
            CGContextSetLineWidth(ctx, lineWidth);
            CGContextSetStrokeColorWithColor(ctx, self.buttonBorderColor.CGColor);
            CGContextStrokePath(ctx);
        }
        CGContextRestoreGState(ctx);
        CGPathRelease(knobPath);
    }
    CGContextRestoreGState(ctx);
}

#pragma mark UIGestureRecognizer

- (void)handleTouch:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.isEnabled) {
        CGFloat inset = self.borderWidth*(CGFloat)[[UIScreen mainScreen] scale];
        CGRect bounds = CGRectInset(self.bounds, inset, inset);
        CGSize slotSize = CGSizeMake(CGRectGetWidth(bounds), CGRectGetHeight(bounds)*(CGFloat)0.5);
        CGRect slotBounds = CGRectIntegral(SSRectCenteredSize(bounds, slotSize));
        CGRect knobBounds = SSRectMakeSquare(FLOOR(MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))));
        knobBounds.origin = CGPointMake(FLOOR(CGRectGetMinX(slotBounds) + (self.offset*(CGRectGetWidth(slotBounds)-CGRectGetWidth(knobBounds)))), FLOOR(CGRectGetMidY(slotBounds) - (CGRectGetHeight(knobBounds)*(CGFloat)0.5)));
        CGPoint point = [gestureRecognizer locationInView:self];
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                break;
            case UIGestureRecognizerStateEnded: {
                BOOL on = self.isOn;
                [self setOn:!on animated:(!CGRectContainsPoint(knobBounds, point) && ((!on && (CGRectGetMaxX(knobBounds) < point.x)) || (on && (CGRectGetMinX(knobBounds) > point.x))))];
                [self sendActionsForControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
            }
                break;
            default:
                break;
        }
    }
}

- (void)handleDragging:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self.isEnabled) {
        CGFloat inset = self.borderWidth*[[UIScreen mainScreen] scale];
        CGRect bounds = CGRectInset(self.bounds, inset, inset);
        CGSize slotSize = CGSizeMake(CGRectGetWidth(bounds), CGRectGetHeight(bounds)*(CGFloat)0.5);
        CGRect slotBounds = CGRectIntegral(SSRectCenteredSize(bounds, slotSize));
        CGRect knobBounds = SSRectMakeSquare(FLOOR(MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))));
        knobBounds.origin = CGPointMake(FLOOR(CGRectGetMinX(slotBounds) + (self.offset*(CGRectGetWidth(slotBounds)-CGRectGetWidth(knobBounds)))), FLOOR(CGRectGetMidY(slotBounds) - (CGRectGetHeight(knobBounds)*(CGFloat)0.5)));
        CGPoint point = CGPointZero;
        CGFloat minPosition = CGRectGetMinX(slotBounds) + CGRectGetWidth(knobBounds)*(CGFloat)0.5;
        CGFloat maxPosition = CGRectGetMaxX(slotBounds) - CGRectGetWidth(knobBounds)*(CGFloat)0.5;
        BOOL on = self.isOn;
        switch (gestureRecognizer.state) {
            case UIGestureRecognizerStateBegan:
                
                break;
            case UIGestureRecognizerStateChanged: {
                CGFloat offset = 0.0;
                CGPoint location = [gestureRecognizer locationInView:self];
                CGFloat position = location.x - (point.x-CGRectGetMidX(knobBounds));
                if (position <= minPosition) {
                    offset = 0.0;
                } else if (position >= maxPosition) {
                    offset = 1.0;
                } else {
                    offset = (position-minPosition)/(maxPosition - minPosition);
                }
                
                self.offset = offset;
            }
                break;
            case UIGestureRecognizerStateEnded: {
                self.on = ((self.offset >= (on ? 1.0 : 0.0) + ((on ? -1 : 1) * 0.25)) ? YES : NO);
                [self sendActionsForControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark getters & setters

- (UIColor *)onColor {
    if (!_onColor) {
        _onColor = [self.tintColor ss_retain];
    }
    return _onColor;
}

- (void)setOnColor:(UIColor *)onColor {
    SSNonAtomicRetainedSet(_onColor, onColor);
    
    [self setNeedsDisplay];
}

- (UIColor *)offColor {
    if (!_offColor) {
        _offColor = [[UIColor clearColor] ss_retain];
    }
    return _offColor;
}

- (void)setOffColor:(UIColor *)offColor {
    SSNonAtomicRetainedSet(_offColor, offColor);
    
    [self setNeedsDisplay];
}

- (UIColor *)buttonColor {
    if (!_buttonColor) {
        _buttonColor = [[UIColor blackColor] ss_retain];
    }
    return _buttonColor;
}

- (void)setButtonColor:(UIColor *)buttonColor {
    SSNonAtomicRetainedSet(_buttonColor, buttonColor);
    
    [self setNeedsDisplay];
}

- (UIColor *)buttonBorderColor {
    if (!_buttonBorderColor) {
        _buttonBorderColor = [[UIColor whiteColor] ss_retain];
    }
    return _buttonBorderColor;
}

- (void)setButtonBorderColor:(UIColor *)buttonBorderColor {
    SSNonAtomicRetainedSet(_buttonBorderColor, buttonBorderColor);
    
    [self setNeedsDisplay];
}

- (UIColor *)borderColor {
    if (!_borderColor) {
        _borderColor = [[UIColor grayColor] ss_retain];
    }
    return _borderColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    SSNonAtomicRetainedSet(_borderColor, borderColor);
    
    [self setNeedsDisplay];
}

- (UIColor *)shadowColor {
    if (!_shadowColor) {
        _shadowColor = [[UIColor colorWithWhite:0.0 alpha:0.50] ss_retain];
    }
    return _shadowColor;
}

- (void)setShadowColor:(UIColor *)shadowColor {
    SSNonAtomicRetainedSet(_shadowColor, shadowColor);
    
    [self setNeedsDisplay];
}

- (CGFloat)offset {
    return _offset;
}

- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    _on = (_offset == 0.0) ? NO : YES;
    
    [self setNeedsDisplay];
}

- (CGFloat)borderWidth {
    return _borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    
    [self setNeedsDisplay];
}

- (BOOL)isOn {
    return _on;
}

- (void)setOn:(BOOL)on {
    _on = on;
    _offset = on ? 1.0 : 0.0;
    
    [self setNeedsDisplay];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated {
    if (animated) {
        _on = on;
        [[CADisplayLink displayLinkWithDuration:0.25 execution:^(CGFloat progress) {
            self.offset = on ? progress : (1.0 - progress);
        }] addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        self.on = on;
    }
}

@end
