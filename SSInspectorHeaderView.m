//
//  SSInspectorHeaderView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSInspectorHeaderView.h"
#import "SSInspectorCell.h"
#import "SSValidatedButton.h"
#import <SSBase/SSGeometry.h>

#define kSSInspectorHeaderViewButtonTag 5667
#define kSSInspectorHeaderViewImageViewTag 5668
#define kSSInspectorHeaderViewTextFieldTag 5669

#define kHVImageSpacing ((CGFloat) 2.0)
#define kHVRightMargin ((CGFloat) 5.0)
#define kHVDisclosureTriangleSpace ((CGFloat) 5.0)

@interface SSInspectorHeaderViewDisclosureButton : SSValidatedButton

@end

@implementation SSInspectorHeaderViewDisclosureButton

- (BOOL)allowsVibrancy {
    return YES;
}

@end

@implementation SSInspectorHeaderView

#pragma mark life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        SSInspectorHeaderViewDisclosureButton *button = [[[SSInspectorHeaderViewDisclosureButton alloc] initWithFrame:CGRectMake(0, 0, 20.0, 17.0)] autorelease];
        button.tag = kSSInspectorHeaderViewButtonTag;
        button.bezelStyle = NSDisclosureBezelStyle;
        button.buttonType = NSOnOffButton;
        button.title = @"";
        button.focusRingType = NSFocusRingTypeNone;
        ((NSButtonCell *)button.cell).controlSize = NSSmallControlSize;
        
        [self addSubview:button];
        
        NSImageView *imageView = [[[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 16.0, 16.0)] autorelease];
        imageView.tag = kSSInspectorHeaderViewImageViewTag;
        imageView.editable = NO;
        imageView.animates = NO;
        imageView.enabled = YES;
        imageView.imageFrameStyle = NSImageFrameNone;
        imageView.imageScaling = NSImageScaleProportionallyDown;
        imageView.allowsCutCopyPaste = NO;
        imageView.imageAlignment = NSImageAlignCenter;
        imageView.hidden = YES;
        
        [self addSubview:imageView];
        
        NSTextField *textField = [[[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 16.0, 16.0)] autorelease];
        textField.tag = kSSInspectorHeaderViewTextFieldTag;
        textField.editable = NO;
        textField.bezeled = NO;
        textField.drawsBackground = NO;
        
        NSTextFieldCell *cell = textField.cell;
        cell.editable = NO;
        cell.bezeled = NO;
        cell.drawsBackground = NO;
        cell.wraps = NO;
        cell.textColor = [NSColor blackColor];
        cell.controlSize = NSSmallControlSize;
        cell.font = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:cell.controlSize]];
        cell.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [self addSubview:textField];
    }
    return self;
}

- (void)dealloc {
    _accessoryView = nil;
    
    [super ss_dealloc];
}

- (void)layout {
    [super layout];
    if (!((SSInspectorCell *)self.superview).isAnimating) {
        if ([_accessoryView respondsToSelector:@selector(sizeToFit)]) {
            [(id)_accessoryView sizeToFit];
        }
        
        CGFloat spacing = 3.0;
        __block CGFloat origin = spacing;
        __block CGFloat availableSpace = CGRectGetWidth(self.bounds) - (spacing*(CGFloat)2.0);
        CGRect bounds = self.bounds;
        CGRect (^proposedFrameForView)(NSView *view) = ^CGRect(NSView *view) {
            if ([view respondsToSelector:@selector(sizeToFit)] && ![view isKindOfClass:[NSImageView class]]) {
                [(id)view sizeToFit];
            }
            
            CGRect frame = CGRectZero;
            if (view) {
                if (!view.isHidden) {
                    frame = view.frame;
                    frame.size = CGSizeMake(MIN(CGRectGetWidth(view.frame), availableSpace), MIN(CGRectGetHeight(view.frame), CGRectGetHeight(bounds) - 2.0));
                    frame.origin = CGPointMake(FLOOR(origin), FLOOR(CGRectGetMidY(bounds) - (CGRectGetHeight(frame)*(CGFloat)0.5)));
                }
                
                origin += CGRectIsEmpty(frame) ? 0 : CGRectGetWidth(frame) + spacing;
                
                availableSpace -= origin;
            }
            
            return frame;
        };
        
        NSArray <NSView*>*views = @[[self viewWithTag:kSSInspectorHeaderViewButtonTag], [self viewWithTag:kSSInspectorHeaderViewImageViewTag], [self viewWithTag:kSSInspectorHeaderViewTextFieldTag]];
        for (NSView *view in views) {
            view.frame = proposedFrameForView(view);
        }
        
        CGRect frame = proposedFrameForView(_accessoryView);
        frame.origin.x = CGRectGetMaxX(bounds) - CGRectGetWidth(frame) - spacing;
        ((NSView *)_accessoryView).frame = frame;
    }
}

#pragma mark NSEvent

- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        NSButton *button = [self viewWithTag:kSSInspectorHeaderViewButtonTag];
        [button sendAction:button.action to:button.target];
        button.state = !button.state;
    }
}

#pragma mark getters & setters

- (id)target {
    return ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).target;
}

- (void)setTarget:(id)target {
    ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).target = target;
}

- (SEL)action {
    return ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).action;
}

- (void)setAction:(SEL)action {
    ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).action = action;
}

- (NSInteger)state {
    return ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).state;
}

- (void)setState:(NSInteger)state {
    ((NSButton *)[self viewWithTag:kSSInspectorHeaderViewButtonTag]).state = state;
}

- (NSString *)title {
    return ((NSTextField *)[self viewWithTag:kSSInspectorHeaderViewTextFieldTag]).stringValue;
}

- (void)setTitle:(NSString *)title {
    ((NSTextField *)[self viewWithTag:kSSInspectorHeaderViewTextFieldTag]).stringValue = title;
    [self layout];
}

- (NSAttributedString *)attributedTitle {
    return ((NSTextField *)[self viewWithTag:kSSInspectorHeaderViewTextFieldTag]).attributedStringValue;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    ((NSTextField *)[self viewWithTag:kSSInspectorHeaderViewTextFieldTag]).attributedStringValue = attributedTitle;
    [self layout];
}

- (id)icon {
    return ((NSImageView *)[self viewWithTag:kSSInspectorHeaderViewImageViewTag]).image;
}

- (void)setIcon:(id)icon {
    NSImageView *imageView = [self viewWithTag:kSSInspectorHeaderViewImageViewTag];
    imageView.image = icon;
    imageView.frame = SSRectMakeSquare(16.0);
    imageView.hidden = (icon == nil);
    
    [self layout];
}

- (id)accessoryView {
    return _accessoryView;
}

- (void)setAccessoryView:(id)accessoryView {
    if ([_accessoryView isEqual:accessoryView]) {
        return;
    }
    
    [_accessoryView removeFromSuperview];
    _accessoryView = accessoryView;
    
    if (accessoryView && ![self.subviews containsObject:accessoryView]) {
        [self addSubview:accessoryView];
    }
    
    [self layout];
}

@end
