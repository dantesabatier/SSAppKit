//
//  SSTexturedCornerView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSTexturedCornerView.h"
#import "SSMenuButton.h"
#import "NSView+SSAdditions.h"
#import "NSGradient+SSAdditions.h"

#define kCVMenuButtonTag 86547

@implementation SSTexturedCornerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundGradient = [NSGradient tableHeaderViewBackgroundGradientAsKey:YES];
        self.alternateBackgroundGradient = [NSGradient tableHeaderViewBackgroundGradientAsKey:NO];
        self.gradientAngle = -90;
    }
    return self;
}

#pragma mark getters & setters

- (NSMenu *)menu {
	return [self viewWithTag:kCVMenuButtonTag].menu;
}

- (void)setMenu:(NSMenu *)menu {
    SSMenuButton *button = [self viewWithTag:kCVMenuButtonTag];
    if (!button) {
        button = [[[SSMenuButton alloc] initWithFrame:CGRectMake(3.0, 2.0, 10.0, 11.0)] autorelease];
        button.autoresizingMask = NSViewMaxXMargin|NSViewMinYMargin;
        button.tag = kCVMenuButtonTag;
        button.title = @"";
        button.bezelStyle = NSRegularSquareBezelStyle;
        button.buttonType = NSMomentaryChangeButton;
        button.bordered = NO;
        button.imagePosition = NSImageOnly;
        button.image = [NSImage imageNamed:NSImageNameActionTemplate];
        
        ((NSButtonCell *)button.cell).imageScaling = NSImageScaleProportionallyDown;
        button.cell.controlSize = NSSmallControlSize;
        
        [self addSubview:button];
    }
    
	button.menu = menu;
}

- (BOOL)isFlipped {
	return YES;
}

@end
