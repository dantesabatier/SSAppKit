//
//  SSProgressView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/21/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSProgressView.h"
#if TARGET_OS_IPHONE
#import <graphics/SSColorSpace.h>
#import <graphics/SSContext.h>
#import <graphics/SSGradient.h>
#import <graphics/SSPath.h>
#import <graphics/SSUtilities.h>
#else
#import "NSColor+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSGraphics/SSColorSpace.h>
#import <SSGraphics/SSContext.h>
#import <SSGraphics/SSGradient.h>
#import <SSGraphics/SSPath.h>
#import <SSGraphics/SSUtilities.h>
#endif

static void SSDrawStripePattern (void *info, CGContextRef ctx) {
    CGMutablePathRef patternPath = CGPathCreateMutable();
    CGPathMoveToPoint(patternPath, NULL, 0, 5);
    CGPathAddLineToPoint(patternPath, NULL, 5, 0);
    CGPathAddLineToPoint(patternPath, NULL, 0, 0);
    CGPathCloseSubpath(patternPath);
    
    CGPathMoveToPoint(patternPath, NULL, 0, 15);
    CGPathAddLineToPoint(patternPath, NULL, 0, 20);
    CGPathAddLineToPoint(patternPath, NULL, 5, 20);
    CGPathAddLineToPoint(patternPath, NULL, 20, 5);
    CGPathAddLineToPoint(patternPath, NULL, 20, 0);
    CGPathAddLineToPoint(patternPath, NULL, 15, 0);
    CGPathCloseSubpath(patternPath);
    
    CGPathMoveToPoint(patternPath, NULL, 15, 20);
    CGPathAddLineToPoint(patternPath, NULL, 20, 20);
    CGPathAddLineToPoint(patternPath, NULL, 20, 15);
    CGPathCloseSubpath(patternPath);
    
    CGContextAddPath(ctx, patternPath);
    
    CGContextFillPath(ctx);
    
    CGPathRelease(patternPath);
}

@interface SSProgressView ()

#if TARGET_OS_IPHONE
@property (nonatomic, copy) UIColor *startProgressGradientColor;
@property (nonatomic, copy) UIColor *endProgressGradientColor;
#else
@property (nonatomic, copy) NSColor *startProgressGradientColor;
@property (nonatomic, copy) NSColor *endProgressGradientColor;
#endif

@end

@implementation SSProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _phase = 0;
        _minValue = 0.0;
        _maxValue = 1.0;
        _doubleValue = 1.0;
        _cornerRadius = 0;
		_flags.indeterminate = 1;
        
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
#endif
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.minValue = [coder decodeDoubleForKey:@"minValue"];
        self.maxValue = [coder decodeDoubleForKey:@"maxValue"];
        self.doubleValue = [coder decodeDoubleForKey:@"doubleValue"];
        self.cornerRadius = [coder decodeFloatForKey:@"cornerRadius"];
        self.indeterminate = [coder decodeBoolForKey:@"indeterminate"];
        self.startProgressGradientColor = [coder decodeObjectForKey:@"startProgressGradientColor"];
        self.endProgressGradientColor = [coder decodeObjectForKey:@"endProgressGradientColor"];
        _phase = 0;
#if (TARGET_OS_MAC && !(TARGET_OS_EMBEDDED || TARGET_OS_IPHONE))
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
#endif
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:_cornerRadius forKey:@"cornerRadius"];
    [coder encodeDouble:_minValue forKey:@"minValue"];
    [coder encodeDouble:_maxValue forKey:@"maxValue"];
    [coder encodeDouble:_doubleValue forKey:@"doubleValue"];
    [coder encodeBool:(BOOL)_flags.indeterminate forKey:@"indeterminate"];
    [coder encodeObject:_startProgressGradientColor forKey:@"startProgressGradientColor"];
    [coder encodeObject:_endProgressGradientColor forKey:@"endProgressGradientColor"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_displayLink invalidate];
    [_displayLink release];
    
    CGGradientRelease(_progressGradient);
    
    [_startProgressGradientColor release];
    [_endProgressGradientColor release];
	
    [super ss_dealloc];
}

#if defined(__MAC_10_10)

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    _maxValue = 1.0;
    _doubleValue = 1.0;
    _cornerRadius = 0;
}

#endif

