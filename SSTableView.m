//
//  SSTableView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2007 Dante Sabatier. All rights reserved.
//

#import "SSTableView.h"
#import "SSAppKitUtilities.h"
#import "NSBezierPath+SSAdditions.h"
#import "NSGradient+SSAdditions.h"
#import "NSMenu+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import "NSImage+SSAdditions.h"
#import <SSBase/SSGeometry.h>
#import <SSGraphics/SSColorSpace.h>
#import <SSGraphics/SSColor.h>
#import <SSFoundation/NSString+SSAdditions.h>
#import <objc/runtime.h>

#define USES_CUSTOM_HIGHLIGHT_COLOR 1

@implementation SSTableView

+ (id)defaultAnimationForKey:(NSString *)key {
    return [NSNull null];
}

#if USES_CUSTOM_HIGHLIGHT_COLOR

+ (void)load {
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            // When swizzling a class method, use the following:
            // Class class = object_getClass((id)self);
            SEL originalSelector = NSSelectorFromString(@"_highlightColorForCell:");
            SEL swizzledSelector = @selector(customHighlightColorForCell:);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            
            if (class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        });
    }
#endif
}

#endif

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        self.verticalMotionCanBeginDrag = NO;
        self.focusRingType = NSFocusRingTypeNone;
	}
	
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.verticalMotionCanBeginDrag = NO;
        self.focusRingType = NSFocusRingTypeNone;
    }
    return self;
}

- (void)dealloc {
	[_alternatingRowBackgroundColors release];
    [_highlightColor release];
	
	[super ss_dealloc];
}

- (void)reloadData {
	[super reloadData];
    
	NSArray *itemArray = self.cornerView.menu.itemArray;
	for (NSMenuItem *item in itemArray) {
        item.state = !((NSTableColumn *)item.representedObject).isHidden;
    }
    
    (self.cornerView.subviews.lastObject).hidden = !itemArray.count;
}

#pragma mark actions

- (IBAction)delete:(id)sender {
	if (!self.canDelete) {
        NSBeep();
        return;
    }
    
    NSIndexSet *indexes = self.selectedRowIndexes;
    if (self.clickedRow != SSTableViewRowNotFound)
        indexes = [NSIndexSet indexSetWithIndex:self.clickedRow];
    [self.dataSource tableView:self removeRowsAtIndexes:indexes];
}

- (IBAction)toggleTableColumnVisibility:(id)sender {
	id column = [sender representedObject];
	if (!column || ![column isKindOfClass:[NSTableColumn class]])
        return;
	
	[column setHidden:![column isHidden]];
	[sender setState:![column isHidden]];
}

#pragma mark events

- (void)keyDown:(NSEvent *)event {
	if ((event.modifierFlags & NSCommandKeyMask) != 0) {
		if (event.keyCode == 51)
            [self delete:self];
        else
            [super keyDown:event];
	} else {
        [super keyDown:event];
    }
}

#pragma mark NSResponder

- (void)centerSelectionInVisibleArea:(id)sender {
	if (!self.selectedRowIndexes.count)
        return;
	
	CGRect visibleRect = self.visibleRect;
	CGRect aRect = [self rectOfRow:self.selectedRowIndexes.lastIndex];
    if (!NSIntersectsRect(aRect, visibleRect)) {
        CGFloat heightDifference = CGRectGetHeight(visibleRect) - CGRectGetHeight(aRect);
        if (heightDifference > 0)
			aRect = NSInsetRect(aRect, 0.0, -(heightDifference / 2.0));
		else
			aRect.size.height = CGRectGetHeight(visibleRect);
		
        [self scrollRectToVisible:aRect];
    }
}

#pragma mark NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)item {
	SEL action = item.action;
    if (action == @selector(deselectAll:)) {
        return self.selectedRowIndexes.count && !self.contentController.avoidsEmptySelection;
    } else if (action == @selector(selectAll:)) {
        return self.allowsMultipleSelection;
    } else if (action == @selector(delete:)) {
        return self.canDelete;
    }
		
	return YES;
}

#pragma mark NSTableView subclass

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend {
    [super selectRowIndexes:indexes byExtendingSelection:extend];
    
    [self centerSelectionInVisibleArea:nil];
}

