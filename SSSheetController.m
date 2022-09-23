//
//  SSSheetController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/06/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSheetController.h"
#import "SSToolbarPane.h"
#import "SSStatusBar.h"
#import "NSApplication+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSBase/SSGeometry.h>
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSArray+SSAdditions.h>

#define kSCSelectedToolbarItemIdentifierKey [NSString stringWithFormat:@"%@ Selected ToolbarItem Identifier", NSStringFromClass(self.class)]

@interface SSSheetController () 

@end

@implementation SSSheetController

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
	_delegate = nil;
    _currentPane = nil;
    _parentWindow = nil;
    _statusBar = nil;
    
    [_window release];
    [_toolbarPanes release];

	[super ss_dealloc];
}

- (void)awakeFromNib {
    /*
    _statusBar.backgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.71 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1.0]] autorelease];
    _statusBar.alternateBackgroundGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.81 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.89 alpha:1.0]] autorelease];
    [_statusBar setInsetColor:[NSColor colorWithCalibratedWhite:0.88 alpha:1.0] forEdge:NSMaxYEdge];
    [_statusBar setBorderColor:[NSColor colorWithCalibratedWhite:0.47 alpha:1.0] forEdge:NSMaxYEdge];
     */
}

- (void)close {
    if (_parentWindow.isVisible) {
        if (_parentWindow.attachedSheet == _window) {
            [_window orderOut:self];
#if defined(__MAC_10_9)
            [_parentWindow endSheet:_window];
#else
            [NSApp endSheet:_window];
#endif
        }
    } else {
        [_window close];
    }  
}

#pragma mark actions

- (IBAction)open:(id)sender {
    if (!_window) {
        NSLog(@"%@ %@, ignoring, no window…", self, NSStringFromSelector(_cmd));
        return;
    }
    
	NSWindow *attachedSheet = _parentWindow.attachedSheet;
    if (attachedSheet == _window) {
        return;
    }
    
	if (!_parentWindow.isVisible) {
        NSLog(@"%@ %@, Warning!, parent window not visible or nil…", self, NSStringFromSelector(_cmd));
		return;
	}
    
	_terminationStatus = 1;
    
    if (attachedSheet) {
        [attachedSheet orderOut:nil];
#if defined(__MAC_10_9)
        [_parentWindow endSheet:attachedSheet];
#else
        [NSApp endSheet:attachedSheet];
#endif
	}
	
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        _window.appearance = _parentWindow.appearance;
        [_parentWindow beginSheet:_window completionHandler:nil];
    }
#else
    [NSApp beginSheet:_window modalForWindow:_parentWindow modalDelegate:nil didEndSelector:nil contextInfo:nil];
#endif
}

- (IBAction)ok:(id)sender {
	_terminationStatus = 1;
    
    [self _endSheet];
}

- (IBAction)cancel:(id)sender {
	_terminationStatus = 0;
    [self _endSheet];
}

#if NS_BLOCKS_AVAILABLE

- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger response))handler {
    self.parentWindow = window;
    
#if defined(__MAC_10_9)
    [window beginSheet:_window completionHandler:handler];
#else
    [NSApp beginSheet:_window modalForWindow:window didEndBlock:handler];
#endif
}

#endif

#pragma mark SSButtonValidations

- (BOOL)validateButton:(id <SSValidatedButton>)button {
	return YES;
}

#pragma mark NSToolbar

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	NSMutableArray *identifiers = [NSMutableArray array];
    for (id toolbarPane in _toolbarPanes) {
        [identifiers addObject:[toolbarPane identifier]];
    }
    
	return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return @[];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	id toolbarPane = [self toolbarPaneForIdentifier:itemIdentifier];
	if (!toolbarPane)
		return [item autorelease];
	
    item.label = [toolbarPane title];
    item.image = [toolbarPane icon];
    item.target = self;
    item.action = @selector(_selectToolbarItem:);
    
	return [item autorelease];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return [self toolbarAllowedItemIdentifiers:toolbar];
}

#pragma mark private methods

- (void)_setupToolbarIfNeeded {
    if (_window.toolbar)
        return;
    
	NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%@ToolbarIdentifier", NSStringFromClass(self.class)]] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.allowsUserCustomization = NO;
    toolbar.delegate = self;
    toolbar.autosavesConfiguration = NO;
    
    _window.toolbar = toolbar;
}

- (void)_selectToolbarItem:(NSToolbarItem *)item {
	if (![item isKindOfClass:[NSToolbarItem class]])
        return;
	
	id toolbarPane = [self toolbarPaneForIdentifier:item.itemIdentifier];
	if (!toolbarPane)
        return;
    
	//NSLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    self.currentPane = toolbarPane;
}

- (void)_endSheet {
	if (_delegate && [_delegate respondsToSelector:@selector(sheetControllerShouldEndModalSession:)]) {
        if ([_delegate sheetControllerShouldEndModalSession:self]) {
            [self close];
        }
    } else {
        [self close];
    }
}

#pragma mark getters & setters

- (NSWindow *)window {
    return _window;
}

