//
//  SSOverlayWindow.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/22/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSBorderlessWindow.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSOverlayWindow : SSBorderlessWindow {
@private
	NSView *_parentView;
}

@property (nullable, nonatomic, strong) IBOutlet NSView *parentView;

@end

NS_ASSUME_NONNULL_END
