//
//  SSInspectorHeaderView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <TargetConditionals.h>
#import "SSLayoutView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSInspectorHeaderView : SSLayoutView {
@private
    __ss_weak id _accessoryView;
}

@property (nonatomic, ss_weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSAttributedString *attributedTitle;
@property (nonatomic, strong) NSImage *icon;
@property (nonatomic, ss_weak) NSView *accessoryView;

@end

NS_ASSUME_NONNULL_END
