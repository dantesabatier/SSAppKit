//
//  SSSourceListViewItem.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/5/13.
//
//

#import <Foundation/Foundation.h>

@protocol SSSourceListViewItem <NSObject>

@optional
@property (nonatomic, readonly, copy) NSString *badgeLabel;
@property (nonatomic, readonly, copy) NSColor *badgeColor;

@required
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSImage *image;

@end
