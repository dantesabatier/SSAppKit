//
//  SSSheetController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 17/06/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSValidatedButton.h"
#import <SSBase/SSDefines.h>

@class SSStatusBar;

NS_ASSUME_NONNULL_BEGIN

@class SSSheetController;
@protocol SSSheetControllerDelegate <NSObject>

@optional
- (BOOL)sheetControllerShouldEndModalSession:(SSSheetController *)controller;

@end

NS_CLASS_AVAILABLE(10_5, NA)
@interface SSSheetController : NSObject
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1050
<NSWindowDelegate, NSToolbarDelegate, SSButtonValidations>
#else
<SSButtonValidations>
#endif 
{
@private
    NSArray *_toolbarPanes;
    NSInteger _terminationStatus;
    NSWindow *_window;
    __ss_weak NSWindow *_parentWindow;
    __ss_weak SSStatusBar *_statusBar;
    __ss_weak id _currentPane;
    __ss_weak id <SSSheetControllerDelegate> _delegate;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSSheetControllerDelegate> delegate;
@property (nullable, nonatomic, ss_strong) IBOutlet NSWindow *window;
@property (nullable, nonatomic, ss_weak) IBOutlet NSWindow *parentWindow;
@property (nullable, nonatomic, ss_weak) IBOutlet SSStatusBar *statusBar;
@property (nullable, nonatomic, copy) NSArray *toolbarPanes;
@property (nullable, nonatomic, ss_weak) id currentPane;
@property (nonatomic, readonly, assign) NSInteger terminationStatus;

- (IBAction)open:(nullable id)sender;
- (IBAction)ok:(nullable id)sender;
- (IBAction)cancel:(nullable id)sender;
- (void)close;
- (nullable id)toolbarPaneForIdentifier:(NSString *)identifier;
#if NS_BLOCKS_AVAILABLE
#if defined(__MAC_10_9)
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^ __nullable)(NSModalResponse response))handler NS_AVAILABLE(10_6, NA);
#else
- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^ __nullable)(NSInteger response))handler NS_AVAILABLE(10_6, NA);
#endif
#endif

@end

NS_ASSUME_NONNULL_END
