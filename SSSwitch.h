//
//  SSSwitch.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSControl.h"

NS_ASSUME_NONNULL_BEGIN

NS_CLASS_AVAILABLE(10_6, NA)
@interface SSSwitch : SSControl {
@private
    NSString *_title;
    NSString *_alternateTitle;
    CGFloat _offset;
}

@property (nullable, nonatomic, ss_strong) NSString *title;
@property (nullable, nonatomic, ss_strong) NSString *alternateTitle;
#if defined(__MAC_10_14)
@property (nonatomic, readonly) NSControlStateValue state;
#else
@property (nonatomic, readonly) NSCellStateValue state;
#endif
@property (nonatomic, assign) NSBezelStyle bezelStyle;

@end

NS_ASSUME_NONNULL_END
