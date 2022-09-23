//
//  SSLabelPicker.h
//  SSAppKit
//
//  Created by Dante Sabatier on 12/12/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSControl.h"

@interface SSLabelPicker : SSControl {
@private
    NSPoint _initialEventLocation;
    NSPoint _finalEventLocation;
    BOOL _tracking;
}

@end
