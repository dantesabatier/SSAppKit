//
//  SSInspectorItem.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSInspectorItem.h"
#import <SSBase/SSDefines.h>

NSString *const SSInspectorItemTitleBinding = @"title";
NSString *const SSInspectorItemIconBinding = @"icon";

@implementation SSInspectorItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [NSStringFromClass(self.class) ss_retain];
    }
    return self;
}

- (void)dealloc {
    [_accessoryView release];
    [_identifier release];
    [_icon release];
    
    [super ss_dealloc];
}

- (id)icon {
    return _icon;
}

- (void)setIcon:(id)icon {
    SSNonAtomicCopiedSet(_icon, icon);
}

- (NSString *)identifier {
    return _identifier;
}

- (void)setIdentifier:(NSString *)identifier {
    SSNonAtomicCopiedSet(_identifier, identifier);
}

- (id)accessoryView {
    return _accessoryView;
}

- (void)setAccessoryView:(id)accessoryView {
    SSNonAtomicRetainedSet(_accessoryView, accessoryView);
}

@end


