//
//  SSDropZoneView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 11/05/14.
//
//

#import "SSAsynchronousImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSDropZoneView : SSAsynchronousImageView {
@private
    CGColorRef _shadowColor;
    CGColorRef _strokeColor;
    CGColorRef _labelColor;
    NSString *_label;
    CGSize _dropZoneSize;
}

@property (nullable, nonatomic, copy) IBInspectable NSString *label;
@property (nullable, nonatomic) CGColorRef strokeColor;
@property (nullable, nonatomic) CGColorRef labelColor;
@property (nullable, nonatomic) CGColorRef shadowColor;
@property (nonatomic) IBInspectable CGSize dropZoneSize;

@end

NS_ASSUME_NONNULL_END

