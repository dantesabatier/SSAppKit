//
//  SSZoomPanel.h
//  SSAppKit
//
//  Created by Dante Sabatier on 21/02/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@class SSZoomPanel;
@protocol SSZoomPanelDelegate <NSWindowDelegate>

@optional
- (CGRect)sourceFrameOnScreenForZoomPanel:(SSZoomPanel *)zoomPanel;
- (nullable NSWindow *)sourceWindowForZoomPanel:(SSZoomPanel *)zoomPanel;

@end

NS_CLASS_AVAILABLE_MAC(10_6)
@interface SSZoomPanel : NSPanel

@property (nullable, ss_weak) id <SSZoomPanelDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
