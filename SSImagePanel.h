//
//  SSImagePanel.h
//  SSAppKit
//
//  Created by Dante Sabatier on 21/02/12.
//  Copyright (c) 2012 Dante Sabatier. All rights reserved.
//

#import "SSZoomPanel.h"
#import "SSAsynchronousImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSImagePanel : SSZoomPanel {
@private;
    SSAsynchronousImageView *imageView;
}

@property (class, readonly, ss_strong) SSImagePanel *sharedImagePanel NS_AVAILABLE_MAC(10_6);
@property (class, readonly) BOOL sharedImagePanelExists NS_AVAILABLE_MAC(10_6);
@property (nullable) CGImageRef image;
@property (nullable, nonatomic, readonly) SSAsynchronousImageView *imageView;

@end

NS_ASSUME_NONNULL_END
