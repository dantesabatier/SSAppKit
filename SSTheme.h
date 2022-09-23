//
//  SSTheme.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/10/12.
//
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>
#import <objc/NSObjCRuntime.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <base/SSDefines.h>
#else
#import <SSBase/SSDefines.h>
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SSTheme <NSObject, NSCoding, NSCopying>

@optional
@property (nullable, readonly, copy) NSString *title;
@property (nullable, readonly, copy) NSString *uniqueID;
@property (readonly) NSInteger type;
#if TARGET_OS_IPHONE
@property (nullable, readonly, ss_strong) UIImage *thumbnail;
#else
@property (nullable, readonly, ss_strong) NSImage *thumbnail;
#endif

@required
#if TARGET_OS_IPHONE
@property (nullable, readonly, ss_strong) UIColor *textColor;
@property (nullable, readonly, ss_strong) UIColor *backgroundColor;
@property (nullable, readonly, ss_strong) UIImage *backgroundImage;
@property (nullable, readonly, ss_strong) UIImage *scrollerBackgroundImage;
#else
@property (nullable, readonly, ss_strong) NSColor *textColor;
@property (nullable, readonly, ss_strong) NSColor *backgroundColor;
@property (nullable, readonly, ss_strong) NSImage *backgroundImage;
@property (nullable, readonly, ss_strong) NSImage *scrollerBackgroundImage;
#endif

@end

@interface SSTheme : NSObject <SSTheme> {
@private
    NSURL *_URL;
    NSString *_title;
    NSString *_uniqueID;
    NSInteger _type;
    id _thumbnail;
    id _backgroundImage;
    id _backgroundColor;
    id _textColor;
}

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithURL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;
#if TARGET_OS_IPHONE
- (instancetype)initWithColor:(UIColor *)color NS_DESIGNATED_INITIALIZER;
#else
- (instancetype)initWithColor:(NSColor *)color NS_DESIGNATED_INITIALIZER;
#endif
@property (class, readonly, ss_strong) __kindof SSTheme *defaultTheme SS_CONST NS_AVAILABLE(10_6, 4_0);
@property (nullable, readonly, copy) NSURL *URL;
@property (nullable, copy) NSString *title;
@property (nullable, copy) NSString *uniqueID;
@property NSInteger type;
#if TARGET_OS_IPHONE
@property (nullable, ss_strong) UIColor *textColor;
@property (nullable, ss_strong) UIColor *backgroundColor;
@property (nullable, ss_strong) UIImage *backgroundImage;
@property (nullable, ss_strong) UIImage *thumbnail;
@property (nullable, readonly, ss_strong) UIImage *scrollerBackgroundImage;
#else
@property (nullable, ss_strong) NSColor *textColor;
@property (nullable, ss_strong) NSColor *backgroundColor;
@property (nullable, ss_strong) NSImage *backgroundImage;
@property (nullable, ss_strong) NSImage *thumbnail;
@property (nullable, readonly, ss_strong) NSImage *scrollerBackgroundImage;
#endif

@end

extern NSString *const SSAppKitDefaultThemeUniqueID;

extern NSString *const SSThemeUniqueIDKey;
extern NSString *const SSThemeThumbnailKey;
extern NSString *const SSThemeBackgroundColorKey;
extern NSString *const SSThemeBackgroundImageKey;
extern NSString *const SSThemeIsDefaultKey;

NS_ASSUME_NONNULL_END