- (void)drawBackgroundInClipRect:(CGRect)clipRect {
    [NSGraphicsContext saveGraphicsState];
    
	if (self.usesAlternatingRowBackgroundColors) {
        NSArray *alternatingRowBackgroundColors = self.alternatingRowBackgroundColors;
        if (alternatingRowBackgroundColors.count) {
            if (self.needsDisplayWhenWindowResignsKey && !self.window.isActive) {
                alternatingRowBackgroundColors = @[[NSColor colorWithCalibratedWhite:0.965 alpha:1.0], [NSColor colorWithCalibratedWhite:0.91 alpha:1.0]];
            }
            
            [self.backgroundColor setFill];
            NSRectFill(clipRect);
            
            if (alternatingRowBackgroundColors.count > 1) {
                NSArray *numbers = @[@"0", @"2", @"4", @"6", @"8"];
                NSIndexSet *visibleRowIndexes = [NSIndexSet indexSetWithIndexesInRange:[self rowsInRect:clipRect]];
                NSUInteger idx = visibleRowIndexes.firstIndex;
                while (idx != NSNotFound) {
                    @autoreleasepool {
                        CGRect rect = [self rectOfRow:idx];
                        if ([self needsToDrawRect:rect]) {
                            [numbers containsObject:@(idx).stringValue.charactersAsComponents.lastObject] ? [(NSColor *)alternatingRowBackgroundColors[0] setFill] : [(NSColor *)alternatingRowBackgroundColors[1] setFill];
                            NSRectFill(rect);
                        }
                    }
                    idx = [visibleRowIndexes indexGreaterThanIndex:idx];
                }
            }
        } else {
            [super drawBackgroundInClipRect:clipRect];
        }
    } else {
        if (self.window.isActive) {
            [super drawBackgroundInClipRect:clipRect];
        } else {
            if (_extendedFlags.viewHasCustomBackgroundColor) {
                if (self.needsDisplayWhenWindowResignsKey) {
                    [[NSColor windowBackgroundColor] setFill];
                    NSRectFill(clipRect);
                } else {
                    [super drawBackgroundInClipRect:clipRect];
                }
            } else {
                [super drawBackgroundInClipRect:clipRect];
            }
        }
    }
	    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawRow:(NSInteger)row clipRect:(CGRect)clipRect {
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    id <SSTableViewDataSource> dataSource = self.dataSource;
	if ([dataSource respondsToSelector:@selector(tableView:labelColorForRow:)]) {
		NSColor *color = [dataSource tableView:self labelColorForRow:row];
		if (color && ![self isRowSelected:row]) {
			CGRect rowRect = CGRectZero;
			if ([dataSource respondsToSelector:@selector(tableView:labelColorRectOfRow:)])
				rowRect = [dataSource tableView:self labelColorRectOfRow:row];
            if (NSIsEmptyRect(rowRect))
                rowRect = NSInsetRect([self rectOfRow:row], 1.0, 0.0);
			
			[[NSGradient gradientWithBaseColor:color] drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:rowRect radius:CGRectGetHeight(rowRect)/(CGFloat)2.0] angle:90.0];
		}
	}
	
    [super drawRow:row clipRect:clipRect];
    
    [context restoreGraphicsState];
}

#if USES_CUSTOM_HIGHLIGHT_COLOR

- (void)highlightSelectionInClipRect:(CGRect)clipRect {
    if (_extendedFlags.viewHasCustomHighlightColor) {
        NSIndexSet *selectedRowIndexes = self.selectedRowIndexes;
        if (selectedRowIndexes.count) {
            NSColor *highlightColor = self.highlightColor;
            if (!highlightColor) highlightColor = [NSColor alternateSelectedControlColor];
            if (self.needsDisplayWhenWindowResignsKey && ((NSApp.keyWindow != self.window) || (self.window.firstResponder != self)))
                highlightColor = [NSColor secondarySelectedControlColor];
            [highlightColor set];
            
            [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                CGRect rowRect = [self rectOfRow:idx];
                rowRect.size.height -= 1.0;
                
                NSRectFill(rowRect);
            }];
        }
    } else {
        [super highlightSelectionInClipRect:clipRect];
    }
}

- (NSColor *)customHighlightColorForCell:(NSCell *)cell {
    return _extendedFlags.viewHasCustomHighlightColor ? nil : [self customHighlightColorForCell:cell];
}

#endif

#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070

