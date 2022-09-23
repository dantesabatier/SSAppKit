//
//  SSLabelPicker.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/12/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSLabelPicker.h"
#import "SSLabelPickerCell.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import <SSGraphics/SSGraphics.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSArray+SSAdditions.h>

static char SSLabelPickerValueObservationContext;

@interface SSLabelPicker () <NSValidatedUserInterfaceItem>

@end

@implementation SSLabelPicker

+ (void)initialize {
    if (self == SSLabelPicker.class) {
        [self exposeBinding:NSValueBinding];
        [self exposeBinding:NSEnabledBinding];
    }
}

+ (Class)cellClass {
	return SSLabelPickerCell.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[[self.class.cellClass alloc] initImageCell:nil] autorelease];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.cell = [[[self.class.cellClass alloc] initImageCell:nil] autorelease];
    }
    return self;
}

- (void)sizeToFit {
    [self setFrameSize:CGSizeMake(((NSCell *)self.cell).cellSize.width*[NSWorkspace sharedWorkspace].fileLabelColors.count, ((NSCell *)self.cell).cellSize.height*(CGFloat)1.5)];
}

- (void)validate {
	id validator = [NSApp targetForAction:self.action to:self.target from:self];
	if (validator) {
        if (![validator respondsToSelector:self.action]) {
            self.enabled = NO;
        } else if ([validator respondsToSelector:@selector(validateUserInterfaceItem:)]) {
            self.enabled = [validator validateUserInterfaceItem:self];
        } else {
            self.enabled = YES;
        }
    }
}

#pragma mark NSView

- (void)prepareForInterfaceBuilder {
    self.cell = [[[self.class.cellClass alloc] initImageCell:nil] autorelease];
    
    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
    paragraphStyle.paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
    paragraphStyle.alignment = NSCenterTextAlignment;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableDictionary <NSString *, id>*attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11.0];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
#if defined(__MAC_10_10)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        attributes[NSForegroundColorAttributeName] = [NSColor secondaryLabelColor];
    }
#else
    attributes[NSForegroundColorAttributeName] = [NSColor grayColor];
#endif

    self.attributedStringValue = [[[NSAttributedString alloc] initWithString:[NSWorkspace sharedWorkspace].fileLabels.firstObject attributes:attributes] autorelease];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidUpdateNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToWindow {
	[super viewDidMoveToWindow];
    
    if (!self.window) {
         return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validate) name:NSWindowDidUpdateNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

#if 1

- (void)updateTrackingAreas {
    NSArray *trackingAreas = self.trackingAreas;
    for (NSTrackingArea *trackingArea in trackingAreas) {
        [self removeTrackingArea:trackingArea];
    }
    
	[super updateTrackingAreas];
	
    NSTrackingAreaOptions trackingOptions = NSTrackingEnabledDuringMouseDrag|NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp|NSTrackingActiveInKeyWindow;
    NSArray *fileLabelColors = [NSWorkspace sharedWorkspace].fileLabelColors;
    [fileLabelColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            [self addTrackingArea:[[[NSTrackingArea alloc] initWithRect:[self rectForCellAtIndex:idx] options:trackingOptions owner:self userInfo:@{@"index": @(idx)}] autorelease]];
        }
    }];
}

#endif

- (void)viewWillDraw {
    [super viewWillDraw];
    
    if ([self.window isKindOfClass:NSClassFromString(@"NSCarbonMenuWindow")]) {
        [self validate];
    }
}

