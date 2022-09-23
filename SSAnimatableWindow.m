//
//  SSAnimatableWindow.m
//  SSAppKit
//
//  Created by Dante Sabatier on 19/09/13.
//
//

#import "SSAnimatableWindow.h"
#import <SSGraphics/SSGraphics.h>
#import <QuartzCore/QuartzCore.h>

static NSUInteger SSAnimatableWindowOpenTransactions = 0;

static const CGFloat SSAnimatableWindowShadowOpacity = 0.58;
static const CGSize SSAnimatableWindowShadowOffset = {0.0, -30.0};
static const CGFloat SSAnimatableWindowShadowRadius = 19.0;
static const CGFloat SSAnimatableWindowShadowHorizontalOutset = 7.0;
static const CGFloat SSAnimatableWindowShadowTopOffset = 14.0;

@interface SSAnimatableWindowContentView : NSView

@end

@interface SSAnimatableWindow ()
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_12)) || ((TARGET_OS_EMBEDDED || TARGET_OS_IPHONE) && defined(__IPHONE_10_0)))
<CAAnimationDelegate>
#endif

@end

@implementation SSAnimatableWindow

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [_fullScreenWindow release];
    [_presentationLayer release];
    
    [super ss_dealloc];
}

- (void)beginAnimations:(void(^)(CALayer *layer))block {
    if (_presentationLayer) {
        return;
    }
    _fullScreenWindow = [[NSWindow alloc] initWithContentRect:self.screen.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:self.screen];
	_fullScreenWindow.animationBehavior = NSWindowAnimationBehaviorNone;
	_fullScreenWindow.backgroundColor = [NSColor clearColor];
	_fullScreenWindow.movableByWindowBackground = NO;
	_fullScreenWindow.ignoresMouseEvents = YES;
	_fullScreenWindow.level = self.level;
	_fullScreenWindow.hasShadow = NO;
	_fullScreenWindow.opaque = NO;
	_fullScreenWindow.contentView = [[[SSAnimatableWindowContentView alloc] initWithFrame:(_fullScreenWindow.contentView).bounds] autorelease];
    
    _presentationLayer = [[CALayer alloc] init];
	_presentationLayer.contentsScale = self.backingScaleFactor;
	_presentationLayer.shadowColor = SSAutorelease(SSColorCreateDeviceRGB(0, 0, 0, SSAnimatableWindowShadowOpacity));
	_presentationLayer.shadowOffset = SSAnimatableWindowShadowOffset;
	_presentationLayer.shadowRadius = SSAnimatableWindowShadowRadius;
	_presentationLayer.shadowOpacity = 1.f;
	_presentationLayer.shadowPath = SSAutorelease(CGPathCreateWithRect(self.shadowRect, NULL));
	_presentationLayer.contentsGravity = kCAGravityResize;
	_presentationLayer.opaque = YES;
    
	[(_fullScreenWindow.contentView).layer addSublayer:_presentationLayer];
    
	_presentationLayer.frame = self.frame;
    
	NSImage *image = [self imageRepresentationOffscreen:NO];
	
	// Begin a non-animated transaction to ensure that the layer's contents are set before we get rid of the real window.
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
	_presentationLayer.contents = image;
	
	// The setup block is called when we are ordering in. We want this non-animated and done before the the fake window
	// is shown, so we do in in the same transaction.
	if (block)
		block(_presentationLayer);
	
	[CATransaction commit];
	
	[_fullScreenWindow makeKeyAndOrderFront:nil];
    
	// Effectively hide the original window. If we are ordering in, the window will become visible again once
	// the fake window is destroyed.
	self.alphaValue = 0.f;
}

- (void)setFrame:(CGRect)frameRect withDuration:(CFTimeInterval)duration timing:(CAMediaTimingFunction *)timing {
	[self beginAnimations:nil];
    
	[super setFrame:frameRect display:YES animate:NO];
	
	// We need to explicitly animate the shadow path to reflect the new size.
	CGPathRef shadowPath = SSAutorelease(CGPathCreateWithRect(self.shadowRect, NULL));
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
	animation.fromValue = (__bridge id)_presentationLayer.shadowPath;
	animation.toValue = (__bridge id)shadowPath;
	animation.duration = duration;
	animation.timingFunction = timing ? : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
	[_presentationLayer addAnimation:animation forKey:@"shadowPath"];
	_presentationLayer.shadowPath = shadowPath;
	
	NSImage *image = [self imageRepresentationOffscreen:YES];
    [self commitAnimationsWithDuration:duration timing:timing block:^(CALayer *layer) {
		_presentationLayer.frame = frameRect;
		_presentationLayer.contents = image;
	}];
}

#pragma mark animations

- (void)commitAnimationsWithDuration:(CFTimeInterval)duration timing:(CAMediaTimingFunction *)timing block:(void (^)(CALayer *layer))block {
	[NSAnimationContext beginGrouping];
	
	[CATransaction begin];
	[CATransaction setAnimationDuration:duration];
	[CATransaction setAnimationTimingFunction:timing ? : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[CATransaction setCompletionBlock:^{
		[self destroyTransformingWindowIfNeeded];
	}];
	
	block(_presentationLayer);
    
	SSAnimatableWindowOpenTransactions++;
	
	[CATransaction commit];
	[NSAnimationContext endGrouping];
}

- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key {
	animation.delegate = self;
	animation.removedOnCompletion = NO;
    
	[_presentationLayer addAnimation:animation forKey:key];
	SSAnimatableWindowOpenTransactions++;
}

#pragma mark CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	[self destroyTransformingWindowIfNeeded];
}

#pragma mark Lifecycle