- (void)startAnimation:(id)sender {
    if (!_displayLink) {
        _displayLink = [[CADisplayLink displayLinkWithTarget:self selector:@selector(update)] ss_retain];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    _displayLink.paused = NO;
    
	_flags.indeterminate = 1;
}

- (void)stopAnimation:(id)sender {
    _displayLink.paused = YES;
	
	_flags.indeterminate = 0;
    _phase = 0;
}

- (void)update {
    _phase++;
    
    [self display];
}

- (void)drawRect:(CGRect)dirtyRect {
    BOOL isDrawingToScreen = YES;
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
    isDrawingToScreen = [NSGraphicsContext currentContext].drawingToScreen;
#endif
    
    if (!isDrawingToScreen) {
        return;
    }
    
    CGContextRef ctx = SSContextGetCurrent();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGRect bounds = self.bounds;
    bounds.origin.y += 1.0;
    bounds.size.height -= 1.0;
    
    CGRect progressRect = CGRectInset(bounds, 1.0, 1.0);
    CGFloat cornerRadius = MIN(self.cornerRadius, CGRectGetHeight(progressRect)*(CGFloat)0.5);
	if (!self.isIndeterminate) {
        progressRect.size.width = FLOOR((CGRectGetWidth(progressRect) / (self.maxValue - self.minValue)) * (self.doubleValue - self.minValue));
        if (CGRectGetWidth(progressRect) < (cornerRadius * (CGFloat)1.5)) {
            progressRect.size.height = MIN((cornerRadius*(CGFloat)0.5) + CGRectGetWidth(progressRect) + (CGRectGetHeight(progressRect) - (cornerRadius * (CGFloat)2.0)) + 2.0, CGRectGetHeight(bounds) - 2.0);
            progressRect.origin.y = CGRectGetMidY(bounds) - CGRectGetHeight(progressRect)*(CGFloat)0.5;
        }
    }
    
    CGPathRef holderPath = SSPathCreateWithRoundedRect(bounds, cornerRadius, NULL);
    CGPathRef progressPath = SSPathCreateWithRect(progressRect, (CGRectGetWidth(progressRect) < cornerRadius) ? SSRectLeftCorners : SSRectAllCorners, MAX(cornerRadius - 1.0, 0), NULL);
    
    // Draw the holder
    CGContextSaveGState(ctx);
    {
        CGContextSaveGState(ctx);
        {
            CGColorRef dropShadowColor = CGColorCreate(colorSpace, (const CGFloat[]) {1.0, 1.0, 1.0, 0.06});
            CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, dropShadowColor);
			CGColorRelease(dropShadowColor);
            
            // Draw holder background gradient
            CGContextBeginTransparencyLayer(ctx, NULL);
            {
                CGContextAddPath(ctx, holderPath);
                CGContextClip(ctx);
                
                CGGradientRef backgroundGradient = CGGradientCreateWithColorComponents(colorSpace, (const CGFloat[]){0, 0, 0, 0, 0, 0, 0, 0.33}, (const CGFloat[]){1, 0}, 2);
                CGColorRef shadowColor = CGColorCreate(colorSpace, (const CGFloat[]){0.16, 0.16, 0.16, 0.16});
                CGContextSaveGState(ctx);
                {
                    CGContextSetFillColorWithColor(ctx, shadowColor);
                    CGContextFillRect(ctx, bounds);
                    CGPoint endPoint = CGPointZero;
                    CGPoint startPoint = CGPointMake(0, CGRectGetMaxY(bounds));
                    CGContextSetShadowWithColor(ctx, CGSizeZero, 0, NULL);
					CGContextDrawLinearGradient(ctx, backgroundGradient, startPoint, endPoint, 0);
                }
                CGContextRestoreGState(ctx);
				CGColorRelease(shadowColor);
				CGGradientRelease(backgroundGradient);
                
            }
            CGContextEndTransparencyLayer(ctx);
        }
        CGContextRestoreGState(ctx);
        
        // Draw the holder inner shadow
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, holderPath);
            const CGFloat holderInnerShadowComponents[] = {0.0, 0.0, 0.0, 1.0};
            CGColorRef holderInnerShadowColor = CGColorCreate(colorSpace, holderInnerShadowComponents); 
            SSContextDrawInnerShadowWithColor(ctx, holderPath, holderInnerShadowColor, CGSizeMake(0.0, -1.0), 3.0);
            CGColorRelease(holderInnerShadowColor);
        }
        CGContextRestoreGState(ctx);
    }
    CGContextRestoreGState(ctx);
    
    // Draw the progress bar
    CGContextSaveGState(ctx);
    {
        // Draw the stroke.  It'll draw it inside, too, so have it draw the rest on top
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, progressPath);
            const CGFloat strokeComponents[] = { 0.0, 0.0, 0.0, 0.37};
            CGColorRef strokeColor = CGColorCreate(colorSpace, strokeComponents);
            CGContextSetStrokeColorWithColor(ctx, strokeColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(strokeColor);
        }
        CGContextRestoreGState(ctx);
        
        // Draw the actual progress bar
        CGContextAddPath(ctx, progressPath);
        CGContextClip(ctx);
        
        CGGradientRef progressGradient = self.progressGradient;
        CGRect boundingBox = CGPathGetBoundingBox(progressPath);
        CGContextDrawLinearGradient(ctx, progressGradient, CGPointZero, CGPointMake(CGRectGetMaxX(boundingBox), 0), 0);
        SSContextDrawGlossGradient(ctx, boundingBox, false);
        
        // Draw progress bar glow
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, progressPath);
            const CGFloat glowComponents[] = { 0.9, 0.9, 0.9, 0.16};
            CGColorRef glowColor = CGColorCreate(colorSpace, glowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            CGContextSetStrokeColorWithColor(ctx, glowColor);
            CGContextSetLineWidth(ctx, 2.0);
            CGContextStrokePath(ctx);
            CGColorRelease(glowColor);
        }
        CGContextRestoreGState(ctx);
        
        // Draw progress bar inner shadow
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, progressPath);
            const CGFloat innerShadowComponents[] = {0.9, 0.9, 0.9, 0.6};
            CGColorRef innerShadowColor = CGColorCreate(colorSpace, innerShadowComponents);
            CGContextSetBlendMode(ctx, kCGBlendModeOverlay);
            SSContextDrawInnerShadowWithColor(ctx, progressPath, innerShadowColor, CGSizeMake(0.0, -1.0), 0.0);
            CGColorRelease(innerShadowColor);
        }
        CGContextRestoreGState(ctx);
        
		if (self.isIndeterminate) {
			// Draw stripes
			CGContextSaveGState(ctx);
			{
				CGContextSetPatternPhase(ctx, CGSizeMake(_phase, 0));
				static const CGPatternCallbacks callbacks = {0, &SSDrawStripePattern, NULL};
				CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(colorSpace);
				CGContextSetFillColorSpace(ctx, patternSpace);
				CGColorSpaceRelease(patternSpace);
				
				CGPatternRef pattern = CGPatternCreate(NULL, CGRectMake(0, 0, 20, 20), CGAffineTransformIdentity, 20, 20, kCGPatternTilingConstantSpacing, false, &callbacks);
				const CGFloat patternColorComponents[] = {0.0, 0.0, 0.0, 0.28};
				CGContextSetFillPattern(ctx, pattern, patternColorComponents);
				CGPatternRelease(pattern);
				CGContextSetBlendMode(ctx, kCGBlendModeSoftLight);
				CGContextFillRect(ctx, CGRectMake(boundingBox.origin.x, -2.0, boundingBox.size.width, CGRectGetHeight(bounds) + 2.0));
			}
			CGContextRestoreGState(ctx);
		}
    }
    CGContextRestoreGState(ctx);
    CGColorSpaceRelease(colorSpace);
    CGPathRelease(holderPath);
    CGPathRelease(progressPath);
}

