//
//  SSAlert.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/27/12.
//
//

#import "SSAlert.h"
#import "SSViewController.h"
#import "SSValidatedButton.h"
#import "SSAutomaticallyVerticallyResizingTextField.h"
#import "SSAppKitUtilities.h"
#import "NSApplication+SSAdditions.h"
#import "NSWindow+SSAdditions.h"
#import "NSView+SSAdditions.h"
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSBase/SSGeometry.h>

#define kSSAlertSpacing ((CGFloat)8.0)
#define kSSAlertButtonWidth ((CGFloat)82.0)
#define kSSAlertButtonHeight ((CGFloat)32.0)
#define kSSAlertHelpButtonWidth ((CGFloat)25.0)
#define kSSAlertEdgeOffset ((CGFloat)20.0)
#define kSSAlertBottomOffset ((CGFloat)(kSSAlertButtonHeight + (kSSAlertSpacing*(CGFloat)2.0)))

#define kSSAlertHelpButtonTag ((NSInteger)-3)
#define kSSAlertToggleButtonTag ((NSInteger)-4)

static CGSize const kSSAlertDefaultContentSize = {380.0, 180.0};

@interface SSAlert () <SSButtonValidations> 

@property (nonatomic, readonly, ss_strong) NSWindow *window;
@property (nonatomic, ss_weak) NSWindow *parentWindow;

@end

@implementation SSAlert

+ (instancetype)alertWithContentViewController:(NSViewController *)contentViewController accessoryViewController:(NSViewController *)accessoryViewController defaultButton:(NSString *)defaultButton alternateButton:(NSString *)alternateButton otherButton:(NSString *)otherButton {
    SSAlert *alert = [[SSAlert alloc] init];
    if (defaultButton) {
        [alert addButtonWithTitle:defaultButton];
    }
    
    if (alternateButton) {
        [alert addButtonWithTitle:alternateButton];
    }
        
    if (otherButton) {
        [alert addButtonWithTitle:otherButton];
    }
    
    alert.contentViewController = contentViewController;
    alert.accessoryViewController = accessoryViewController;
    return [alert autorelease];
}

+ (instancetype)alertWithContentViewController:(NSViewController *)contentViewController defaultButton:(NSString *)defaultButton alternateButton:(NSString *)alternateButton otherButton:(NSString *)otherButton {
    return [self alertWithContentViewController:contentViewController accessoryViewController:nil defaultButton:defaultButton alternateButton:alternateButton otherButton:otherButton];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    _delegate = nil;
    _parentWindow = nil;
    
    [_window release];
    [_accessoryViewController release];
    [_contentViewController release];
    [_buttons release];
    [_helpAnchor release];
    
    [super ss_dealloc];
}

