//
//  SSInspectorItem.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import "SSViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSInspectorItem : SSViewController  {
@private
    NSString *_identifier;
    id _icon;
    id _accessoryView;
}

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, copy) NSImage *icon;
@property (nullable, nonatomic, ss_strong) NSView *accessoryView;

@end

extern NSString *const SSInspectorItemTitleBinding;
extern NSString *const SSInspectorItemIconBinding;

NS_ASSUME_NONNULL_END