- (NSDraggingSession *)beginDraggingSessionWithItems:(NSArray *)items event:(NSEvent *)event source:(id<NSDraggingSource>)source {
    id <SSTableViewDataSource> dataSource = self.dataSource;
    if (![dataSource respondsToSelector:@selector(tableView:draggingImageForItemAtColumn:row:)]) {
        return [super beginDraggingSessionWithItems:items event:event source:source];
    }
    
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSTableColumn *column = (self.tableColumns)[[self columnAtPoint:location]];
    NSIndexSet *indexes = self.selectedRowIndexes;
    NSInteger clickedRow = self.clickedRow;
    if (clickedRow == SSTableViewRowNotFound) {
        clickedRow = [self rowAtPoint:location];
    }
        
    if (clickedRow != SSTableViewRowNotFound && ![indexes containsIndex:clickedRow]) {
        indexes = [NSIndexSet indexSetWithIndex:clickedRow];
    }
    
    NSIndexSet *visibleIndexes = [NSIndexSet indexSetWithIndexesInRange:[self rowsInRect:self.visibleRect]];
    NSMutableArray *draggingItems = [NSMutableArray arrayWithCapacity:indexes.count];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id writer = [dataSource tableView:self pasteboardWriterForRow:idx];
        if (writer) {
            Class NSDraggingItemClass = NSClassFromString(@"NSDraggingItem");
            id draggingItem = [[[NSDraggingItemClass alloc] initWithPasteboardWriter:writer] autorelease];
            
            NSImage *image = nil;
            CGRect frame = CGRectZero;
            if ([visibleIndexes containsIndex:idx]) {
                image = [dataSource tableView:self draggingImageForItemAtColumn:column row:idx];
                if (image) {
                    if ([dataSource respondsToSelector:@selector(tableView:draggingRectForItemAtColumn:row:)]) 
                        frame = [dataSource tableView:self draggingRectForItemAtColumn:column row:idx];
                    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                        frame.size = [self convertSizeFromBacking:image.size];
                    else
                        frame.size = image.size;
                }
            }
            [draggingItem setDraggingFrame:CGRectIntegral(frame) contents:image];
            [draggingItems addObject:draggingItem];
        }
    }];
    return [super beginDraggingSessionWithItems:draggingItems event:event source:source];
}

#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    NSDragOperation operation = NSDragOperationCopy;
    if (context == NSDraggingContextWithinApplication)
        operation |= NSDragOperationMove;
    else
        operation |= NSDragOperationDelete;
    return operation;
}

#else

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    NSDragOperation operation = NSDragOperationCopy;
    if (isLocal)
        operation |= NSDragOperationMove;
    else
        operation |= NSDragOperationDelete;
    return mask;
}