- (void)display {
#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#else
    [super display];
#endif
}

#pragma mark NSColor notifications

- (void)controlTintDidChange:(NSNotification *)notification {
    if (_flags.viewHasCustomProgressGradient)
        return;
    
    SSRetainedTypeSet(_progressGradient, SSGradientGetDefaultProgressIndicatorGradient());
    
    [self display];
}

#pragma mark getters & setters

- (id)startProgressGradientColor {
    return _startProgressGradientColor;
}

- (void)setStartProgressGradientColor:(id)startProgressGradientColor {
    SSNonAtomicCopiedSet(_startProgressGradientColor, startProgressGradientColor);
    self.progressGradient = NULL;
}

- (id)endProgressGradientColor {
    return _endProgressGradientColor;
}

- (void)setEndProgressGradientColor:(id)endProgressGradientColor {
    SSNonAtomicCopiedSet(_endProgressGradientColor, endProgressGradientColor);
    self.progressGradient = NULL;
}

- (CGGradientRef)progressGradient {
    if (!_progressGradient) {
        if ( _startProgressGradientColor && _endProgressGradientColor) {
            _progressGradient = CGGradientCreateWithColors(SSColorSpaceGetDeviceRGB(), (__bridge CFArrayRef)@[(__bridge id)[_startProgressGradientColor CGColor], (__bridge id)[_endProgressGradientColor CGColor]], (const CGFloat[]){0.0, 1.0});
            _flags.viewHasCustomProgressGradient = 1;
        } else {
            _progressGradient = CGGradientRetain(SSGradientGetDefaultProgressIndicatorGradient());
        }
    }
    return _progressGradient;
}

- (void)setProgressGradient:(CGGradientRef)progressGradient {
    if (_progressGradient == progressGradient)
        return;
    
    SSRetainedTypeSet(_progressGradient, progressGradient);
    
    _flags.viewHasCustomProgressGradient = progressGradient ? 1 : 0;
    
    [self display];
}

- (CGFloat)cornerRadius {
    return _cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_cornerRadius == cornerRadius)
        return;
    
    _cornerRadius = MIN(cornerRadius,CGRectGetHeight(self.frame)/(CGFloat)2.0);
    
    [self display];
}

- (double)minValue {
    return _minValue;
}

- (void)setMinValue:(double)minValue {
	if (_minValue == minValue)
        return;
	
	_minValue = minValue;
	
	[self display];
}

- (double)maxValue {
    return _maxValue;
}

- (void)setMaxValue:(double)maxValue {
	if (_maxValue == maxValue)
        return;
	
	_maxValue = maxValue;
	
	[self display];
}

- (double)doubleValue {
    return _doubleValue;
}

- (void)setDoubleValue:(double)doubleValue {
	if (_doubleValue == doubleValue || _flags.indeterminate)
        return;
	
	_doubleValue = doubleValue;
    
	[self display];
}

- (BOOL)isIndeterminate {
    return _flags.indeterminate;
}

- (void)setIndeterminate:(BOOL)indeterminate {
	_flags.indeterminate = indeterminate;
	
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
    if (indeterminate) {
        [self startAnimation:nil];
    } else  {
        [self stopAnimation:nil];
    }
#endif
	[self display];
}

@end

