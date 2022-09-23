//
//  SSPopoverPresenterController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/16.
//
//

#import <UIKit/UIKit.h>
#import <base/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSPopoverArrowDirection) {
    SSPopoverArrowDirectionUp = 1UL << 0,
    SSPopoverArrowDirectionDown = 1UL << 1,
    SSPopoverArrowDirectionLeft = 1UL << 2,
    SSPopoverArrowDirectionRight = 1UL << 3,
};

@class SSPopover;
@protocol SSPopoverPresenterControllerDelegate;

@interface SSPopoverPresenterController : UIViewController {
    SSPopover *_popover;
    id <SSPopoverPresenterControllerDelegate> _delegate;
    SSPopoverArrowDirection _permittedArrowDirections;
    __kindof UIView *_sourceView;
    CGRect _sourceRect;
    SSPopoverArrowDirection _arrowDirection;
}

- (instancetype)initWithContentViewController:(__kindof UIViewController *)contentViewController;
@property (nonatomic, readonly, ss_strong) __kindof UIViewController *contentViewController;
@property (nullable, nonatomic, ss_weak) id <SSPopoverPresenterControllerDelegate> delegate;
@property (nonatomic, assign) SSPopoverArrowDirection permittedArrowDirections;
@property (nullable, nonatomic, ss_strong) __kindof UIView *sourceView;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, readonly) SSPopoverArrowDirection arrowDirection;

@end

@protocol SSPopoverPresenterControllerDelegate <NSObject>

@end

NS_ASSUME_NONNULL_END