#endif

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent*)dragEvent offset:(NSPointPointer)dragImageOffset {
    id <SSTableViewDataSource> dataSource = self.dataSource;
    if (![dataSource respondsToSelector:@selector(tableView:draggingImageForItemAtColumn:row:)])
        return [super dragImageForRowsWithIndexes:dragRows tableColumns:tableColumns event:dragEvent offset:dragImageOffset];
    
    NSPoint location = [self convertPoint:dragEvent.locationInWindow fromView:nil];
    NSTableColumn *column = (self.tableColumns)[[self columnAtPoint:location]];
    NSInteger draggingLeaderIndex = self.clickedRow;
    if (!NSLocationInRange(draggingLeaderIndex, NSMakeRange(0, self.numberOfRows)))
        draggingLeaderIndex = [self rowAtPoint:location];
    
    NSInteger numberOfItems = dragRows.count;
    CGFloat spacing = 6.0;
    CGFloat dragginImageRectInset = 32.0;
    NSImage *leadingImage = [dataSource tableView:self draggingImageForItemAtColumn:column row:draggingLeaderIndex];
    CGRect itemFrame = CGRectZero;
    itemFrame.size = leadingImage.size;
    
    __block CGSize cellSize = itemFrame.size;
    NSInteger maxNumberOfItems = 10;
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    [dragRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (indexes.count >= maxNumberOfItems) {
            *stop = YES;
        } else {
            [indexes addIndex:idx];
            
            NSImage *image = [dataSource tableView:self draggingImageForItemAtColumn:column row:idx];
            CGSize imageSize = image.size;
            if (imageSize.height > cellSize.height)
                cellSize.height = imageSize.height;
            if (imageSize.width > cellSize.width)
                cellSize.width = imageSize.width;
        }
    }];
    
    [indexes removeIndex:draggingLeaderIndex];
    
    CGFloat extraSpace = (indexes.count * spacing) + (dragginImageRectInset*(CGFloat)2.0);
    CGSize imageSize = CGSizeMake(FLOOR(cellSize.width + extraSpace), FLOOR(cellSize.height + extraSpace));
    CGRect boundingBox = CGRectZero;
    boundingBox.size = imageSize;
    
    CGRect interiorBox = CGRectIntegral(CGRectInset(boundingBox, dragginImageRectInset, dragginImageRectInset));
    CGRect itemBounds = itemFrame;
    if (numberOfItems > 1) {
        itemBounds.origin = CGPointMake(CGRectGetMinX(interiorBox), FLOOR(CGRectGetMaxY(interiorBox) - CGRectGetHeight(itemBounds)));
    } else {
        itemBounds.origin = CGPointMake(FLOOR(NSMidX(interiorBox) - (CGRectGetWidth(itemBounds) * (CGFloat)0.5)), FLOOR(CGRectGetMidY(interiorBox) - (CGRectGetHeight(itemBounds)*(CGFloat)0.5)));
    }
    
    CGContextRef ctx = SSAutorelease(CGBitmapContextCreate(NULL, CGRectGetWidth(boundingBox), CGRectGetHeight(boundingBox), 8, CGRectGetWidth(boundingBox)*4, SSColorSpaceGetDeviceRGB(), kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Host));
	CGContextSaveGState(ctx);
    {
        CGContextSetShouldAntialias(ctx, true);
        CGContextSetAllowsAntialiasing(ctx, true);
        CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
        CGContextSetShadowWithColor(ctx, CGSizeZero, 3.0, SSColorGetBlackColor());
        
        CGContextSaveGState(ctx);
        {
            CGContextSetAlpha(ctx, 0.99);
            CGContextBeginTransparencyLayer(ctx, NULL);
            
            __block NSPoint origin = CGPointMake(FLOOR(CGRectGetMaxX(interiorBox) - CGRectGetWidth(itemBounds)), CGRectGetMinY(interiorBox));
            [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL *stop) {
                NSImage *itemImage = [dataSource tableView:self draggingImageForItemAtColumn:column row:idx];
                CGImageRef imageRef = [itemImage CGImageForProposedRect:NULL context:nil hints:nil];
                CGContextSetShadowWithColor(ctx, CGSizeZero, 3.0, SSColorGetBlackColor());
                CGContextDrawImage(ctx, CGRectMake(origin.x, origin.y, itemImage.size.width, itemImage.size.height), imageRef);
                
                origin.x -= spacing;
                origin.y += spacing;
            }];
            
            CGImageRef imageRef = [leadingImage CGImageForProposedRect:NULL context:nil hints:nil];
            CGContextSetShadowWithColor(ctx, CGSizeZero, 3.0, SSColorGetBlackColor());
            CGContextDrawImage(ctx, itemBounds, imageRef);
            
            CGContextEndTransparencyLayer(ctx);
        }
        
        CGContextRestoreGState(ctx);
        
        if (numberOfItems > 1) {
            CGFloat scaleFactor = self.scale;
            CGImageRef badge = SSAutorelease(SSImageCreateBadgeWithLabel(@(numberOfItems).stringValue, [NSFont boldSystemFontOfSize:11.0*scaleFactor], 0.0));
            CGRect badgeRect = boundingBox;
            badgeRect.size = SSImageGetSize(badge);
            badgeRect.origin = CGPointMake(FLOOR(CGRectGetMinX(boundingBox) + spacing), FLOOR(CGRectGetMaxY(boundingBox) - (CGRectGetHeight(badgeRect) + spacing)));
            
            CGContextSaveGState(ctx);
            {
                CGContextSetShadow(ctx, CGSizeMake(1.0, -1.0), 3.0);
                CGContextDrawImage(ctx, badgeRect, badge);
            }
            CGContextRestoreGState(ctx);
        }
    }
	CGContextRestoreGState(ctx);
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        imageSize = [self convertSizeFromBacking:imageSize];
    return [[[NSImage alloc] initWithCGImage:SSAutorelease(CGBitmapContextCreateImage(ctx)) size:imageSize] autorelease];
}

#pragma mark NSView

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToWindow {
    if (!self.window)
        return;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
}

#pragma mark getters & setters

- (id <SSTableViewDelegate>)delegate {
    return (id<SSTableViewDelegate>)super.delegate;
}

- (void)setDelegate:(id<SSTableViewDelegate>)delegate {
    super.delegate = delegate;
}

- (id <SSTableViewDataSource>)dataSource {
    return (id<SSTableViewDataSource>)super.dataSource;
}

