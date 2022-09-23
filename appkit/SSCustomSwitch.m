//
//  SSCustomSwitch.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/16.
//
//

#import "SSCustomSwitch.h"
#import <graphics/SSContext.h>

@implementation SSCustomSwitch

- (void)drawRect:(CGRect)rect {
    if (self.drawingHandler) {
        self.drawingHandler(SSContextGetCurrent());
    }
}

- (void)dealloc {
    [_drawingHandler release];
    
    [super ss_dealloc];
}

#pragma mark getters & setters

- (void (^)(CGContextRef _Nullable))drawingHandler {
    return _drawingHandler;
}

- (void)setDrawingHandler:(void (^)(CGContextRef _Nullable))drawingHandler {
    SSNonAtomicCopiedSet(_drawingHandler, drawingHandler);
}

@end
