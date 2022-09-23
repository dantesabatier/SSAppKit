//
//  SSGradientButtonCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/30/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

enum {
    SSHUDBezelStyle = 1000,
    
};
typedef NSBezelStyle SSBezelStyle;

IB_DESIGNABLE
@interface SSGradientButtonCell : NSButtonCell {
@private
    CGFloat _cornerRadius;
}

@property IBInspectable CGFloat cornerRadius;
@property (nullable, readonly) CGColorRef borderColor;
@property (nullable, readonly) CGColorRef backgroundColor;
@property (nullable, readonly) CGGradientRef backgroundGradient;

@end

extern NSButtonType SSButtonCellGetType(NSButtonCell *self);

NS_ASSUME_NONNULL_END