- (void)layout {
    NSWindow *window = self.window;
    window.title = _contentViewController.title ? _contentViewController.title : @"";
    
    NSView *backgroundView = window.contentView;
    backgroundView.subviews = @[];
    
    NSView *contentView = _contentViewController.view;
	CGSize contentSize = _contentSize;
    if (SSSizeIsEmpty(contentSize)) {
        contentSize = contentView.frame.size;
    }
        
    if (SSSizeIsEmpty(contentSize)) {
        contentSize = kSSAlertDefaultContentSize;
    }
        
    contentSize.height += kSSAlertBottomOffset;
    
	CGRect contentRect = [window frameRectForContentRect:CGRectMake(CGRectGetMinX(window.frame), CGRectGetMinY(window.frame), contentSize.width, contentSize.height)];
	contentRect.origin.y -= contentRect.size.height - window.frame.size.height;
	
	[window setFrame:contentRect display:YES animate:window.isVisible];
    
    CGRect backgroundRect = backgroundView.frame;
    CGRect statusRect = CGRectMake(CGRectGetMinX(backgroundRect), CGRectGetMinY(backgroundRect), CGRectGetWidth(backgroundRect), kSSAlertBottomOffset);
    CGFloat originX = FLOOR(CGRectGetMaxX(backgroundRect) - kSSAlertEdgeOffset);
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:5];
    [buttons addObjectsFromArray:self.buttons];
    
    if (!buttons.count) {
        [buttons addObject:[self addButtonWithTitle:SSAppKitLocalizedString(@"OK", @"button title")]];
    }
        
    if (_showsHelp) {
        [buttons addObject:[[self newButtonWithTitle:@"" tag:kSSAlertHelpButtonTag] autorelease]];
    }
        
    [buttons sortUsingDescriptors:@[[[[NSSortDescriptor alloc] initWithKey:@"tag" ascending:NO] autorelease]]];
    
    for (NSButton *button in buttons) {
        [button sizeToFit];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.size.width = MAX(CGRectGetWidth(buttonFrame), kSSAlertButtonWidth);
        buttonFrame.origin.y = FLOOR(CGRectGetMidY(statusRect) - (CGRectGetHeight(buttonFrame)*(CGFloat)0.5));
        
        switch (button.tag) {
            case -1:
                if (_showsHelp) {
                    buttonFrame.origin.x = FLOOR((CGRectGetMinX(backgroundRect) + kSSAlertEdgeOffset) + kSSAlertHelpButtonWidth);
                } else {
                    buttonFrame.origin.x = FLOOR((CGRectGetMinX(backgroundRect) + kSSAlertEdgeOffset));
                }
                break;
            case kSSAlertHelpButtonTag:
                buttonFrame.size.width = kSSAlertHelpButtonWidth;
                buttonFrame.origin.x = FLOOR((CGRectGetMinX(backgroundRect) + kSSAlertEdgeOffset));
                break;
            default:
                buttonFrame.origin.x = FLOOR(originX - CGRectGetWidth(buttonFrame));
                break;
        }
        
        button.frame = buttonFrame;
        
        [backgroundView addSubview:button];
        
        originX -= CGRectGetWidth(buttonFrame);
    }
        
    contentView.frame = CGRectMake(CGRectGetMinX(statusRect), CGRectGetMaxY(statusRect), CGRectGetWidth(statusRect), contentSize.height - kSSAlertBottomOffset);
    
    [backgroundView addSubview:contentView];
    
    NSView *accessoryView = _accessoryViewController.view;
    if (accessoryView) {
        NSButton *button = [[self newButtonWithTitle:@"" tag:kSSAlertToggleButtonTag] autorelease];
        button.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin;
        [button sizeToFit];
        
        CGRect buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(FLOOR((CGRectGetMinX(backgroundRect) + kSSAlertEdgeOffset)), CGRectGetMaxY(statusRect));
        
        button.frame = buttonFrame;
        
        [backgroundView addSubview:button];
        
        NSTextField *textField = [[[NSTextField alloc] initWithFrame:SSRectMakeSquare(20)] autorelease];
        textField.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin;
        textField.editable = NO;
        textField.bezeled = NO;
        textField.drawsBackground = NO;
        
        NSTextFieldCell *cell = textField.cell;
        cell.wraps = NO;
        cell.controlSize = NSSmallControlSize;
        cell.font = [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:cell.controlSize]];
        cell.lineBreakMode = NSLineBreakByTruncatingTail;
        
        textField.stringValue = _accessoryViewController.title ? _accessoryViewController.title : @"";
        [textField sizeToFit];
        
        CGRect textFieldFrame = textField.frame;
        textFieldFrame.origin = CGPointMake(CGRectGetMaxX(buttonFrame), CGRectGetMidY(buttonFrame) - (CGRectGetHeight(textField.frame)*(CGFloat)0.5));
        
        textField.frame = textFieldFrame;
        
        [backgroundView addSubview:textField];
    }
}

#pragma mark buttons

- (NSButton *)newButtonWithTitle:(NSString *)title tag:(NSInteger)tag {
    SSValidatedButton *button = [[SSValidatedButton alloc] initWithFrame:CGRectZero];
    button.bezelStyle = NSRoundedBezelStyle;
    button.focusRingType = NSFocusRingTypeNone;
    button.target = self;
    button.title = title;
    button.tag = tag;
    
    switch (tag) {
        case 1:
        case 0:
        case -1:
            button.action = @selector(stopModal:);
            break;
        case kSSAlertHelpButtonTag:
            button.title = @"";
            button.action = @selector(showHelp:);
            button.bezelStyle = NSHelpButtonBezelStyle;
            break;
        case kSSAlertToggleButtonTag:
            button.title = @"";
            button.action = @selector(toggle:);
            button.bezelStyle = NSDisclosureBezelStyle;
            button.buttonType = NSOnOffButton;
            break;
    }
    
    return button;
}

