//
//  SSPreferencesWindowController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 24/02/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSToolbarPane.h"

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_MAC(10_5)
@interface SSPreferencesWindowController : NSWindowController
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1050
<NSWindowDelegate, NSToolbarDelegate>
#endif 
{
@private
    NSArray <SSToolbarPane *>*_preferencePanes;
    SSToolbarPane *_currentPane;
}

@property (class, readonly, strong) SSPreferencesWindowController *sharedPreferencesWindowController NS_AVAILABLE_MAC(10_6);
@property (nonatomic, copy) NSArray <SSToolbarPane *>*preferencePanes;
@property (nullable, nonatomic, strong) SSToolbarPane *currentPane;
- (nullable SSToolbarPane *)preferencePaneForIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
