//
//  SSFilterView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSFilterView.h"
#import "SSMenuButton.h"
#import "SSValidatedButton.h"
#import "SSAppKitUtilities.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSArray+SSAdditions.h>

static char SSFilterViewSelectedIndexObservationContext;

@interface SSFilterViewCell : SSValidatedButton

@end

@interface SSFilterView () <SSButtonValidations> 

@end

@implementation SSFilterView

+ (void)initialize {
    if (self == SSFilterView.class) {
		[self exposeBinding:SSSelectedIndexBinding];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
	_delegate = nil;

	[super ss_dealloc];
}

- (void)drawRect:(CGRect)dirtyRect {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    
    BOOL isActive = YES;
    BOOL needsDisplayWhenWindowResignsKey = YES;
    BOOL allowsVibrancy = NO;
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
    isActive = self.window.isActive;
    needsDisplayWhenWindowResignsKey = self.needsDisplayWhenWindowResignsKey;
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        allowsVibrancy = self.effectiveAppearance.allowsVibrancy;
    }
#endif
#endif
    
    NSGradient *gradient = nil;
    if ((needsDisplayWhenWindowResignsKey && !isActive) || (allowsVibrancy && !isActive)) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            gradient = [[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:0.878 alpha:1.0], 0.0, [NSColor colorWithCalibratedWhite:0.976 alpha:1.0], 1.0, nil] autorelease];
        } else {
            gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.85098 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.929412 alpha:1.0]] autorelease];
        }
    } else {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.81176471 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1.0]] autorelease];
        } else {
            gradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.90 alpha:1.0]] autorelease];
        }
    }
    
    [gradient drawInBezierPath:[NSBezierPath bezierPathWithRect:self.bounds] angle:90];
    
    [context restoreGraphicsState];
    
    NSColor *insetColor = [NSColor colorWithCalibratedWhite:0.98 alpha:1.0];
    [insetColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:YES flip:YES];
    
    NSColor *borderColor = [NSColor colorWithCalibratedWhite:0.48 alpha:1.0];
    [borderColor drawPixelThickLineAtPosition:0 withInset:0 inRect:self.bounds inView:self horizontal:YES flip:NO];
}

- (void)reloadData {
    [[self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSView *subview, NSDictionary *bindings) {
        return [subview isKindOfClass:[SSFilterViewCell class]];
    }]] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _numberOfItems = 0;
    if (_flags.dataSourceRespondsToNumberOfItems)
        _numberOfItems = [_dataSource numberOfItemsInFilterView:self];
    
    if (_numberOfItems) {
        NSUInteger idx = 0;
        while (idx < _numberOfItems) {
            @autoreleasepool {
                NSString *title = nil;
                if (_flags.dataSourceRespondsToItemAtIndex)
                    title = [_dataSource filterView:self titleForItemAtIndex:idx];
                
                SSFilterViewCell *cell = [[[SSFilterViewCell alloc] initWithFrame:CGRectZero] autorelease];
                cell.title = title;
                cell.tag = idx;
                cell.target = self;
                cell.action = @selector(cellAction:);
                [cell sizeToFit];
                
                [self addSubview:cell];
                
                idx ++;
            }
        }
    }
    
    [self layout];
}

#pragma mark layout

- (void)layout {
    [super layout];
    
    static const CGFloat buttonWidth = 25.0;
    static const CGFloat spacing = 8.0;
    __block CGFloat width = 0;
    NSArray *subviews = [[self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSView *subview, NSDictionary *bindings) {
        return [subview isKindOfClass:[SSFilterViewCell class]];
    }]] sortedArrayUsingDescriptors:@[[[[NSSortDescriptor alloc] initWithKey:@"tag" ascending:YES] autorelease]]];
    for (NSView *subview in subviews) {
        CGFloat extension = CGRectGetWidth(subview.frame) + spacing;
        if ((width + extension) > (CGRectGetMaxX(self.bounds) - buttonWidth - spacing))
            break;
        
         width += extension;
    }
    
    BOOL menuNeedsUpdate = NO;
    CGRect bounds = SSRectCenteredSize(self.bounds, CGSizeMake(width, CGRectGetHeight(self.bounds)));
    __block CGPoint origin = bounds.origin;
    for (NSView *subview in subviews) {
        subview.frame = CGRectMake(FLOOR(origin.x), FLOOR(CGRectGetMidY(bounds) - (CGRectGetHeight(subview.bounds)*(CGFloat)0.5)), CGRectGetWidth(subview.bounds), CGRectGetHeight(subview.bounds));
        subview.hidden = NO;
        if (CGRectGetMaxX(subview.frame) > (CGRectGetMaxX(self.bounds) - buttonWidth - spacing)) {
            subview.hidden = YES;
            menuNeedsUpdate = YES;
        }
        origin.x += CGRectGetWidth(subview.bounds) + spacing;
    }
    
    static const NSInteger buttonTag = 124578;
    SSMenuButton *button = [self viewWithTag:buttonTag];
    if (!menuNeedsUpdate) {
        button.hidden = YES;
    } else {
        if (!button) {
            button = [[[SSMenuButton alloc] initWithFrame:SSRectMakeSquare(buttonWidth)] autorelease];
            button.tag = buttonTag;
            button.title = @"";
            button.bezelStyle = NSRegularSquareBezelStyle;
            button.bordered = NO;
            button.imagePosition = NSImageOnly;
            button.image = SSAppKitGetImageResourceNamed(@"NSToolbarClipIndicator");
            button.bezelStyle = NSRegularSquareBezelStyle;
            ((NSButtonCell *)button.cell).imageScaling = NSImageScaleProportionallyDown;
            
            [self addSubview:button];
        }
        
        NSMenu *menu = [[[NSMenu alloc] init] autorelease];
        for (SSFilterViewCell *subview in subviews) {
            if (!subview.isHidden)
                continue;
            
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            NSImage *image = [[subview.image copy] autorelease];
#if !defined(__MAC_10_7)
            image.scalesWhenResized = YES;
#endif
            image.size = CGSizeMake(16.0, 16.0);
            
            item.image = image;
            item.tag = subview.tag;
            item.title = subview.title;
            item.target = subview.target;
            item.action = subview.action;
            item.keyEquivalent = subview.keyEquivalent;
            
            [menu addItem:item];
        }
        
        button.frame = CGRectMake(FLOOR(CGRectGetMaxX(self.bounds) - buttonWidth), FLOOR(CGRectGetMidY(bounds) - (buttonWidth *(CGFloat)0.5)), buttonWidth, buttonWidth);
        button.menu = menu;
        button.hidden = NO;
    }
}

