//
//  SSHoverViewSeparatorView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 15/12/16.
//
//

#import <UIKit/UIKit.h>

@interface SSHoverViewSeparatorView : UIView {
@private
    NSInteger _orientation;
    CGFloat _separatorWidth;
    UIColor *_separatorColor;
    NSArray<UIView *> *_viewsToSeparate;
}

@property (nonatomic, assign) NSInteger orientation;
@property (nonatomic, assign) CGFloat separatorWidth;
@property (nullable, nonatomic, copy) UIColor *separatorColor;
@property (nullable, nonatomic, copy) NSArray<UIView *> *viewsToSeparate;

@end
