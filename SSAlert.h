//
//  SSAlert.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/27/12.
//
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class SSAlert;
@protocol SSAlerDelegate <NSObject>

@optional
#if defined(__MAC_10_9)
- (BOOL)alert:(SSAlert *)alert validateSessionWithModalResponse:(NSModalResponse)response;
#else
- (BOOL)alert:(SSAlert *)alert validateSessionWithModalResponse:(NSInteger)response;
#endif

@end

@interface SSAlert : NSObject {
@private
    NSWindow *_window;
    NSWindow *_parentWindow;
    NSViewController *_contentViewController;
    NSViewController *_accessoryViewController;
    NSArray *_buttons;
    CGSize _contentSize;
    NSString *_helpAnchor;
    BOOL _showsHelp;
    __ss_weak id <SSAlerDelegate> _delegate;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSAlerDelegate> delegate;
@property (nullable, nonatomic, ss_strong) IBOutlet NSViewController *contentViewController;
@property (nullable, nonatomic, ss_strong) IBOutlet NSViewController *accessoryViewController;
@property (nullable,nonatomic, copy) NSString *helpAnchor;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL showsHelp;
@property (nullable, nonatomic, readonly, ss_strong) NSArray <NSButton*> *buttons;
#if defined(__MAC_10_9)
@property (nonatomic, readonly) NSModalResponse runModal;
#else
@property (nonatomic, readonly) NSInteger runModal;
#endif

+ (instancetype)alertWithContentViewController:(NSViewController *)contentViewController accessoryViewController:(nullable NSViewController *)accessoryViewController defaultButton:(NSString *)defaultButton alternateButton:(nullable NSString *)alternateButton otherButton:(nullable NSString *)otherButton;
+ (instancetype)alertWithContentViewController:(NSViewController *)contentViewController defaultButton:(NSString *)defaultButton alternateButton:(nullable NSString *)alternateButton otherButton:(nullable NSString *)otherButton;
#if NS_BLOCKS_AVAILABLE
#if defined(__MAC_10_9)
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^ __nullable)(NSModalResponse response))handler NS_AVAILABLE(10_6, NA);
#else
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^ __nullable)(NSInteger response))handler NS_AVAILABLE(10_6, NA);
#endif
#endif
- (nullable NSButton *)addButtonWithTitle:(NSString *)title;
- (void)layout;

@end

NS_ASSUME_NONNULL_END
