//
//  SSPopoverView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 14/10/12.
//
//

#import "SSPopoverView.h"
#import "SSPopover.h"
#if TARGET_OS_IPHONE
#import <graphics/SSColor.h>
#import <graphics/SSPath.h>
#import "UIView+SSAdditions.h"
#else
#import <SSGraphics/SSColor.h>
#import <SSGraphics/SSPath.h>
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#endif

@implementation SSPopoverView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = SSViewAutoresizingAll;
        self.autoresizesSubviews = YES;
        
        _fillColor = SSColorCreateDeviceGray(0.909804, 0.909804);
        _borderColor = SSColorCreateDeviceGray(0.909804, 0.33);
        _borderWidth = 1.0;
        _cornerRadius = 6.0;
        _arrowSize = CGSizeMake(20.0, 10.0);
        _arrowPosition = SSRectPositionBottom;
        _rectCorners = SSRectAllCorners;
    }
    
    return self;
}

#if TARGET_OS_IPHONE


#else

- (void)mouseDown:(NSEvent *)event {
    [super mouseDown:event];
}

- (void)mouseDragged:(NSEvent *)event {
    SSPopover *popover = (id)self.window.delegate;
    NSViewController *contentViewController = popover.contentViewController;
    if (!contentViewController) {
        return;
    }
    
    id <SSPopoverDelegate> delegate = (id)popover.delegate;
    if (![delegate respondsToSelector:@selector(detachableWindowForPopover:)]) {
        return;
    }
    
    NSWindow *detachableWindow = [delegate detachableWindowForPopover:popover];
    if (!detachableWindow) {
        return;
    }
    
    NSImage *image = self.imageRepresentation;
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        Class NSPasteboardItemClass = NSClassFromString(@"NSPasteboardItem");
        id pasteboardItem = [[[NSPasteboardItemClass alloc] init] autorelease];
        [pasteboardItem setString:@"popover" forType:@"com.sabatiersoftware.ssappkit.popoverconventview"];
        
        CGRect draggingRect = self.bounds;
        draggingRect.size = image.size;
        
        Class NSDraggingItemClass = NSClassFromString(@"NSDraggingItem");
        id draggingItem = [[[NSDraggingItemClass alloc] initWithPasteboardWriter:pasteboardItem] autorelease];
        [draggingItem setDraggingFrame:draggingRect contents:image];
        
        id session = [self beginDraggingSessionWithItems:@[draggingItem] event:event source:self];
        [session setDraggingFormation:NSDraggingFormationNone];
        [session setAnimatesToStartingPositionsOnCancelOrFail:YES];
    } else {
        CGPoint location = [self convertPoint:event.locationInWindow fromView:nil];
        location.x -= location.x - CGRectGetMinX(self.frame);
        location.y -= location.y - CGRectGetMinY(self.frame);
        
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
        [pasteboard declareTypes:@[@"com.sabatiersoftware.ssappkit.popoverconventview"] owner:self];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self dragImage:image at:location offset:NSZeroSize event:event pasteboard:pasteboard source:self slideBack:YES];
#pragma clang diagnostic pop
    }
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    NSDragOperation operation = NSDragOperationCopy;
    if (context == NSDraggingContextWithinApplication) {
        operation |= NSDragOperationMove;
    } else {
        operation |= NSDragOperationDelete;
    }
    return operation;
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(CGPoint)screenPoint {
    session.animatesToStartingPositionsOnCancelOrFail = CGRectContainsPoint(self.bounds, [self convertPoint:[self.window convertRectFromScreen:SSRectMakeWithPoint(screenPoint)].origin fromView:nil]);
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(CGPoint)screenPoint operation:(NSDragOperation)operation {
    CGPoint location = [self convertPoint:[self.window convertRectFromScreen:SSRectMakeWithPoint(screenPoint)].origin fromView:nil];
    if (CGRectContainsPoint(self.bounds, location)) {
        return;
    }
    
    SSPopover *popover = (id)self.window.delegate;
    id <SSPopoverDelegate> delegate = (id)popover.delegate;
    NSWindow *detachableWindow = [delegate detachableWindowForPopover:popover];
    if (!detachableWindow) {
        return;
    }
    
    NSViewController *contentViewController = popover.contentViewController;
    NSView *contentView = contentViewController.view;
    CGRect destinationFrame = SSRectCenteredAroundPoint(detachableWindow.frame, screenPoint);
    
    [detachableWindow setFrame:destinationFrame display:YES];
    
    CGFloat contentBorder = [detachableWindow contentBorderThicknessForEdge:NSRectEdgeMinY];
    CGRect contentRect = ((NSView *)detachableWindow.contentView).bounds;
    contentRect.size.height -= contentBorder;
    contentRect.origin.y += contentBorder;
    
    contentView.frame = contentRect;
    ((NSView *)detachableWindow.contentView).subviews = @[];
    
    
    [detachableWindow.contentView addSubview:contentView];
    [detachableWindow makeKeyAndOrderFront:nil];
    
    [popover performClose:nil];
    popover.contentViewController = nil;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
    return YES;
}

#endif

#pragma mark getters & setters

- (CGPathRef)path {
    return SSAutorelease(SSPathCreateWithArrow(CGRectInset(self.bounds, _arrowSize.height, _arrowSize.height), _rectCorners, _cornerRadius, _arrowSize, _arrowPosition));
}

- (CGSize)arrowSize {
    return _arrowSize;
}

- (void)setArrowSize:(CGSize)arrowSize {
    if (CGSizeEqualToSize(_arrowSize, arrowSize)) {
        return;
    }
    
    _arrowSize = arrowSize;
    
   [self setNeedsDisplay];
}

- (SSRectPosition)arrowPosition {
    return _arrowPosition;
}

- (void)setArrowPosition:(SSRectPosition)arrowPosition {
    if (_arrowPosition == arrowPosition) {
        return;
    }
    
    _arrowPosition = arrowPosition;
    
    [self setNeedsDisplay];
}

@end
