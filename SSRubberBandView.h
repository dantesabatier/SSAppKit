//
//  SSRubberBandView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 08/01/19.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSRubberBandView : NSView {
@private
    NSInteger _tag;
    CGRect _selectionRect;
}

@property (nonatomic, assign) CGRect selectionRect;
@property (nonatomic, assign) NSInteger tag;

@end

NS_ASSUME_NONNULL_END
