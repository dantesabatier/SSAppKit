//
//  SSToolbarPane.h
//  SSAppKit
//
//  Created by Dante Sabatier on 10/27/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSViewController.h"

NS_ASSUME_NONNULL_BEGIN

NS_PROTOCOL_REQUIRES_EXPLICIT_IMPLEMENTATION
@protocol SSToolbarPane <SSObject>

@optional
- (BOOL)shouldBeReplacedByPane:(id<SSToolbarPane>)pane;
- (BOOL)windowShouldClose:(NSWindow *)sender;
- (IBAction)showHelp:(nullable id)sender;
@property (nullable, nonatomic, readonly, copy) NSString *helpAnchor;

@required
@property (nonatomic, readonly, copy) NSString *identifier;
@property (nullable, nonatomic, readonly, copy) NSImage *icon;

@end

@interface SSToolbarPane : SSViewController <SSToolbarPane>

@end

NS_ASSUME_NONNULL_END
