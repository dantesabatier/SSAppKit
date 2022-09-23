//
//  SSHoverBar.m
//  SSAppKit
//
//  Created by Dante Sabatier on 11/01/16.
//
//

#import "SSHoverBar.h"
#import "SSHoverViewShadowLayer.h"
#import "SSHoverViewSeparatorView.h"
#import <graphics/SSImage.h>

const CGFloat SSHoverBarDefaultItemDimension = 44.0;

@interface SSHoverBar ()

@property (nonnull, nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonnull, nonatomic, strong) SSHoverViewSeparatorView *separatorView;
@property (nonnull, nonatomic, strong) SSHoverViewShadowLayer *shadowLayer;
@property (nullable, nonatomic, copy) NSArray<UIControl *> *controls;

@end

@implementation SSHoverBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)dealloc {
    [_items release];
    [_controls release];
    [_backgroundView release];
    [_separatorView release];
    [_shadowLayer release];
    
    [super ss_dealloc];
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];

    // add shadow layer
    self.shadowLayer = [SSHoverViewShadowLayer layer];
    [self.layer addSublayer:self.shadowLayer];

    // add visual effects view as background
    self.backgroundView = [[[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]] autorelease];
    [self addSubview:self.backgroundView];

    // add separator drawing view on top
    self.separatorView = [[[SSHoverViewSeparatorView alloc] init] autorelease];
    [self addSubview:self.separatorView];

    // set default values
    self.borderColor = [UIColor lightGrayColor];
    self.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    self.cornerRadius = 8.0;
    self.shadowOpacity = 0.25;
    self.shadowColor = [UIColor blackColor];
    self.shadowRadius = 3.0;
}

#pragma mark - Layout

