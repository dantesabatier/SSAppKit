//
//  UIBarButtonItem+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/04/16.
//
//

#import "UIBarButtonItem+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import <graphics/SSColor.h>
#import <graphics/SSImage.h>
#import <graphics/SSString.h>

#define SSCustomBackBarButtonItemHeight ((CGFloat)25.0)
#define SSCustomBackBarButtonItemBorderWidth ((CGFloat)3.0)
#define SSCustomBackBarButtonItemTitleLeftInset ((CGFloat)20.0)

@implementation UIBarButtonItem (SSAdditions)

- (instancetype)initWithCustomBackBarButtonItemWithTarget:(id)target action:(SEL)action {
    self = [self init];
    if (self) {
        
    }
    return nil;
}

- (instancetype)initWithCustomBackBarButtonItemForViewController:(__kindof UIViewController *)viewController title:(nullable NSString *)title {
    self = [self init];
    if (self) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = nil;
        button.opaque = NO;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, SSCustomBackBarButtonItemTitleLeftInset, 0, 0);
        [button setTitle:title ? title : SSAppKitLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        //[button setTitleColor:viewController.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        button.frame = SSRectMakeWithWidthAndHeight(SSCustomBackBarButtonItemTitleLeftInset + SSStringGetSizeWithFont(button.titleLabel.text, button.titleLabel.font).width, SSCustomBackBarButtonItemHeight);
        [button setBackgroundImage:[[[UIImage imageWithCGImage:SSAutorelease(SSImageCreate(SSSizeScale(button.frame.size, button.scale), ^(CGContextRef __nullable ctx) {
            CGRect boundingBox = CGContextGetClipBoundingBox(ctx);
            CGPathRef background = CGPathCreateWithRect(boundingBox, NULL);
            CGContextAddPath(ctx, background);
            CGContextSetFillColorWithColor(ctx, SSColorGetClearColor());
            CGContextFillPath(ctx);
            CGPathRelease(background);
            CGFloat borderWidth = SSCustomBackBarButtonItemBorderWidth*button.scale;
            CGRect arrowBounds = CGRectInset(boundingBox, borderWidth, borderWidth);
            arrowBounds.size.width = CGRectGetHeight(arrowBounds);
            CGMutablePathRef arrow = CGPathCreateMutable();
            CGContextSetLineWidth(ctx, borderWidth);
            CGPathMoveToPoint(arrow, NULL, CGRectGetMidX(arrowBounds), CGRectGetMinY(arrowBounds));
            CGPathAddLineToPoint(arrow, NULL, CGRectGetMinX(arrowBounds), CGRectGetMidY(arrowBounds));
            CGPathAddLineToPoint(arrow, NULL, CGRectGetMidX(arrowBounds), CGRectGetMaxY(arrowBounds));
            CGContextAddPath(ctx, arrow);
            CGContextSetStrokeColorWithColor(ctx, SSColorGetBlackColor());
            CGContextStrokePath(ctx);
            CGPathRelease(arrow);
        }))] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] imageWithAlignmentRectInsets:button.alignmentRectInsets] forState:UIControlStateNormal];
#if defined(__IPHONE_9_0)
        [button addTarget:viewController action:@selector(dismiss:) forControlEvents:UIControlEventPrimaryActionTriggered];
#else
        [backButton addTarget:viewController action:@selector(dismiss:) forControlEvents:UIControlEventTouchDown];
#endif
        self.customView = button;
    }
    return self;
}

- (instancetype)initWithCustomBackBarButtonItemForViewController:(__kindof UIViewController *)viewController {
    return [self initWithCustomBackBarButtonItemForViewController:viewController title:nil];
}

@end
