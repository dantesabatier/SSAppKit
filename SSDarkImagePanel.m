//
//  SSDarkImagePanel.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/08/12.
//
//

#import "SSDarkImagePanel.h"
#import <SSBase/SSDefines.h>

static BOOL __kSharedDarkImagePanelCanBeDestroyed = NO;

@implementation SSDarkImagePanel

static SSDarkImagePanel *sharedDarkImagePanel;

+ (SSDarkImagePanel*)sharedImagePanel
{
#if defined(__MAC_10_6)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDarkImagePanel = [[self alloc] init];
        __block id __unsafe_unretained observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __kSharedDarkImagePanelCanBeDestroyed = YES;
            [sharedDarkImagePanel release];
            sharedDarkImagePanel = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
    return sharedDarkImagePanel;
}

+ (BOOL)sharedImagePanelExists;
{
    return sharedDarkImagePanel != nil;
}

- (instancetype)init
{
    self = [self initWithContentRect:NSMakeRect(0, 0, 300, 300) styleMask:NSTitledWindowMask|NSClosableWindowMask|NSUtilityWindowMask|NSHUDWindowMask backing:NSBackingStoreBuffered defer:YES];
    if (self) {
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            self.titleVisibility = NSWindowTitleHidden;
            self.titlebarAppearsTransparent = YES;
            self.styleMask |= NSFullSizeContentViewWindowMask;
        }
#endif
    }
    return self;
}

- (void)dealloc
{
    if (self == sharedDarkImagePanel && !__kSharedDarkImagePanelCanBeDestroyed)
        return;
    
    [super ss_dealloc];
}

#if 0

- (BOOL)canBecomeKeyWindow
{
    return NO;
}

#endif

@end
