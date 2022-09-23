//
//  SSDarkSegmentedControl.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/8/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSDarkSegmentedControl.h"
#import "SSDarkSegmentedCell.h"

@implementation SSDarkSegmentedControl

+ (Class)cellClass 
{
    return [SSDarkSegmentedCell class];
}

- (BOOL)allowsVibrancy
{
    return NO;
}

@end
