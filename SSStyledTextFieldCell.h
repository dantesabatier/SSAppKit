//
//  SSStyledTextFieldCell.h
//  SSAppKit
//
//  Created by Dante Sabatier on 1/12/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSStyledTextFieldCell : NSTextFieldCell {
    NSColor *_shadowColor;
    CGSize _shadowOffset;
}

@property (nullable, nonatomic, strong) NSColor *shadowColor;
@property CGSize shadowOffset;

@end

NS_ASSUME_NONNULL_END
