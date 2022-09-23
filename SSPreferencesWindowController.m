//
//  SSPreferencesWindowController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 24/02/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSPreferencesWindowController.h"
#import "SSToolbarPane.h"
#import "NSView+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSArray+SSAdditions.h>

#define kPCSelectedToolbarItemIdentifierKey [NSString stringWithFormat:@"%@ Selected ToolbarItem Identifier", NSStringFromClass(self.class)]

@interface SSPreferencesWindowController ()

- (void)selectToolbarItem:(NSToolbarItem *)sender;

@end

static BOOL __kSharedPreferencesControllerCanBeDestroyed = NO;

@implementation SSPreferencesWindowController

static SSPreferencesWindowController * sharedPreferencesWindowController = nil;

+ (instancetype)sharedPreferencesWindowController {
#if defined(__MAC_10_6)
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedPreferencesWindowController = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __kSharedPreferencesControllerCanBeDestroyed = YES;
            [sharedPreferencesWindowController release];
            sharedPreferencesWindowController = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
	return sharedPreferencesWindowController;
}

+ (BOOL)sharedPreferencesWindowControllerExists {
    return sharedPreferencesWindowController != nil;
}

- (instancetype)init {
    NSWindowStyleMask styleMask = 0;
#if defined(__MAC_10_12)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_11) {
        styleMask = NSWindowStyleMaskTitled|NSWindowStyleMaskClosable;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        styleMask = NSTitledWindowMask|NSClosableWindowMask;
#pragma clang diagnostic pop
    }
#else
    styleMask = NSTitledWindowMask|NSClosableWindowMask;
#endif
    NSWindow *window = [[[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 300, 200) styleMask:styleMask backing:NSBackingStoreBuffered defer:YES] autorelease];
    window.showsToolbarButton = NO;
    window.releasedWhenClosed = NO;
    window.oneShot = NO;
    
    self = [super initWithWindow:window];
    if (self) {
        self.window.delegate = self;
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
            self.window.restorable = YES;
        }
#endif
        _preferencePanes = [[NSArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    if ((self == sharedPreferencesWindowController) && !__kSharedPreferencesControllerCanBeDestroyed) {
        return;
    }
    
    self.window.delegate = nil;
    self.window.toolbar.delegate = nil;
    
    [self close];
    
    _currentPane = nil;
    
    [_preferencePanes release];
	
	[super ss_dealloc];
}

- (void)showWindow:(id)sender {
    if (!self.window.frameAutosaveName.length) {
        [self.window center];
        [self.window setFrameAutosaveName:@"Preferences"];
    }
    
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        self.window.appearance = [NSApplication sharedApplication].mainWindow.appearance;
    }
#endif
    
    [super showWindow:sender];
}

#pragma mark NSWindow delegate

- (BOOL)windowShouldClose:(id)sender {
    if ([_currentPane respondsToSelector:@selector(windowShouldClose:)]) {
        return [_currentPane windowShouldClose:sender];
    }
	return YES;
}

#pragma mark NSToolbar

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	NSMutableArray *identifiers = [NSMutableArray array];
	for (id<SSToolbarPane> pane in self.preferencePanes) {
		[identifiers addObject:pane.identifier];
	}
	return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	// We start off with no items. 
	// Add them when we set the toolbarPanes
	return @[];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	id preferencePane = [self preferencePaneForIdentifier:itemIdentifier];
	NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    if (!preferencePane) {
        return item;
    }
	item.label = [preferencePane title];
    item.image = [preferencePane icon];
    item.target = self;
    item.action = @selector(selectToolbarItem:);
	return item;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [self toolbarAllowedItemIdentifiers:toolbar];
}

#pragma mark private methods

- (void)selectToolbarItem:(NSToolbarItem *)sender {
    if (![sender isKindOfClass:[NSToolbarItem class]]) {
        return;
    }
    
	id preferencePane = [self preferencePaneForIdentifier:sender.itemIdentifier];
    if (!preferencePane) {
        return;
    }
    
	self.currentPane = preferencePane;
}

#pragma mark getters & setters

- (NSArray <SSToolbarPane *>*)preferencePanes {
    return _preferencePanes;
}

- (void)setPreferencePanes:(NSArray <SSToolbarPane *>*)preferencePanes {
    if ([_preferencePanes isEqualToArray:preferencePanes]) {
        return;
    }
    
    //NSLog(@"%@ %@%u", self.class, NSStringFromSelector(_cmd), value.count);
    
    SSNonAtomicCopiedSet(_preferencePanes, preferencePanes);
    
	if (preferencePanes) {
        if (!self.window.toolbar) {
            NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%@ToolbarIdentifier", NSStringFromClass(self.class)]] autorelease];
            toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
            toolbar.allowsUserCustomization = NO;
            toolbar.autosavesConfiguration = NO;
            toolbar.delegate = self;
            
            self.window.toolbar = toolbar;
        }
	}
    
	NSToolbar *toolbar = self.window.toolbar;
	NSInteger itemIndex = (NSInteger)(toolbar.items.count-1);
    while (itemIndex > 0) {
        [toolbar removeItemAtIndex:itemIndex];
        itemIndex--;
    }
    
    for (id preferencePane in preferencePanes) {
        [toolbar insertItemWithItemIdentifier:[preferencePane identifier] atIndex:(NSInteger)toolbar.items.count];
    }
    
    id defaultPane = [self preferencePaneForIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:kPCSelectedToolbarItemIdentifierKey]];
    if (!defaultPane && preferencePanes.count) {
        defaultPane = preferencePanes[0];
    }
    
    self.currentPane = defaultPane;
    
    if (!preferencePanes.count) {
        self.window.toolbar = nil;
    }
}

- (SSToolbarPane *)currentPane {
    return _currentPane;
}

- (void)setCurrentPane:(SSToolbarPane *)currentPane {
    if (_currentPane == currentPane) {
        return;
    }
        
	if ([_currentPane respondsToSelector:@selector(shouldBeReplacedByPane:)] && ![_currentPane shouldBeReplacedByPane:currentPane]) {
		self.window.toolbar.selectedItemIdentifier = _currentPane.identifier;
		return;
	}
    
    [_currentPane.view removeFromSuperview];
    
    if (currentPane) {
        _currentPane = currentPane;
        
        CGRect newWindowFrame = [self.window frameRectForContentRect:currentPane.view.frame];
        newWindowFrame.origin = self.window.frame.origin;
        newWindowFrame.origin.y -= newWindowFrame.size.height - self.window.frame.size.height;
        
        if (self.window.isVisible) {
            [self.window setFrame:newWindowFrame display:YES animate:YES];
        } else {
            [self.window setFrame:newWindowFrame display:YES];
        }
        
        self.window.toolbar.selectedItemIdentifier = currentPane.identifier;
        self.window.title = currentPane.title;
        
        [currentPane viewWillAppear];
        [self.window.contentView addSubview:currentPane.view];
        
        [[NSUserDefaults standardUserDefaults] setObject:currentPane.identifier forKey:kPCSelectedToolbarItemIdentifierKey];
    }
}

- (nullable SSToolbarPane *)preferencePaneForIdentifier:(NSString *)identifier {
    return [_preferencePanes firstObjectPassingTest:^BOOL(SSToolbarPane *obj) {
        return [obj.identifier isEqualToString:identifier];
    }];
}

@end
