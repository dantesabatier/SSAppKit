//
//  SSModalWindowController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/3/10.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSModalWindowController.h"

@implementation SSModalWindowController

- (instancetype)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6) {
        self.window.animationBehavior = NSWindowAnimationBehaviorAlertPanel;
    }
}

#pragma mark actions

- (IBAction)ok:(id)sender {
	[NSApp stopModalWithCode:1];
}

- (IBAction)cancel:(id)sender {
	[NSApp stopModalWithCode:0];
}

#pragma mark SSButtonValidations

- (BOOL)validateButton:(id <SSValidatedButton>)button {
	return YES;
}

#pragma mark getters & setters

- (NSInteger)runModal {
    NSWindow *window = self.window;
	[window center];
    
	[window makeKeyAndOrderFront:self];
	
	NSInteger response = [NSApp runModalForWindow:window];
	
	[window orderOut:nil];
	
	return response;
}

@end
