//
//  SSScriptsMenuManager.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/3/10.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE_MAC(10_6)
@interface SSScriptsMenuController : NSObject <NSMenuDelegate> {
@private
    NSArray <NSString *>*_allowedFileTypes;
    NSArray <NSString *>*_appleScriptsDirectories;
}

@property (class, nonatomic, readonly, ss_strong) SSScriptsMenuController *sharedScriptsMenuController;
@property (nullable, nonatomic, copy) NSArray <NSString *>*appleScriptsDirectories;
@property (nullable, nonatomic, copy) NSArray <NSString *>*allowedFileTypes;
@property (getter=isScriptMenuEnabled) BOOL scriptMenuEnabled;

@end

NS_ASSUME_NONNULL_END
