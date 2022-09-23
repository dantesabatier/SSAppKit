//
//  NSSearchFieldCell+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/11/14.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSearchFieldCell (SSAdditions)

@property (nonatomic, readonly, ss_strong) NSImage *searchButtonCellImage;
@property (nonatomic, readonly, ss_strong) NSImage *cancelButtonCellImage;

@end

NS_ASSUME_NONNULL_END