- (void)setWindow:(NSWindow *)window {
    SSNonAtomicRetainedSet(_window, window);
}

- (NSWindow *)parentWindow {
    return _parentWindow;
}

- (void)setParentWindow:(NSWindow *)parentWindow {
    _parentWindow = parentWindow;
}

- (SSStatusBar *)statusBar {
    return _statusBar;
}

- (void)setStatusBar:(SSStatusBar *)statusBar {
    _statusBar = statusBar;
}

- (NSArray *)toolbarPanes {
    return _toolbarPanes;
}

- (void)setToolbarPanes:(NSArray *)toolbarPanes {
    if ([self.toolbarPanes isEqualToArray:toolbarPanes])
        return;
    
    //NSLog(@"%@ %@%u", self.class, NSStringFromSelector(_cmd), value.count);
    
    SSNonAtomicCopiedSet(_toolbarPanes, toolbarPanes);
    
    if (toolbarPanes) {
        [self _setupToolbarIfNeeded];
    }
    
    NSToolbar *toolbar = _window.toolbar;
    NSInteger itemIndex = (NSInteger)(toolbar.items.count-1);
    while (itemIndex > 0) {
        [toolbar removeItemAtIndex:itemIndex];
        itemIndex--;
    }
    
    for (id <SSToolbarPane> toolbarPane in toolbarPanes) {
        if ([toolbarPane implementsRequiredMethodsInProtocol:@protocol(SSToolbarPane)]) {
            [toolbar insertItemWithItemIdentifier:[toolbarPane identifier] atIndex:(NSInteger)toolbar.items.count];
        }
    }
    
    [toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:0];
    [toolbar insertItemWithItemIdentifier:NSToolbarFlexibleSpaceItemIdentifier atIndex:(NSInteger)toolbar.items.count];
    
    id <SSToolbarPane> defaultPane = [self toolbarPaneForIdentifier:[[NSUserDefaults standardUserDefaults] stringForKey:kSCSelectedToolbarItemIdentifierKey]];
    if (!defaultPane && toolbarPanes.count) {
        defaultPane = (id <SSToolbarPane>) toolbarPanes[0];
    }
    
    self.currentPane = defaultPane;
    
    if (!toolbarPanes.count)
        _window.toolbar = nil;
}

- (id)currentPane {
    return _currentPane;
}

- (void)setCurrentPane:(id)currentPane {
    if (_currentPane == currentPane)
        return;
    
    //NSLog(@"%@ %@%@", self, NSStringFromSelector(_cmd), value);
    
    if (_currentPane) {
        if ([_currentPane respondsToSelector:@selector(shouldBeReplacedByPane:)] && ![_currentPane shouldBeReplacedByPane:currentPane]) {
            (_window.toolbar).selectedItemIdentifier = [_currentPane identifier];
            return;
        }
        
        [[_currentPane view] removeFromSuperview];
        
        _currentPane = nil;
    }
    
    if (currentPane) {
        _currentPane = currentPane;
        
        CGFloat statusBarHeight = _statusBar ? CGRectGetHeight(_statusBar.frame) : 60.0;
        NSView *contentView = _window.contentView;
        NSView *newView = [currentPane view];
        CGRect viewFrame = newView.frame;
        
        CGRect windowFrame = _window.frame;
        CGRect newWindowFrame = [_window frameRectForContentRect:viewFrame];
        newWindowFrame.size.height += statusBarHeight;
        newWindowFrame.origin = windowFrame.origin;
        //newWindowFrame.origin.x = MAX(FLOOR(self.parentWindow.frame.origin.x + ((CGRectGetWidth(self.parentWindow.frame) - CGRectGetWidth(newWindowFrame)) / (CGFloat)2.0)), 0);
        newWindowFrame.origin.x = NSMidX(windowFrame) - (CGRectGetWidth(newWindowFrame)/2);
        newWindowFrame.origin.y -= CGRectGetHeight(newWindowFrame) - CGRectGetHeight(windowFrame);
        
        //NSLog(@"newWindowFrame:%@", NSStringFromRect(newWindowFrame));
        
        [_window setFrame:newWindowFrame display:YES animate:YES];
        
        viewFrame.origin.y = contentView.frame.origin.y + statusBarHeight;
        
        newView.frame = viewFrame;
        
        (_window.toolbar).selectedItemIdentifier = [currentPane identifier];
        _window.title = [currentPane title];
        
        [currentPane viewWillAppear];
        
        [contentView addSubview:newView];
        
        [[NSUserDefaults standardUserDefaults] setObject:[currentPane identifier] forKey:kSCSelectedToolbarItemIdentifierKey];
    }
}

- (NSInteger)terminationStatus {
    return _terminationStatus;
}

- (void)setTerminationStatus:(NSInteger)terminationStatus {
    _terminationStatus = terminationStatus;
}

- (id)toolbarPaneForIdentifier:(NSString *)identifier {
    return [_toolbarPanes firstObjectPassingTest:^BOOL(id obj) {
        return [[obj identifier] isEqualToString:identifier];
    }];
}

@end
