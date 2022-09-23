//
//  NSWindow+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "NSWindow+SSAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import <SSBase/SSGeometry.h>

@implementation NSWindow (SSAdditions)

- (void)animateToFrame:(CGRect)frameRect duration:(NSTimeInterval)duration {
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[@{NSViewAnimationTargetKey: self, NSViewAnimationEndFrameKey: [NSValue valueWithRect:frameRect]}]];
    animation.duration = duration;
    animation.animationBlockingMode = NSAnimationBlocking;
    animation.animationCurve = NSAnimationLinear;
    [animation startAnimation];
    [animation release];
}

- (BOOL)isActive {
    return self.attachedSheet ? YES : (self.canBecomeMainWindow ? self.isMainWindow : self.isKeyWindow);
}

- (BOOL)inFullScreenMode {
    return (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) ? (self.styleMask & NSFullScreenWindowMask) : NO;
}

- (CGPoint)centerPoint {
    return SSRectGetCenterPoint(self.frame);
}

- (void)setCenterPoint:(CGPoint)centerPoint {
    [self setFrame:SSRectCenteredAroundPoint(self.frame, centerPoint) display:YES];
}

- (void)flipToWindow:(NSWindow *)window withDuration:(CFTimeInterval)duration edge:(NSRectEdge)edge shadowed:(BOOL)shadowed {
    //Center the toWindow under the fromWindow
    
    window.centerPoint = self.centerPoint;
    
    //force redisplay of hidden window so we get an up to date image
    [window display];
    
    NSString *animationKey = @"transform";
    //Create two windows to contain images of the windows
    NSWindow* flipFromWindow = [[NSWindow alloc] initWithContentRect:NSInsetRect(self.frame,-100,-100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    flipFromWindow.releasedWhenClosed = YES;
    flipFromWindow.opaque = NO;
    flipFromWindow.hasShadow = NO;
    flipFromWindow.backgroundColor = [NSColor clearColor];
    
    NSWindow *flipToWindow = [[NSWindow alloc] initWithContentRect:NSInsetRect(window.frame,-100,-100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    flipToWindow.releasedWhenClosed = YES;
    flipToWindow.opaque = NO;
    flipToWindow.hasShadow = NO;
    flipToWindow.backgroundColor = [NSColor clearColor];
    
    //Two temp views to get some data
    NSView *tempFrom = ((NSView *)self.contentView).superview;
    NSView *tempTo = ((NSView *)window.contentView).superview;
    
    CGRect tempFromBounds = tempFrom.bounds;
    CGRect tempToBounds = tempTo.bounds;
    
    //Grab the bitmap of the windows
    NSBitmapImageRep *fromBitmap = [tempFrom bitmapImageRepForCachingDisplayInRect:tempFromBounds];
    [tempFrom cacheDisplayInRect:tempFromBounds toBitmapImageRep:fromBitmap];
    
    NSBitmapImageRep *toBitmap = [tempTo bitmapImageRepForCachingDisplayInRect:tempToBounds];
    [tempTo cacheDisplayInRect:tempToBounds toBitmapImageRep:toBitmap];
    
    //Create two views sized to their respective windows
    NSView *fromView = [[[NSView alloc] initWithFrame:tempFromBounds] autorelease];
    fromView.wantsLayer = YES;
    fromView.autoresizingMask = NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewHeightSizable|NSViewMaxYMargin;
    
    NSView *toView = [[[NSView alloc] initWithFrame:tempToBounds] autorelease];
    toView.wantsLayer = YES;
    toView.autoresizingMask = NSViewMinXMargin|NSViewWidthSizable|NSViewMaxXMargin|NSViewMinYMargin|NSViewHeightSizable|NSViewMaxYMargin;
    
    flipFromWindow.contentView = fromView;
    flipToWindow.contentView = toView;
    
    //Create two layers sized to their respective windows
    CALayer *fromLayer = [CALayer layer];
    fromLayer.frame = tempFromBounds;
    fromLayer.contents = (id)fromBitmap.CGImage;
    fromLayer.doubleSided = NO;
    fromLayer.contentsGravity = kCAGravityCenter;
    
    CALayer *toLayer = [CALayer layer];
    toLayer.frame = tempFromBounds;
    toLayer.contents = (id)toBitmap.CGImage;
    toLayer.doubleSided = NO;
    toLayer.contentsGravity = kCAGravityCenter;
    
    //Make the layer we are flipping have a rotation of M_PI so it is facing away and culled
    [toLayer setValue:[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0)] forKeyPath:animationKey];
    
    if (shadowed) {
        //Create shadows on the layers - the shadow varies between versions of OSX.
        //I should really write some code to accomodate it, but it hasn't been critical as we don't use it.
        //Keep in mind, the shadow drawn is a filled box. If your view is transparent, it will look weird.
        //Basically this shadow is really poorly implemented and needs to be done properly.
        int shadowRadius = 14;
        CGSize offset = CGSizeMake(0,-22.5);
        float opacity = 0.4;
        
        fromLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        fromLayer.shadowRadius = shadowRadius;
        fromLayer.shadowOffset = offset;
        fromLayer.shadowOpacity = opacity;
        toLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        toLayer.shadowRadius = shadowRadius;
        toLayer.shadowOffset = offset;
        toLayer.shadowOpacity = opacity;
    }
    
    //Add the layers to their respective views
    fromView.layer = fromLayer;
    toView.layer = toLayer;
    
    //We need to disable screen updates so all this setup doesn't cause weird visual flickering, etc
    NSDisableScreenUpdates();
    
    //Bring up the new bitmapped windows
    [flipToWindow orderFront:nil];
    [flipFromWindow orderFront:nil];
    [flipToWindow display];
    [flipFromWindow display];
    
    //Remove the original window
    [self close];
    
    //Bring up the destination window
    window.alphaValue = 0.0;
    [window orderFront:nil];
    
    //Our flippers are in place and ready to go, enable updates to draw them. They should look identical at this point
    NSEnableScreenUpdates();
    
    //Set up the animation
    CABasicAnimation *fromAnimation = [CABasicAnimation animationWithKeyPath:animationKey];
    fromAnimation.removedOnCompletion = NO;
    
    CABasicAnimation *toAnimation = [CABasicAnimation animationWithKeyPath:animationKey];
    toAnimation.removedOnCompletion = NO;
    
    //The zDistance is what makes it look like the window is rotating around a center. Playing with this value is fun. Try it!
    int zDistance = 850;
    
    CATransform3D fromTransform = CATransform3DIdentity;
    fromTransform.m34 = 1.0 / -zDistance;
    fromTransform = CATransform3DRotate(fromTransform, M_PI, 0.0, 1.0, 0.0);
    
    CATransform3D toTransform = CATransform3DIdentity;
    toTransform.m34 = 1.0 / -zDistance;
    toTransform = CATransform3DRotate(toTransform, 2*M_PI, 0.0, 1.0, 0.0);
    
    //Apply all our options to our animations
    fromAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    fromAnimation.toValue = [NSValue valueWithCATransform3D:fromTransform];
    fromAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    toAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0)];
    toAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    toAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
#if 1
    CGEventRef event = CGEventCreate(NULL);
	CGEventFlags modifiers = CGEventGetFlags(event);
	CFRelease(event);
    
    //For fun. Hold shift to double duration of flip. Hold shift and control to quadruple it.
	if (modifiers & kCGEventFlagMaskShift)
        duration *= 2;
    if ((modifiers & kCGEventFlagMaskShift) && (modifiers & kCGEventFlagMaskControl))
        duration *= 4;
#endif
    
    fromAnimation.duration = duration;
    toAnimation.duration = duration;
    
    //Fire animations  
    [fromLayer setValue:[NSValue valueWithCATransform3D:fromTransform] forKeyPath:animationKey];  
    [fromLayer addAnimation:fromAnimation forKey:animationKey];  
    [toLayer setValue:[NSValue valueWithCATransform3D:toTransform] forKeyPath:animationKey];
    [toLayer addAnimation:toAnimation forKey:animationKey];
    
    [NSWindow.class cancelPreviousPerformRequestsWithTarget:flipFromWindow selector:@selector(close) object:nil];
    [flipFromWindow performSelector:@selector(close) withObject:nil afterDelay:duration inModes:@[NSRunLoopCommonModes]];
    
    [NSWindow.class cancelPreviousPerformRequestsWithTarget:flipToWindow selector:@selector(close) object:nil];
    [flipToWindow performSelector:@selector(close) withObject:nil afterDelay:duration inModes:@[NSRunLoopCommonModes]];
    
    [NSWindow.class cancelPreviousPerformRequestsWithTarget:window selector:@selector(setAlphaValue:) object:@1.0f];
    [window performSelector:@selector(setAlphaValue:) withObject:@1.0f afterDelay:duration inModes:@[NSRunLoopCommonModes]];
}

@end