#pragma mark actions

- (void)cellAction:(id)sender {
	self.selectionIndex = [sender tag];
}

#pragma mark SSButtonValidations

- (BOOL)validateButton:(id <SSValidatedButton>)button {
    ((NSButton *)button).state = (button.tag == _selectionIndex) ? NSOnState : NSOffState;
	
	return YES;
}

#pragma mark selection

- (void)moveSelectionToIndex:(NSInteger)selectionIndex {
    if (!NSLocationInRange(selectionIndex, NSMakeRange(0, _numberOfItems)))
        return;
    
    NSButton *(^cellAtIndex)(NSInteger index) = ^NSButton*(NSInteger index) {
        return [[self.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSView *subview, NSDictionary *bindings) {
            return [subview isKindOfClass:[SSFilterViewCell class]];
        }]] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSButton *button, NSDictionary *bindings) {
            return (button.tag == index);
        }]].firstObject;
    };
    
    cellAtIndex(_selectionIndex).state = NSOffState;
    cellAtIndex(selectionIndex).state = NSOnState;
    
    _selectionIndex = selectionIndex;
}

#pragma mark SSKeyValueBinding

- (void *)contextForBinding:(NSString *)binding {
	if ([binding isEqualToString:SSSelectedIndexBinding])
        return &SSFilterViewSelectedIndexObservationContext;
	return [super contextForBinding:binding];
}

- (Class)valueClassForBinding:(NSString *)binding {
	if ([binding isEqualToString:SSSelectedIndexBinding])
        return [NSNumber class];
	return [super valueClassForBinding:binding];
}

#pragma mark NSKeyValueBindingCreation

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    if ([binding isEqualToString:SSSelectedIndexBinding]) {
        NSInteger index = 0;
		NSNumber *value = [self valueForBinding:SSSelectedIndexBinding];
#if TARGET_OS_IPHONE
        index = value.integerValue;
#else
        if (!NSIsControllerMarker(value))
            index = value.integerValue;
#endif
        [self moveSelectionToIndex:index];
        
        if (_flags.delegateRespondsToSelectionDidChange)
            [_delegate filterViewSelectionDidChange:self];
    }
}

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &SSFilterViewSelectedIndexObservationContext) {
		NSInteger index = 0;
		NSNumber *value = [self valueForBinding:SSSelectedIndexBinding];
#if TARGET_OS_IPHONE
        index = value.integerValue;
#else
        if (!NSIsControllerMarker(value))
            index = value.integerValue;
#endif
        [self moveSelectionToIndex:index];
        if (_flags.delegateRespondsToSelectionDidChange)
            [_delegate filterViewSelectionDidChange:self];
	} else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark getters & setters

- (id<SSFilterViewDataSource>)dataSource {
    return _dataSource;
}

- (void)setDataSource:(id<SSFilterViewDataSource>)dataSource {
    _dataSource = dataSource;
    _flags.dataSourceRespondsToNumberOfItems = [dataSource respondsToSelector:@selector(numberOfItemsInFilterView:)] ? 1 : 0;
    _flags.dataSourceRespondsToItemAtIndex = [dataSource respondsToSelector:@selector(filterView:titleForItemAtIndex:)] ? 1 : 0;
}

- (id<SSFilterViewDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSFilterViewDelegate>)delegate {
    _delegate = delegate;
    _flags.delegateRespondsToSelectionDidChange = [delegate respondsToSelector:@selector(filterViewSelectionDidChange:)] ? 1 : 0;
}

- (NSInteger)selectionIndex {
    return _selectionIndex;
}

- (void)setSelectionIndex:(NSInteger)selectionIndex {
    [self moveSelectionToIndex:selectionIndex];
	[self setValue:@(selectionIndex) forBinding:SSSelectedIndexBinding];
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end

@implementation SSFilterViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.showsBorderOnlyWhileMouseInside = YES;
        self.autoresizingMask = NSViewMaxXMargin|NSViewMinYMargin;
        self.bezelStyle = NSRecessedBezelStyle;
        self.buttonType = NSPushOnPushOffButton;
        self.focusRingType = NSFocusRingTypeNone;
        
        NSButtonCell *cell = self.cell;
        cell.wraps = NO;
        cell.alignment = NSCenterTextAlignment;
        cell.lineBreakMode = NSLineBreakByTruncatingTail;
        //cell.controlSize = NSSmallControlSize;
        //cell.font = [NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
    }
    return self;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