- (void)setDataSource:(id<SSTableViewDataSource>)aSource {
    super.dataSource = aSource;
    
    if (!aSource)
        return;
    
    if ([aSource respondsToSelector:@selector(tableViewWantsCornerViewMenu:)]) {
        if ([aSource tableViewWantsCornerViewMenu:self])
            self.cornerView.menu = self.headersMenu;
    }
    else
        self.cornerView.menu = self.headersMenu;
}

- (NSArray *)alternatingRowBackgroundColors {
    return _alternatingRowBackgroundColors;
}

- (void)setAlternatingRowBackgroundColors:(NSArray *)alternatingRowBackgroundColors {
    if ([_alternatingRowBackgroundColors isEqualToArray:alternatingRowBackgroundColors])
        return;
	
	SSNonAtomicCopiedSet(_alternatingRowBackgroundColors, alternatingRowBackgroundColors);
	
    [self setNeedsDisplay];
}

- (NSColor *)highlightColor {
    return _highlightColor;
}

- (void)setHighlightColor:(NSColor *)highlightColor {
    SSNonAtomicRetainedSet(_highlightColor, highlightColor);
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
#if USES_CUSTOM_HIGHLIGHT_COLOR
        _extendedFlags.viewHasCustomHighlightColor = 1;
        [self setNeedsDisplay];
#endif
    }
}

- (void)setBackgroundColor:(NSColor *)color {
    _extendedFlags.viewHasCustomBackgroundColor = color ? 1 : 0;
    
    super.backgroundColor = color;
    
    [self setNeedsDisplay];
}

- (NSMenu *)headersMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    
    id <SSTableViewDataSource> dataSource = self.dataSource;
	NSArray *tableColumns = self.tableColumns;
	for (NSTableColumn *tableColumn in tableColumns) {
        if ([dataSource respondsToSelector:@selector(tableView:shouldAddMenuItemForColumn:)] && ![dataSource tableView:self shouldAddMenuItemForColumn:tableColumn])
            continue;
            
		NSString *title = nil;
		if ([dataSource respondsToSelector:@selector(tableView:menuItemTitleForColumn:)])
			title = [dataSource tableView:self menuItemTitleForColumn:tableColumn];
		
		if (!title.length)
            title = (tableColumn.headerCell).stringValue;
		if (!title.length)
            continue;
		
		BOOL enabled = YES;
		if ([dataSource respondsToSelector:@selector(tableView:shouldAllowTogglingColumn:)])
			enabled = [dataSource tableView:self shouldAllowTogglingColumn:tableColumn];
		
		NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        item.target = self;
        item.action = @selector(toggleTableColumnVisibility:);
        item.state = !tableColumn.isHidden;
        item.title = title;
        item.enabled = enabled;
        item.representedObject = tableColumn;
        
		[menu addItem:item];
    }
    
    return [menu  autorelease];
}

- (NSMenu *)sortMenu {
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    
    NSSortDescriptor *descriptor = nil;
    if (self.sortDescriptors.count)
        descriptor = (self.sortDescriptors)[0];
    
    NSArray *items = self.cornerView.menu.itemArray;
    if (!items.count)
        items = self.headersMenu.itemArray;
    
    for (NSMenuItem *item in items) {
        NSTableColumn *column = item.representedObject;
        NSMenuItem *copy = [[item copy] autorelease];
        copy.target = nil;
        copy.action = NULL;
        copy.state = [descriptor.key isEqualToString:column.sortDescriptorPrototype.key];
        copy.enabled = !column.isHidden;
        
        [menu addItem:copy];
    }
    
    if (menu.numberOfItems) {
        [menu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        item.state = !descriptor;
        item.title = SSAppKitLocalizedString(@"None", @"");
        item.enabled = YES;
        
        [menu addItem:item];
    }
    
    return [menu  autorelease];
}

- (BOOL)canDelete {
    id <SSTableViewDataSource> dataSource = self.dataSource;
    if (dataSource) {
        NSIndexSet *indexes = self.selectedRowIndexes;
        if (self.clickedRow != SSTableViewRowNotFound)
            indexes = [NSIndexSet indexSetWithIndex:self.clickedRow];
        if ([dataSource respondsToSelector:@selector(tableView:shouldRemoveRowsAtIndexes:)])
            return [dataSource tableView:self shouldRemoveRowsAtIndexes:indexes];
        return [dataSource respondsToSelector:@selector(tableView:removeRowsAtIndexes:)];
    }
	return NO;
}

@end
