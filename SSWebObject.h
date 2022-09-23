//
//  SSWebObject.h
//  SSAppKit
//
//  Created by Dante Sabatier on 08/09/14.
//
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <CoreGraphics/CoreGraphics.h>
#endif

@protocol SSWebObject <NSObject>

@required
@property (strong) id contents;
@property (copy) NSString *identifier;
@property CGRect frame;
@property (strong) id backgroundColor;
@property CGFloat cornerRadius;
@property CGFloat borderWidth;
@property (strong) id borderColor;
@property (strong) id shadowColor;
@property float shadowOpacity;
@property CGSize shadowOffset;
@property CGFloat shadowRadius;

@optional
@property (copy) NSString *fontName;
@property CGFloat fontSize;
@property (strong) id textColor;

@end




