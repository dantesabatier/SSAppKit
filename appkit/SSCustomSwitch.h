//
//  SSCustomSwitch.h
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/16.
//
//

#import "SSSwitch.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSCustomSwitch : SSSwitch {
@private;
    void (^_drawingHandler)(CGContextRef __nullable ctx);
}

@property (nullable, nonatomic, copy) void (^drawingHandler)(CGContextRef __nullable ctx);

@end

NS_ASSUME_NONNULL_END
