//
//  SSCollectionItemView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 10/08/12.
//
//

#import "SSView.h"

@interface SSCollectionItemView : SSView {
@private
    BOOL _selected;
    NSColor *_selectionColor;
}

@property (null_resettable, nonatomic, copy) NSColor *selectionColor;
@property (getter = isSelected) BOOL selected;

@end
