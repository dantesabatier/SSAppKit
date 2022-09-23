//
//  SSScriptsMenuManager.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/3/10.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSScriptsMenuController.h"
#import "SSAppKitUtilities.h"
#import <SSBase/SSDefines.h>
#import <SSFoundation/NSBundle+SSAdditions.h>
#import <SSFoundation/NSFileManager+SSAdditions.h>
#import <SSFoundation/SSPathUtilities.h>

#define SSAppleScriptMenuItemTag 8000

static BOOL __kSharedScriptsMenuControllerCanBeDestroyed = NO;

@implementation SSScriptsMenuController

static SSScriptsMenuController *sharedScriptsMenuController = nil;

+ (SSScriptsMenuController*)sharedScriptsMenuController {
#if defined(__MAC_10_6)
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedScriptsMenuController = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __kSharedScriptsMenuControllerCanBeDestroyed = YES;
            [sharedScriptsMenuController release];
            sharedScriptsMenuController = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
	return sharedScriptsMenuController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSMutableArray *directories = [NSMutableArray arrayWithCapacity:2];
        [directories addObject:SSApplicationScriptsDirectory()];
        NSString *scriptsDirectory = [[NSBundle mainBundle] pathForResource:@"Scripts" ofType:@""];
        if ([[NSFileManager defaultManager] fileExistsAtPath:scriptsDirectory]) {
            [directories addObject:scriptsDirectory];
        }
        _appleScriptsDirectories = directories.copy;
        _allowedFileTypes = [[NSArray alloc] initWithObjects:@"com.apple.applescript.script", nil];
    }
    return self;
}

- (void)dealloc {
    if (self == sharedScriptsMenuController && !__kSharedScriptsMenuControllerCanBeDestroyed) {
        return;
    }
    
    [_appleScriptsDirectories release];
    [_allowedFileTypes release];
    
    [super ss_dealloc];
}

#pragma mark actions

- (void)openScriptsFolder:(id)sender {
    NSError *error = nil;
    NSString *directory = SSApplicationScriptsDirectory();
    SSCreateDirectoryIfNeeded(directory, &error);
    
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:directory]]];
}

- (void)menuAction:(id)sender {
	NSString *path = [sender representedObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }
    
	if (((NSApp.currentEvent.modifierFlags & NSAlternateKeyMask) != 0)) {
        if (/*[path.stringByDeletingLastPathComponent isEqualToString:SSApplicationScriptsDirectory()]*/YES) {
            [[NSWorkspace sharedWorkspace] openFile:path];
            return;
        }
	}
    
    NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL] autorelease];
    if (appleScript) {
        NSDictionary *error = nil;
        if (![appleScript executeAndReturnError:&error] && error) {
            [NSApp presentError:[NSError errorWithDomain:error[NSAppleScriptErrorAppName] ? error[NSAppleScriptErrorAppName] : @"SSAppKitErrorDomain" code:[error[NSAppleScriptErrorNumber] integerValue] userInfo:@{NSLocalizedFailureReasonErrorKey: error[NSAppleScriptErrorMessage]}]];
        }
    }
}

#pragma mark NSMenu delegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    
    NSArray <NSString *>*allowedFileTypes = self.allowedFileTypes;
    for (NSString *directory in self.appleScriptsDirectories) {
        @autoreleasepool {
            NSURL *baseURL = [NSURL fileURLWithPath:directory];
            [[NSFileManager defaultManager] enumerateContentsOfURL:baseURL includingResourceValuesForKeys:@[NSURLLocalizedNameKey, NSURLParentDirectoryURLKey, NSURLIsHiddenKey, NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLTypeIdentifierKey] usingBlock:^BOOL(NSURL *URL, NSDictionary *resourceValues, NSError *error, BOOL *stop) {
                
                if ([resourceValues[NSURLIsHiddenKey] boolValue]) {
                    return NO;
                }
                
                if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                    if (![resourceValues[NSURLIsPackageKey] boolValue] && ![baseURL isEqualTo:URL]) {
                        NSMenu *submenu = [[[NSMenu alloc] initWithTitle:resourceValues[NSURLLocalizedNameKey]] autorelease];
                        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
                        item.title = submenu.title;
                        item.submenu = submenu;
                        
                        NSString *localizedName = nil;
                        [resourceValues[NSURLParentDirectoryURLKey] getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
                        
                        NSMenu *parentMenu = [menu itemWithTitle:localizedName].submenu;
                        if (!parentMenu) {
                            parentMenu = menu;
                        }
                        
                        [parentMenu addItem:item];
                    }
                    return YES;
                }
                
                for (NSString *fileType in allowedFileTypes) {
                    if ([[NSWorkspace sharedWorkspace] type:resourceValues[NSURLTypeIdentifierKey] conformsToType:fileType]) {
                        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
                        item.title = resourceValues[NSURLLocalizedNameKey];
                        item.representedObject = URL.path;
                        item.target = self;
                        item.action = @selector(menuAction:);
                        
                        NSString *localizedName = nil;
                        [resourceValues[NSURLParentDirectoryURLKey] getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:&error];
                        
                        NSMenu *parentMenu = [menu itemWithTitle:localizedName].submenu;
                        if (!parentMenu) {
                            parentMenu = menu;
                        }
                        
                        [parentMenu addItem:item];
                        break;
                    }
                }
                
                return YES;
            }];
        }
    }
    
    if (menu.itemArray.count) {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    NSMenuItem *item = [[NSMenuItem alloc] init];
    item.title = SSAppKitLocalizedString(@"Open Scripts Folder", @"menu item name");
    item.target = self;
    item.action = @selector(openScriptsFolder:);
    [menu addItem:item];
    [item release];
}

#pragma mark getters & setters

- (NSArray <NSString *>*)appleScriptsDirectories {
    return _appleScriptsDirectories;
}

- (void)setAppleScriptsDirectories:(NSArray <NSString *>*)appleScriptsDirectories {
    SSNonAtomicCopiedSet(_appleScriptsDirectories, appleScriptsDirectories);
}

- (NSArray <NSString *>*)allowedFileTypes {
    return _allowedFileTypes;
}

- (void)setAllowedFileTypes:(NSArray <NSString *>*)allowedFileTypes {
    SSNonAtomicCopiedSet(_allowedFileTypes, allowedFileTypes);
}

- (BOOL)isScriptMenuEnabled {
    return [NSApp.mainMenu itemWithTag:SSAppleScriptMenuItemTag] != nil;
}

- (void)setScriptMenuEnabled:(BOOL)scriptMenuEnabled {
    NSMenu *mainMenu = NSApp.mainMenu;
    NSMenuItem *item = [mainMenu itemWithTag:SSAppleScriptMenuItemTag];
    if (scriptMenuEnabled) {
        if (!item) {
            NSMenu *menu = [[[NSMenu alloc] init] autorelease];
            menu.delegate = self;
            
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            item.tag = SSAppleScriptMenuItemTag;
            item.image = SSAppKitGetImageResourceNamed(@"Scripts");
            item.submenu = menu;
            
            [mainMenu insertItem:item atIndex:MIN((mainMenu.numberOfItems-1), [mainMenu indexOfItemWithSubmenu:NSApp.windowsMenu]+1)];
        }
        return;
    }
    if ([mainMenu.itemArray containsObject:item]) {
        [mainMenu removeItem:item];
    }
}

@end

