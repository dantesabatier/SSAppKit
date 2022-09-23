//
//  SSAnimatedSegmentedControl.h
//  SSAppKit
//
//  Created by Dante Sabatier on 10/19/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSGradientSegmentedControl.h"

@interface SSAnimatedSegmentedControl : SSGradientSegmentedControl

- (void)setSelectedSegment:(NSInteger)newSegment animate:(BOOL)animate;

@end
