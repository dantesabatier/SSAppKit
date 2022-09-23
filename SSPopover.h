//
//  SSPopover.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/10/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSPopoverAppearance) {
    SSPopoverAppearanceMinimal = 0,
    SSPopoverAppearanceHUD = 1,
};

typedef NS_ENUM(NSInteger, SSPopoverBehavior) {
    SSPopoverBehaviorApplicationDefined = 0,
    SSPopoverBehaviorTransient = 1,
    SSPopoverBehaviorSemitransient = 2
};

@class SSPopover;
@protocol SSPopoverDelegate <NSObject>

@optional
- (BOOL)popoverShouldClose:(SSPopover *)popover;
- (id)detachableWindowForPopover:(SSPopover *)popover;
- (void)popoverWillShow:(NSNotification *)notification;
- (void)popoverDidShow:(NSNotification *)notification;
- (void)popoverWillClose:(NSNotification *)notification;
- (void)popoverDidClose:(NSNotification *)notification;

@end

@class SSPopoverView;
@class SSPopoverWindow;

#if TARGET_OS_IPHONE
@interface SSPopover : UIResponder
#else
@interface SSPopover : NSResponder
#endif 
{
@private
    SSPopoverView *_popoverView;
    SSPopoverWindow *_positioningWindow;
    SSPopoverView *_positioningView;
    id _contentViewController;
    SSPopoverAppearance _appearance;
    SSPopoverBehavior _behavior;
    CGRectEdge _preferredEdge;
    CGSize _contentSize;
    CGRect _positioningRect;
    struct {
        unsigned int animates:1;
        unsigned int shown:1;
        unsigned int closing:1;
    } _flags;
    __ss_weak id <SSPopoverDelegate> _delegate;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSPopoverDelegate> delegate;
#if TARGET_OS_IPHONE
@property (nullable, nonatomic, ss_strong) IBOutlet __kindof UIViewController *contentViewController;
#else
@property (nullable, nonatomic, ss_strong) IBOutlet __kindof NSViewController *contentViewController;
#endif
@property SSPopoverAppearance appearance;
@property SSPopoverBehavior behavior;
@property CGSize contentSize;
@property CGRect positioningRect;
@property BOOL animates;
@property (readonly, getter=isShown) BOOL shown;

- (IBAction)performClose:(nullable id)sender;
#if TARGET_OS_IPHONE
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(__kindof UIView *)positioningView preferredEdge:(CGRectEdge)preferredEdge;
#else
- (void)showRelativeToRect:(CGRect)positioningRect ofView:(__kindof NSView *)positioningView preferredEdge:(NSRectEdge)preferredEdge;
#endif
- (void)close;

@end

extern NSNotificationName SSPopoverWillShowNotification;
extern NSNotificationName SSPopoverDidShowNotification;
extern NSNotificationName SSPopoverWillCloseNotification;
extern NSNotificationName SSPopoverDidCloseNotification;

NS_ASSUME_NONNULL_END
