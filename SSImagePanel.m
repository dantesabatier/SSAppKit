//
//  SSImagePanel.m
//  SSAppKit
//
//  Created by Dante Sabatier on 21/02/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSImagePanel.h"
#import "SSAsynchronousImageView.h"
#import <SSBase/SSGeometry.h>
#import <SSGraphics/SSImage.h>

static BOOL __kSharedImagePanelCanBeDestroyed = NO;

@implementation SSImagePanel

static SSImagePanel * sharedImagePanel;

+ (SSImagePanel*)sharedImagePanel {
#if defined(__MAC_10_6)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImagePanel = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __kSharedImagePanelCanBeDestroyed = YES;
            [sharedImagePanel release];
            sharedImagePanel = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
    return sharedImagePanel;
}

+ (BOOL)sharedImagePanelExists {
    return sharedImagePanel != nil;
}

- (instancetype)init {
    self = [self initWithContentRect:CGRectMake(0, 0, 300, 300) styleMask:NSTitledWindowMask|NSClosableWindowMask|NSUtilityWindowMask backing:NSBackingStoreBuffered defer:YES];
    if (self) {
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.animationBehavior = NSWindowAnimationBehaviorNone;
            self.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary;
#if defined(__MAC_10_10)
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                self.titleVisibility = NSWindowTitleHidden;
                self.titlebarAppearsTransparent = YES;
                self.styleMask |= NSFullSizeContentViewWindowMask;
            }
#endif
        }
#endif
    }
    return self;
}

#if defined(__MAC_10_12)
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSWindowStyleMask)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#else
- (instancetype)initWithContentRect:(CGRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
#endif 
{
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
	if (self) {
        NSView *contentView = self.contentView;
        imageView = [[SSAsynchronousImageView alloc] initWithFrame:contentView.bounds];
        imageView.autoresizingMask = SSViewAutoresizingAll;
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            NSVisualEffectView *visualEffectView = [[[NSVisualEffectView alloc] initWithFrame:contentView.bounds] autorelease];
            visualEffectView.autoresizingMask = SSViewAutoresizingAll;
            visualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]; // always set the desired appearance to the NSVisualEffectView
            visualEffectView.presentingView = imageView;
            contentView.presentingView = visualEffectView;
        }
#endif
        if (!imageView.superview) {
            contentView.presentingView = imageView;
        }
	}
	return self;
}

- (void)dealloc {
    if ((self == sharedImagePanel) && !__kSharedImagePanelCanBeDestroyed) {
        return;
    }
    
    [imageView release];
    
    [super ss_dealloc];
}

#pragma mark getters & setters

- (SSAsynchronousImageView *)imageView {
    return imageView;
}

- (CGImageRef)image {
    return imageView.image;
}

- (void)setImage:(CGImageRef)image {
    [imageView setImage:image imageProperties:nil];
    
    if (!image) {
        return;
    }
    
    CGSize screenSize = self.screen.visibleFrame.size;
	CGSize imageSize = SSImageGetSize(image);
    if ((screenSize.width < imageSize.width) || (screenSize.height < imageSize.height)) {
        imageSize = SSSizeMakeWithAspectRatioInsideSize(imageSize, screenSize, SSRectResizingMethodScale);
    }
    
	CGRect frame = [self frameRectForContentRect:CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), imageSize.width, imageSize.height)];
	frame.origin.y -= frame.size.height - self.frame.size.height;
    
    if (!NSEqualRects(frame, self.frame)) {
        [self setFrame:frame display:YES animate:self.isVisible];
    }
        
}

@end