- (NSButton *)addButtonWithTitle:(NSString *)title {
    NSArray *buttons = self.buttons;
    NSUInteger numberOfButtons = buttons.count;
    if (numberOfButtons == 3) {
        return nil;
    }
    
    NSButton *button = nil;
    switch (numberOfButtons) {
        case 0:
#if defined(__MAC_10_9)
            button = [self newButtonWithTitle:title tag:NSModalResponseOK];
#else
            button = [self newButtonWithTitle:title tag:NSOKButton];
#endif
            button.keyEquivalent = @"\r";
            break;
        case 1:
#if defined(__MAC_10_9)
            button = [self newButtonWithTitle:title tag:NSModalResponseCancel];
#else
            button = [self newButtonWithTitle:title tag:NSCancelButton];
#endif
            break;
        case 2:
            button = [self newButtonWithTitle:title tag:-1];
            break;
    }
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:3];
    [set addObjectsFromArray:buttons];
    [set addObject:button];
    
    self.buttons = set.allObjects;
    
    return [button autorelease];
}

#pragma mark actions

- (void)toggle:(id)sender {
    NSWindow *window = self.window;
    NSView *accessoryView = _accessoryViewController.view;
    NSView *backgroundView = window.contentView;
    NSButton *button = [backgroundView viewWithTag:kSSAlertToggleButtonTag];
	CGRect contentViewFrame = backgroundView.frame;
	CGRect windowFrame = window.frame;
	CGRect accessoryViewFrame = accessoryView.frame;
	CGRect referenceFrame = button.frame;
#if defined(__MAC_10_7)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        referenceFrame = [backgroundView convertRectToBacking:referenceFrame];
    }
#else
    referenceFrame = [backgroundView convertRectToBase:referenceFrame];
#endif
	if (![backgroundView.subviews containsObject:accessoryView]) {
        [_accessoryViewController viewWillAppear];
        
		contentViewFrame.size.height += CGRectGetHeight(accessoryViewFrame);
		accessoryViewFrame.origin.y = CGRectGetMinY(referenceFrame) - CGRectGetHeight(accessoryViewFrame);
		
		windowFrame.size.height += CGRectGetHeight(accessoryViewFrame);
		windowFrame.origin.y -= CGRectGetHeight(accessoryViewFrame);
        
        accessoryView.frame = accessoryViewFrame;
        accessoryView.hidden = NO;
        
		[backgroundView addSubview:accessoryView positioned:NSWindowBelow relativeTo:button];
	} else {
        accessoryView.hidden = YES;
		[accessoryView removeFromSuperview];
        
		contentViewFrame.size.height -= CGRectGetHeight(accessoryViewFrame);
		
		windowFrame.size.height -= CGRectGetHeight(accessoryViewFrame);
		windowFrame.origin.y += CGRectGetHeight(accessoryViewFrame);
	}
	
	[window setFrame:windowFrame display:YES animate:window.isVisible];
    
    backgroundView.frame = contentViewFrame;
	[backgroundView displayIfNeeded];
    
    button.state = accessoryView.isHidden ? NSOffState : NSOnState;
}

- (void)showHelp:(id)sender {
    NSString *helpAnchor = self.helpAnchor;
    if (!helpAnchor.length) {
        return;
    }
    
    [[NSHelpManager sharedHelpManager] openHelpAnchor:helpAnchor inBook:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleHelpBookName"]];
}

- (void)stopModal:(id)sender {
    NSInteger returnCode = [sender tag];
    NSWindow *window = self.window;
    [window makeFirstResponder:window];
    if (window.isSheet) {
        [window close];
#if defined(__MAC_10_9)
        [self.parentWindow endSheet:window returnCode:returnCode];
#else
        [NSApp endSheet:window returnCode:returnCode];
#endif
    } else {
        [NSApp stopModalWithCode:returnCode];
    }
}

- (void)performClose:(id)sender {
    [self.window close];
}

- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(void (^)(NSInteger result))handler {
    if (!_contentViewController) {
        self.contentSize = kSSAlertDefaultContentSize;
    }
    
    self.parentWindow = window;
    
    [self layout];
    
    [_contentViewController viewWillAppear];
    [_accessoryViewController viewWillAppear];
    
    [self ss_retain];
    
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        self.window.appearance = window.appearance;
    }
    [window beginSheet:self.window completionHandler:handler];
#else
    [NSApp beginSheet:self.window modalForWindow:window didEndBlock:handler];
#endif
}