- (CGSize)intrinsicContentSize {
    CGFloat itemLength = SSHoverBarDefaultItemDimension * (CGFloat)self.items.count;
    switch (self.orientation) {
        case SSHoverBarOrientationVertical:
            return CGSizeMake(SSHoverBarDefaultItemDimension, itemLength);

        case SSHoverBarOrientationHorizontal:
            return CGSizeMake(itemLength, SSHoverBarDefaultItemDimension);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat yStep = 0;
    CGFloat xStep = 0;
    
    self.backgroundView.frame = self.bounds;
    self.separatorView.frame = self.bounds;
    self.shadowLayer.frame = self.bounds;

    switch (self.orientation) {
        case SSHoverBarOrientationVertical:
            yStep = SSHoverBarDefaultItemDimension;
            break;

        case SSHoverBarOrientationHorizontal:
            xStep = SSHoverBarDefaultItemDimension;
            break;
    }

    CGRect frame = CGRectMake(0, 0, SSHoverBarDefaultItemDimension, SSHoverBarDefaultItemDimension);
    for (UIControl *control in self.controls) {
        [control setFrame:frame];
        frame = CGRectOffset(frame, xStep, yStep);
    }
}

#pragma mark - Control management

- (void)reloadControls {
    [self resetControls];
    
    NSMutableArray *controls = [NSMutableArray arrayWithCapacity:self.items.count];
    for (UIBarButtonItem *item in self.items) {
        __kindof UIControl *control = nil;
        __kindof UIView *view = item.customView;
        if (!view && [item respondsToSelector:@selector(view)]) {
            view = [item performSelector:@selector(view) withObject:nil];
        }
        
        if (view) {
            if ([view isKindOfClass:[UIControl class]]) {
                control = view;
            } else {
                CGImageRef image = SSAutorelease(SSImageCreateFlipped(SSAutorelease(SSImageCreate(view.bounds.size, ^(CGContextRef  _Nullable ctx) {
                    [view.layer renderInContext:ctx];
                })), true));
                if (image) {
                    control = [UIButton buttonWithType:UIButtonTypeCustom];
                    [control setImage:item.image forState:UIControlStateNormal];
                    [control addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
                }
            }
        } else if (item.image || item.title) {
            control = [UIButton buttonWithType:UIButtonTypeCustom];
            [control setImage:item.image forState:UIControlStateNormal];
            [control setTitle:item.title forState:UIControlStateNormal];
            [control addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (!control) {
            NSLog(@"%@ Warning! Invalid item %@…", NSStringFromClass(self.class), item);
            continue;
        }
        
        [self addSubview:control];
        [controls addObject:control];
    }

    self.controls = controls;
}

- (void)resetControls {
    [self.controls makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.controls = nil;
}

- (SSHoverViewShadowLayer *)shadowLayer {
    return _shadowLayer;
}

- (void)setShadowLayer:(SSHoverViewShadowLayer *)shadowLayer {
    SSNonAtomicRetainedSet(_shadowLayer, shadowLayer);
}

- (SSHoverViewSeparatorView *)separatorView {
    return _separatorView;
}

- (void)setSeparatorView:(SSHoverViewSeparatorView *)separatorView {
    SSNonAtomicRetainedSet(_separatorView, separatorView);
}

- (UIVisualEffectView *)backgroundView {
    return _backgroundView;
}

- (void)setBackgroundView:(UIVisualEffectView *)backgroundView {
    SSNonAtomicRetainedSet(_backgroundView, backgroundView);
}

- (nullable NSArray<UIControl *> *)controls {
    return _controls;
}

- (void)setControls:(nullable NSArray<UIControl *> *)controls {
    if ([_controls isEqualToArray:controls]) {
        return;
    }
    SSNonAtomicCopiedSet(_controls, controls);
    self.separatorView.viewsToSeparate = controls;
}

- (SSHoverBarOrientation)orientation {
    return _orientation;
}

- (void)setOrientation:(SSHoverBarOrientation)orientation {
    if (orientation == _orientation) {
        return;
    }
    
    _orientation = orientation;
    self.separatorView.orientation = orientation;
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (nullable NSArray<UIBarButtonItem *> *)items {
    return _items;
}

- (void)setItems:(nullable NSArray<UIBarButtonItem *> *)items {
    if ([_items isEqualToArray:items]) {
        return;
    }
    
    SSNonAtomicRetainedSet(_items, items);
    
    [self reloadControls];
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.backgroundView.clipsToBounds = (cornerRadius != 0);
    self.backgroundView.layer.cornerRadius = cornerRadius;
    self.shadowLayer.cornerRadius = cornerRadius;
}

- (CGFloat)cornerRadius {
    return self.backgroundView.layer.cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.backgroundView.layer.borderWidth = borderWidth;
    self.separatorView.separatorWidth = borderWidth;
}

- (CGFloat)borderWidth {
    return self.backgroundView.layer.borderWidth;
}

- (void)setBorderColor:(nullable UIColor *)borderColor {
    self.backgroundView.layer.borderColor = borderColor.CGColor;
    self.separatorView.separatorColor = borderColor;
}

- (nullable UIColor *)borderColor {
    return self.backgroundView.layer.borderColor ? [UIColor colorWithCGColor:self.backgroundView.layer.borderColor] : nil;
}

- (nullable UIVisualEffect *)effect {
    return self.backgroundView.effect;
}

- (void)setEffect:(nullable UIVisualEffect *)effect {
    self.backgroundView.effect = effect;
}

- (void)setShadowColor:(nullable UIColor *)shadowColor {
    self.shadowLayer.shadowColor = shadowColor.CGColor;
}

- (nullable UIColor *)shadowColor {
    return self.shadowLayer.shadowColor ? [UIColor colorWithCGColor:self.shadowLayer.shadowColor] : nil;
}

- (void)setShadowRadius:(CGFloat)shadowRadius {
    [self.shadowLayer setShadowRadius:shadowRadius];
}

- (CGFloat)shadowRadius {
    return self.shadowLayer.shadowRadius;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity {
    self.shadowLayer.shadowOpacity = shadowOpacity;
}

- (CGFloat)shadowOpacity {
    return self.shadowLayer.shadowOpacity;
}

@end