- (void)drawRect:(CGRect)rect {
    static const CGRect imageBounds = {{0, 0}, {32.0, 32.0}};
    NSImage *(^imageWithColor)(NSColor *color) = ^NSImage*(NSColor *color) {
        CGRect interiorBox = NSInsetRect(imageBounds, 4.0, 4.0);
        NSImage *image = [[NSImage alloc] initWithSize:imageBounds.size];
        [image lockFocus];
        
        [NSGraphicsContext saveGraphicsState];
        
        NSGradient *gradient = [NSGradient gradientWithBaseColor:color];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:interiorBox];
        path.lineWidth = 2.0;
        [path addClip];
        [gradient drawInBezierPath:path angle:-90.0];
        [[[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] shadowWithLevel:0.6] set];
        [path stroke];
        
        [NSGraphicsContext restoreGraphicsState];
        
        [image unlockFocus];
        
        return [image autorelease];
    };
    
    NSImage *(^clearImage)(void) = ^{
#if 1
        return imageWithColor([NSColor colorWithCalibratedWhite:0.9 alpha:1.0]);
#else
        CGRect interiorBox = NSInsetRect(imageBounds, 8.0, 8.0);
        NSImage *image = [[NSImage alloc] initWithSize:imageBounds.size];
        [image lockFocus];
        
        [[NSColor clearColor] set];
        NSRectFill(imageBounds);
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        path.lineWidth = 2.0;
        [path moveToPoint:interiorBox.origin];
        [path lineToPoint:CGPointMake(CGRectGetMaxX(interiorBox), CGRectGetMaxY(interiorBox))];
        [path moveToPoint:CGPointMake(CGRectGetMaxX(interiorBox), CGRectGetMinY(interiorBox))];
        [path lineToPoint:CGPointMake(CGRectGetMinX(interiorBox), CGRectGetMaxY(interiorBox))];
        [[NSColor colorWithCalibratedWhite:0.1 alpha:1.0] set];
        [path stroke];
        
        [image unlockFocus];
        
        return [image autorelease];
#endif
    };
    
	NSInteger currentHitIndex = (_tracking ? [self indexOfCellAtPoint:_finalEventLocation] : NSNotFound);
	NSActionCell *cell = self.cell;
    NSArray *fileLabelColors = [NSWorkspace sharedWorkspace].fileLabelColors;
    [fileLabelColors enumerateObjectsUsingBlock:^(NSColor *color, NSUInteger idx, BOOL *stop) {
        CGRect frame = [self rectForCellAtIndex:idx];
		if ([self needsToDrawRect:frame]) {
			NSImage *image = nil;
            if (!idx) {
                image = clearImage();
            } else {
                image = imageWithColor(color);
            }
            
#if !defined(__MAC_10_7)
            image.scalesWhenResized = YES;
#endif
            image.size = CGSizeMake(16.0, 16.0);
            
            cell.state = (self.integerValue == idx) ? NSOnState : NSOffState;
            cell.highlighted = (BOOL)(currentHitIndex == idx);
            cell.enabled = self.isEnabled;
            cell.image = image;
			
			[cell drawWithFrame:frame inView:self];
		}
    }];
    
    NSAttributedString *attributedStringValue = self.attributedStringValue;
    if (attributedStringValue.length) {
        CGSize cellSize = cell.cellSize;
        CGRect bounds = self.bounds;
        bounds.size.width = FLOOR(cellSize.width*(CGFloat)fileLabelColors.count);
        
        CGSize titleSize = attributedStringValue.size;
        CGRect titleRect = bounds;
        titleRect.size = titleSize;
        titleRect.origin = CGPointMake(FLOOR(NSMidX(bounds) - (CGRectGetWidth(titleRect)*(CGFloat)0.5)), FLOOR(CGRectGetMaxY(bounds) - (cellSize.height*(CGFloat)1.5) - CGRectGetHeight(titleRect)));
        
        [attributedStringValue drawInRect:titleRect];
    }
}

#pragma mark NSEvent

- (void)mouseEntered:(NSEvent *)event {
    if (!self.isEnabled) {
        return;
    }
    
    NSDictionary *userData = (__bridge NSDictionary *) event.userData;
	NSInteger index = [userData[@"index"] integerValue];
    NSArray *labels = [NSWorkspace sharedWorkspace].fileLabels;
    if ([labels containsIndex:index]) {
        NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
        paragraphStyle.paragraphStyle = [NSParagraphStyle defaultParagraphStyle];
        paragraphStyle.alignment = NSCenterTextAlignment;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSMutableDictionary <NSString *, id>*attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11.0];
        attributes[NSParagraphStyleAttributeName] = paragraphStyle;
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            attributes[NSForegroundColorAttributeName] = [NSColor secondaryLabelColor];
        }
#else
        attributes[NSForegroundColorAttributeName] = [NSColor grayColor];