// Calls `-destroyTransformingWindow` only when the running animation count is zero.
- (void)destroyTransformingWindowIfNeeded {
	SSAnimatableWindowOpenTransactions--;
	
	// If there are zero pending operations remaining, we can safely assume that it is time for the window to be destroyed.
	if (SSAnimatableWindowOpenTransactions == 0)
        [self destroyTransformingWindow];
}

// Called when the ordering methods are complete. If the layer is used
// manually, this should be called when animations are complete.
- (void)destroyTransformingWindow {
	self.alphaValue = 1.f;
	
	[_presentationLayer removeFromSuperlayer];
	_presentationLayer.contents = nil;
    [_presentationLayer release];
	_presentationLayer = nil;
	
	[_fullScreenWindow orderOut:nil];
    [_fullScreenWindow release];
	_fullScreenWindow = nil;
}

#pragma mark setup

- (NSImage *)imageRepresentationOffscreen:(BOOL)forceOffscreen {
	CGRect originalWindowFrame = self.frame;
	BOOL onScreen = self.isVisible;
	//CGFloat alpha = self.alphaValue;
	
	if (!onScreen || forceOffscreen) {
		// So the window is closed, and we need to get a screenshot of it without flashing.
		// First, we find the frame that covers all the connected screens.
		CGRect allWindowsFrame = CGRectZero;
		
		for(NSScreen *screen in [NSScreen screens]) {
            allWindowsFrame = NSUnionRect(allWindowsFrame, screen.frame);
		}
		
		// Position our window to the very right-most corner out of visible range, plus padding for the shadow.
		CGRect frame = (CGRect){
			.origin = CGPointMake(CGRectGetWidth(allWindowsFrame) + 2*SSAnimatableWindowShadowRadius, 0),
			.size = originalWindowFrame.size
		};
		
		// This is where things get nasty. Against what the documentation states, windows seem to be constrained
		// to the screen, so we override `constrainFrameRect:toScreen:` to return the original frame, which allows
		// us to put the window off-screen.
		_disableConstrainedWindow = YES;
		
		self.alphaValue = 0.f;
		if (!onScreen)
			[super makeKeyAndOrderFront:nil];
		
		[self setFrame:frame display:NO];
		
		_disableConstrainedWindow = NO;
	}
	
	// If we are ordering ourself in, we will be off-screen and will not be visible.
	self.alphaValue = 1.f;
	
	// Grab the image representation of the window, without the shadows.
	CGImageRef imageRef = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, (CGWindowID)self.windowNumber, kCGWindowImageBoundsIgnoreFraming);
	
	// So there's a problem. As it turns out, CGWindowListCreateImage() returns a CGImageRef
	// that apparently is backed by pixels that don't actually exist until they are queried.
	//
	// This is a significant problem, because what we actually want to do is to grab the image
	// from the window, then set its alpha to 0. But if the actual pixels haven't been grabbed
	// yet, then by the time we actually use them sometime later in the run loop the alpha of
	// the window will have already gone flying off into the distance and we're left with a
	// completely transparent image. That's no good.
	//
	// So here's a very nasty workaround. What we're doing is actually forcing the real pixels
	// to get copied over from the WindowServer by actually drawing them into another context
	// that has settings optimized for use with Core Animation. This isn't too wasteful, and it's
	// far better than actually copying over all of the real pixel data.
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
	CGContextRef ctx = CGBitmapContextCreate(NULL, imageSize.width, imageSize.height, 8, 0, [NSColorSpace deviceRGBColorSpace].CGColorSpace, kCGBitmapByteOrder32Host | kCGImageAlphaPremultipliedFirst);
    NSGraphicsContext *context = nil;
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9)
        context = [NSGraphicsContext graphicsContextWithCGContext:ctx flipped:YES];
#else
    context = [NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:YES];
#endif
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:context];
    
	NSImage *oldImage = [[NSImage alloc] initWithCGImage:imageRef size:CGSizeZero];
	[oldImage drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height) fromRect:CGRectZero operation:NSCompositeCopy fraction:1.0];
    
	[NSGraphicsContext restoreGraphicsState];
    [oldImage release];
	
	CGImageRef copiedImageRef = CGBitmapContextCreateImage(ctx);
	NSImage *image = [[NSImage alloc] initWithCGImage:copiedImageRef size:CGSizeZero];
	
	CGImageRelease(imageRef);
	CGImageRelease(copiedImageRef);
	CGContextRelease(ctx);
	
	// If we weren't originally on the screen, there's a good chance we shouldn't be visible yet.
	if (!onScreen || forceOffscreen)
		self.alphaValue = 0.f;
	
	// If we moved the window offscreen to get the screenshot, we want to move back to the original frame.
	if (!CGRectEqualToRect(originalWindowFrame, self.frame)) {
		[self setFrame:originalWindowFrame display:NO];
	}
	
	return [image autorelease];
}

#pragma mark NSWindow

- (CGRect)constrainFrameRect:(CGRect)frameRect toScreen:(NSScreen *)screen {
	return (_disableConstrainedWindow ? frameRect : [super constrainFrameRect:frameRect toScreen:screen]);
}

#pragma mark getters & setters

- (CALayer *)presentationLayer {
    [self beginAnimations:nil];
    
    return _presentationLayer;
}

- (CGRect)shadowRect {
	CGRect rect = CGRectInset(SSRectMakeWithSize(self.frame.size), -SSAnimatableWindowShadowHorizontalOutset, 0);
	rect.size.height += SSAnimatableWindowShadowTopOffset;
	return rect;
}

@end

@implementation SSAnimatableWindowContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer = [CALayer layer];
        self.wantsLayer = YES;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
    }
    return self;
}

@end
