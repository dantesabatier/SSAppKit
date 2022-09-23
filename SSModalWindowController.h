//
//  SSModalWindowController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 6/3/10.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "SSValidatedButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSModalWindowController : NSWindowController <SSButtonValidations>

#if defined(__MAC_10_9)
@property (nonatomic, readonly) NSModalResponse runModal;
#else
@property (nonatomic, readonly) NSInteger runModal;
#endif
- (IBAction)ok:(nullable id)sender;
- (IBAction)cancel:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END