#pragma mark SSButtonValidations

- (BOOL)validateButton:(id<SSValidatedButton>)button {
    if (button.tag == kSSAlertHelpButtonTag) {
        return self.helpAnchor.length > 0;
    }
    
    if ([_delegate respondsToSelector:@selector(alert:validateSessionWithModalResponse:)]) {
        return [_delegate alert:self validateSessionWithModalResponse:button.tag];
    }
        
    return YES;
}

#pragma mark getters & setters

- (NSInteger)runModal {
    if (!_contentViewController) {
        self.contentSize = kSSAlertDefaultContentSize;
    }
    
    [self layout];
    
    [_contentViewController viewWillAppear];
    [_accessoryViewController viewWillAppear];
    
    NSWindow *window = self.window;
    window.alphaValue = 1.0;
    
    NSWindow *mainWindow = nil;//((NSApplication *)NSApp).mainWindow;
    if (!mainWindow) {
        [window center];
    } else {
        [window setFrame:SSRectCenteredSize(mainWindow.frame, window.frame.size) display:YES animate:NO];
    }
    
#if defined(__MAC_10_9)
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8) {
        window.appearance = [NSApplication sharedApplication].mainWindow.appearance;
    }
#endif
    
    [window makeKeyAndOrderFront:nil];
	
	NSInteger response = [NSApp runModalForWindow:window];
    [NSAnimationContext currentContext].duration = 0.6;
    (window.animator).alphaValue = 0;
    
    [self performLatestRequestOfSelector:@selector(performClose:) withObject:self afterDelay:[NSAnimationContext currentContext].duration inModes:@[NSRunLoopCommonModes]];
	
	return response;
}

- (NSArray *)buttons {
    return _buttons;
}

- (void)setButtons:(NSArray *)buttons {
    SSNonAtomicCopiedSet(_buttons, buttons);
}

- (id<SSAlerDelegate>)delegate {
    return _delegate;
}

- (void)setDelegate:(id<SSAlerDelegate>)delegate {
    _delegate = delegate;
}

- (NSViewController *)contentViewController {
    return _contentViewController;
}

- (void)setContentViewController:(NSViewController *)contentViewController {
    if (_contentViewController == contentViewController || contentViewController.view == nil) {
        return;
    }
    SSNonAtomicRetainedSet(_contentViewController, contentViewController);
}

- (NSViewController *)accessoryViewController {
    return _accessoryViewController;
}

- (void)setAccessoryViewController:(NSViewController *)accessoryViewController {
    if (_accessoryViewController == accessoryViewController || accessoryViewController.view == nil) {
        return;
    }
    
    SSNonAtomicRetainedSet(_accessoryViewController, accessoryViewController);
    _accessoryViewController.view.hidden = YES;
}

- (CGSize)contentSize {
    return _contentSize;
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
}

- (NSString *)helpAnchor {
    return _helpAnchor;
}

- (void)setHelpAnchor:(NSString *)helpAnchor {
    SSNonAtomicCopiedSet(_helpAnchor, helpAnchor);
}

- (BOOL)showsHelp {
    return _showsHelp;
}

- (void)setShowsHelp:(BOOL)showsHelp {
    _showsHelp = showsHelp;
}

- (NSWindow *)window {
    if (!_window) {
        _window = [[NSWindow alloc] initWithContentRect:CGRectMake(0, 0, 380, 180) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
        _window.releasedWhenClosed = NO;
#if defined(__MAC_10_7)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
            _window.animationBehavior = NSWindowAnimationBehaviorAlertPanel;
#endif
    }
    return _window;
}

- (NSWindow *)parentWindow {
    return _parentWindow;
}

- (void)setParentWindow:(NSWindow *)parentWindow {
    _parentWindow = parentWindow;
}

@end