#endif
        
        NSAttributedString *attributedStringValue = [[[NSAttributedString alloc] initWithString:labels[index] attributes:attributes] autorelease];
        
        CGSize cellSize = ((NSActionCell *)self.cell).cellSize;
        CGRect bounds = self.bounds;
        bounds.size.width = FLOOR(cellSize.width*(CGFloat)labels.count);
        
        CGSize titleSize = attributedStringValue.size;
        CGRect titleRect = bounds;
        titleRect.size = titleSize;
        titleRect.origin = CGPointMake(FLOOR(NSMidX(bounds) - (CGRectGetWidth(titleRect)*(CGFloat)0.5)), FLOOR(CGRectGetMaxY(bounds) - (cellSize.height*(CGFloat)1.5) - CGRectGetHeight(titleRect)));
        
        if (NSContainsRect(self.bounds, titleRect)) {
            self.attributedStringValue = attributedStringValue;
        }
    }
}

- (void)mouseExited:(NSEvent *)event {
    if (self.attributedStringValue.length) {
        self.attributedStringValue = [[[NSAttributedString alloc] initWithString:@""] autorelease];
    }
}

- (void)mouseDown:(NSEvent *)event {
    if (!self.isEnabled) {
        return;
    }
	_tracking = 1;
	_initialEventLocation = _finalEventLocation = [self convertPoint:event.locationInWindow fromView:nil];
	[self setNeedsDisplay];
}

- (void)mouseDragged:(NSEvent *)event {
	_finalEventLocation = [self convertPoint:event.locationInWindow fromView:nil];
	[self setNeedsDisplay];
}

- (void)mouseUp:(NSEvent *)event {
    if (!self.isEnabled) {
        return;
    }
    
	_tracking = 0;
	_finalEventLocation = [self convertPoint:event.locationInWindow fromView:nil];
    
    self.integerValue = [self indexOfCellAtPoint:_finalEventLocation];
    [self sendAction:self.action to:self.target];
    [self setNeedsDisplay];
}

#pragma mark SSKeyValueBinding

- (void *)contextForBinding:(NSString *)binding {
    return [binding isEqualToString:NSValueBinding] ? &SSLabelPickerValueObservationContext : NULL;
}

- (Class)valueClassForBinding:(NSString *)binding {
    return [binding isEqualToString:NSValueBinding] ? [NSNumber class] : [super valueClassForBinding:binding];
}

#pragma mark NSKeyValueBindingCreation

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    
    if ([binding isEqualToString:NSValueBinding]) {
        id value = [self valueForBinding:NSValueBinding];
        if ([value isKindOfClass:[NSNumber class]]) {
            super.integerValue = MIN(MAX((NSInteger)floor([value doubleValue]), 0), 5);
        }
    }
}

- (void)unbind:(NSString *)binding {
    [super unbind:binding];
    
    if ([binding isEqualToString:NSValueBinding]) {
        self.integerValue = 0;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &SSLabelPickerValueObservationContext) {
        id value = [self valueForBinding:NSValueBinding];
        if ([value isKindOfClass:[NSNumber class]]) {
            super.integerValue = MIN(MAX(((NSNumber *)value).integerValue, 0), [NSWorkspace sharedWorkspace].fileLabelColors.count);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark getters & setters

- (NSInteger)integerValue {
    id value = [self valueForBinding:NSValueBinding];
    if ([value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)value).integerValue;
    }
    return super.integerValue;
}

- (void)setIntegerValue:(NSInteger)integerValue {
    integerValue = MIN(MAX(integerValue, 0), [NSWorkspace sharedWorkspace].fileLabelColors.count);
    if (self.integerValue == integerValue) {
        return;
    }
    super.integerValue = integerValue;
    [self setValue:@(integerValue) forBinding:NSValueBinding];
    [self setNeedsDisplay];
}

- (CGRect)rectForCellAtIndex:(NSInteger)index {
    NSInteger numberOfCells = [NSWorkspace sharedWorkspace].fileLabelColors.count;
    if (!NSLocationInRange(index, NSMakeRange(0, numberOfCells))) {
        return CGRectZero;
    }
    CGSize cellSize = ((NSCell *)self.cell).cellSize;
    return CGRectIntegral(CGRectMake((index % numberOfCells) * cellSize.width, CGRectGetMaxY(self.bounds) - (cellSize.height*(CGFloat)1.5), cellSize.width, cellSize.height));
}

- (NSInteger)indexOfCellAtPoint:(NSPoint)point {
    NSInteger numberOfCells = [NSWorkspace sharedWorkspace].fileLabelColors.count;
    if (numberOfCells) {
        NSInteger idx = 0;
        while (idx < numberOfCells) {
            if (NSPointInRect(point, [self rectForCellAtIndex:idx])) {
                return idx;
            }
            idx ++;
        }
    }
    return NSNotFound;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
