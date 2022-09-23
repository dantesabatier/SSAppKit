//
//  SSRatingIndicator.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/5/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSRatingIndicator.h"
#import "SSAppKitUtilities.h"
#import <SSBase/SSDefines.h>

#define kSSRatingIndicatorNumberOfCells ((NSInteger)5)

static char _SSRatingIndicatorValueObservationContext;

@implementation SSRatingIndicator

+ (void)initialize {
	[self exposeBinding:NSValueBinding];
}

+ (Class)cellClass {
	return [NSButtonCell class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cell = [[[self.class.cellClass alloc] init] autorelease];
        ((NSButtonCell *)self.cell).bezelStyle = NSSmallSquareBezelStyle;
        ((NSButtonCell *)self.cell).imagePosition = NSImageOnly;
        ((NSButtonCell *)self.cell).imageScaling = NSImageScaleProportionallyDown;
        ((NSButtonCell *)self.cell).title = @"";
        ((NSButtonCell *)self.cell).bordered = NO;
        ((NSButtonCell *)self.cell).buttonType = NSToggleButton;
        ((NSButtonCell *)self.cell).image = SSAppKitGetImageResourceNamed(@"Rating_Dot");
        ((NSButtonCell *)self.cell).alternateImage = SSAppKitGetImageResourceNamed(@"Rating_Star");
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.cell = [[[self.class.cellClass alloc] init] autorelease];
        ((NSButtonCell *)self.cell).bezelStyle = NSSmallSquareBezelStyle;
        ((NSButtonCell *)self.cell).imagePosition = NSImageOnly;
        ((NSButtonCell *)self.cell).imageScaling = NSImageScaleProportionallyDown;
        ((NSButtonCell *)self.cell).title = @"";
        ((NSButtonCell *)self.cell).bordered = NO;
        ((NSButtonCell *)self.cell).buttonType = NSToggleButton;
        ((NSButtonCell *)self.cell).image = SSAppKitGetImageResourceNamed(@"Rating_Dot");
        ((NSButtonCell *)self.cell).alternateImage = SSAppKitGetImageResourceNamed(@"Rating_Star");
    }
    return self;
}

- (void)sizeToFit {
    [self setFrameSize:CGSizeMake(18.0*kSSRatingIndicatorNumberOfCells, 18.0)];
}

#pragma mark NSEvent

- (void)mouseDown:(NSEvent *)event {
    if (!self.isEnabled) {
        return;
    }
    BOOL loop = YES, dragging = NO;
    NSPoint hitPoint = [self convertPoint:event.locationInWindow fromView:nil];
	NSPoint mouseLocation;
	while (loop) {
		event = [self.window nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask)];
		mouseLocation = [self convertPoint:event.locationInWindow fromView:nil];
		switch (event.type) {
			case NSLeftMouseDragged: {
				dragging = YES;
                self.integerValue = ([self indexOfCellAtPoint:mouseLocation] + 1);
				break;
			}
			case NSLeftMouseUp: {
				if (!dragging) {
                    NSInteger integerValue = MIN([self indexOfCellAtPoint:hitPoint] + 1, kSSRatingIndicatorNumberOfCells);
                    if (self.integerValue != integerValue) {
                        self.integerValue = integerValue;
                        [self sendAction:self.action to:self.target];
                    }
                }
				loop = NO;
				break;
            }
            default:
                break;
		}
	}
}

- (void)prepareForInterfaceBuilder {
    NSButtonCell *cell = [[[NSButtonCell alloc] init] autorelease];
    cell.bezelStyle = NSSmallSquareBezelStyle;
    cell.imagePosition = NSImageOnly;
    cell.imageScaling = NSImageScaleProportionallyDown;
    cell.title = @"";
    cell.bordered = NO;
    cell.buttonType = NSToggleButton;
    cell.image = SSAppKitGetImageResourceNamed(@"Rating_Dot");
    cell.alternateImage = SSAppKitGetImageResourceNamed(@"Rating_Star");
    self.cell = cell;
    self.integerValue = 2;
}

#pragma mark drawing

- (void)drawRect:(CGRect)rect {
	NSButtonCell *cell = self.cell;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, kSSRatingIndicatorNumberOfCells)];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        cell.state = self.integerValue > idx ? NSOnState : NSOffState;
        [cell drawWithFrame:[self frameOfCellAtIndex:idx] inView:self];
    }];
}

#pragma mark binding

- (void *)contextForBinding:(NSString *)binding {
    if ([binding isEqualToString:NSValueBinding]) {
        return &_SSRatingIndicatorValueObservationContext;
    }
	return NULL;
}

- (Class)valueClassForBinding:(NSString *)binding {
    if ([binding isEqualToString:NSValueBinding]) {
        return [NSNumber class];
    }
	return [super valueClassForBinding:binding];
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
	if (context == &_SSRatingIndicatorValueObservationContext) {
        id value = [self valueForBinding:NSValueBinding];
        if ([value isKindOfClass:[NSNumber class]]) {
            super.integerValue = MIN(MAX((NSInteger)floor([value doubleValue]), 0), 5);
        }
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
	
	[self setNeedsDisplay];
}

#pragma mark getters && setters

- (NSInteger)integerValue {
    id value = [self valueForBinding:NSValueBinding];
    if (!NSIsControllerMarker(value)) {
        return (NSInteger)floor([value doubleValue]);
    }
    return super.integerValue;
}

- (void)setIntegerValue:(NSInteger)integerValue {
    if (self.integerValue == integerValue) {
        return;
    }
    integerValue = MIN(MAX((NSInteger)floor((double)integerValue), 0), 5);
    super.integerValue = integerValue;
	[self setValue:@(integerValue) forBinding:NSValueBinding];
    [self setNeedsDisplay];
}

- (NSImage *)image {
    return [self.cell image];
}

- (void)setImage:(NSImage *)image {
    (self.cell).image = image;
    [self setNeedsDisplay];
}

- (NSImage *)alternateImage {
    return ((NSButtonCell *)self.cell).alternateImage;
}

- (void)setAlternateImage:(NSImage *)alternateImage {
    ((NSButtonCell *)self.cell).alternateImage = alternateImage;
    [self setNeedsDisplay];
}

- (CGRect)frameOfCellAtIndex:(NSInteger)index {
    if (!NSLocationInRange(index, NSMakeRange(0, kSSRatingIndicatorNumberOfCells))) {
        return CGRectZero;
    }
    NSInteger x = index % kSSRatingIndicatorNumberOfCells;
    const CGSize cellSize = {18.0, 18.0};
    return CGRectMake(x * cellSize.width, CGRectGetMidY(self.bounds) - (cellSize.height*(CGFloat)0.5), cellSize.width, cellSize.height);
}

- (NSInteger)indexOfCellAtPoint:(NSPoint)point {
    const CGSize cellSize = {18.0, 18.0};
    point = CGPointMake(FLOOR(point.x / cellSize.width), FLOOR(point.y / cellSize.height));
    return (NSInteger)((point.y * kSSRatingIndicatorNumberOfCells) + point.x);
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)allowsVibrancy {
    return YES;
}

@end
