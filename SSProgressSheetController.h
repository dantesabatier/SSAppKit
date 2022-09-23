//
//  SSProgressSheetController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/23/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSSheetController.h"

NS_ASSUME_NONNULL_BEGIN

@class SSProgressView;

@interface SSProgressSheetController : SSSheetController {
@private
	IBOutlet NSTextField *titleField;
	IBOutlet NSTextField *statusField;
    IBOutlet SSProgressView *progressView;
    BOOL _cancelled;
}

@property (class, readonly, ss_strong) __kindof SSProgressSheetController *sharedProgressSheetController NS_AVAILABLE_MAC(10_6);
@property (nullable, nonatomic, ss_weak) IBOutlet id <SSSheetControllerDelegate> delegate SS_UNAVAILABLE;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *status;
@property (nonatomic) double minValue;
@property (nonatomic) double maxValue;
@property (nonatomic) double doubleValue;
@property (nonatomic, getter = isIndeterminate) BOOL indeterminate;
@property (nonatomic, readonly, getter = isCancelled) BOOL cancelled;
@property (nonatomic, readonly, weak) NSString *nibName;

@end

NS_ASSUME_NONNULL_END
