//
//  SSTheme.m
//  SSAppKit
//
//  Created by Dante Sabatier on 07/10/12.
//
//

#import "SSTheme.h"
#import "SSAppKitConstants.h"
#if TARGET_OS_IPHONE
#import <graphics/SSGraphics.h>
#import <foundation/NSBundle+SSAdditions.h>
#import "UIImage+SSAdditions.h"
#import "UIColor+SSAdditions.h"
#else
#import "NSImage+SSAdditions.h"
#import "NSColor+SSAdditions.h"
#import <SSGraphics/SSGraphics.h>
#import <SSFoundation/NSBundle+SSAdditions.h>
#endif
#import "SSAppKitUtilities.h"
#import <objc/objc-sync.h>

NSString *const SSAppKitDefaultThemeUniqueID = @"BB7F7FDB-AD3A-468E-86A6-08D9B3FFD31F";

NSString *const SSThemeUniqueIDKey = @"SSThemeUniqueID";
NSString *const SSThemeThumbnailKey = @"SSThemeThumbnail";
NSString *const SSThemeBackgroundColorKey = @"SSThemeBackgroundColor";
NSString *const SSThemeBackgroundImageKey = @"SSThemeBackgroundImage";
NSString *const SSThemeIsDefaultKey = @"SSThemeIsDefault";

static BOOL _kDefaultThemeCanBeDestroyed = NO;

@interface SSTheme ()

@property (copy, readwrite) NSURL *URL;

@end

@implementation SSTheme

static SSTheme * defaultTheme;

+ (SSTheme*)defaultTheme {
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0)))
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultTheme = [[self alloc] init];
#if TARGET_OS_IPHONE
        defaultTheme.backgroundColor = [UIColor whiteColor];
#else
        defaultTheme.backgroundColor = [NSColor whiteColor];
#endif
        defaultTheme.title = SSAppKitLocalizedString(@"Default", @"default theme title");
        defaultTheme.uniqueID = SSAppKitDefaultThemeUniqueID;
        defaultTheme.thumbnail = nil;
        id obj = nil;
        NSString *notificationName = nil;
#if TARGET_OS_IPHONE
        obj = [UIApplication sharedApplication];
        notificationName = UIApplicationWillTerminateNotification;
#else
        obj = NSApp;
        notificationName = NSApplicationWillTerminateNotification;
#endif
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationName object:obj queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            _kDefaultThemeCanBeDestroyed = YES;
            [defaultTheme release];
            defaultTheme = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
    return defaultTheme;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    NSBundle *bundle = [NSBundle bundleWithURL:URL];
    if (!bundle) {
        return nil;
    }
    
    NSString *uniqueID = [bundle objectForInfoDictionaryKey:SSThemeUniqueIDKey];
    if (!uniqueID) {
        NSLog(@"%@ %@, Warning!, theme at %@ does not contains an unique ID (%@), ignoring…", self.class, NSStringFromSelector(_cmd), URL.absoluteString, SSThemeUniqueIDKey);
        return nil;
    }
    
    self = [super init];
    if (self) {
        _URL = [URL copy];
        _title = [bundle.localizedName copy];
        _uniqueID = [uniqueID copy];
        _thumbnail = [[bundle imageForInfoDictionaryKey:SSThemeThumbnailKey] copy];
        _backgroundImage = [[bundle imageForInfoDictionaryKey:SSThemeBackgroundImageKey] copy];
        
        NSString *representation = [bundle objectForInfoDictionaryKey:SSThemeBackgroundColorKey];
        if ([representation componentsSeparatedByString:@" "].count) {
#if TARGET_OS_IPHONE
            _backgroundColor = [[UIColor colorWithString:representation] copy];
#else
            _backgroundColor = [[NSColor colorWithString:representation] copy];
#endif
        }
        
        if (!_backgroundColor) {
#if TARGET_OS_IPHONE
            _backgroundColor = [[UIColor whiteColor] copy];
#else
            _backgroundColor = [[NSColor whiteColor] copy];
#endif
        }
        
        if (!_thumbnail) {
#if TARGET_OS_IPHONE
            _thumbnail = [[UIImage alloc] initWithCGImage:SSAutorelease(SSImageCreateWithColor([_backgroundColor CGColor], SSSizeMakeSquare(16.0)))];
#else
            _thumbnail = [[NSImage alloc] initWithCGImage:SSAutorelease(SSImageCreateWithColor([_backgroundColor CGColor], SSSizeMakeSquare(16.0))) size:CGSizeZero];
#endif
        }
    }
    return self;
}

#if TARGET_OS_IPHONE
- (instancetype)initWithColor:(UIColor *)color;
#else
- (instancetype)initWithColor:(NSColor *)color;
#endif 
{
    self = [super init];
    if (self) {
        _backgroundColor = [color ss_retain];
#if TARGET_OS_IPHONE
        _backgroundImage = [[UIImage imageWithColor:_backgroundColor size:SSSizeMakeSquare(1.0)] ss_retain];
        _thumbnail = [[UIImage imageWithColor:_backgroundColor size:SSSizeMakeSquare(16.0)] ss_retain];
#else
        _backgroundImage = [[NSImage imageWithColor:_backgroundColor size:SSSizeMakeSquare(1.0)] ss_retain];
        _thumbnail = [[NSImage imageWithColor:_backgroundColor size:SSSizeMakeSquare(16.0)] ss_retain];
#endif
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    return [decoder decodeObjectForKey:@"URL"] ? [self initWithURL:[decoder decodeObjectForKey:@"URL"]] : [self initWithColor:[decoder decodeObjectForKey:@"backgroundColor"]];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.URL forKey:@"URL"];
    [coder encodeObject:self.backgroundColor forKey:@"backgroundColor"];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SSTheme *theme = [[self.class allocWithZone:zone] init];
    if (theme) {
        theme.URL = self.URL;
        theme.backgroundColor = self.backgroundColor;
        theme.backgroundImage = self.backgroundImage;
        theme.title = self.title;
        theme.thumbnail = self.thumbnail;
        theme.textColor = self.textColor;
    }
    return theme;
}

- (void)dealloc {
    if (self == defaultTheme && !_kDefaultThemeCanBeDestroyed)
        return;
    
    [_URL release];
    [_title release];
    [_uniqueID release];
    [_thumbnail release];
    [_backgroundImage release];
    [_backgroundColor release];
    [_textColor release];
    
    [super ss_dealloc];
}

#pragma mark getters & setters

- (NSURL *)URL {
    return SSAtomicAutoreleasedGet(_URL);
}

- (void)setURL:(NSURL *)URL {
    SSAtomicCopiedSet(_URL, URL);
}

- (NSString *)title {
    return SSAtomicAutoreleasedGet(_title);
}

- (void)setTitle:(NSString *)title {
    SSAtomicCopiedSet(_title, title);
}

- (NSString *)uniqueID {
    return SSAtomicAutoreleasedGet(_uniqueID);
}

- (void)setUniqueID:(NSString *)uniqueID {
    SSAtomicCopiedSet(_uniqueID, uniqueID);
}

- (NSInteger)type {
    return _type;
}

- (void)setType:(NSInteger)type {
    _type = type;
}

- (id)thumbnail {
    return SSAtomicAutoreleasedGet(_thumbnail);
}

- (void)setThumbnail:(id)thumbnail {
    SSAtomicRetainedSet(_thumbnail, thumbnail);
}

- (id)backgroundImage {
    objc_sync_enter(self);
    if (!_backgroundImage) {
        _backgroundImage = [SSAppKitGetImageResourceNamed(SSImageNameThemeBackground) copy];
    }
    objc_sync_exit(self);
    return SSAtomicAutoreleasedGet(_backgroundImage);
}

- (void)setBackgroundImage:(id)backgroundImage {
    SSAtomicRetainedSet(_backgroundImage, backgroundImage);
}

- (id)backgroundColor {
    return SSAtomicAutoreleasedGet(_backgroundColor);
}

- (void)setBackgroundColor:(id)backgroundColor {
    SSAtomicRetainedSet(_backgroundColor, backgroundColor);
}

- (id)textColor {
    return SSAtomicAutoreleasedGet(_textColor);
}

- (void)setTextColor:(id)textColor {
    SSAtomicRetainedSet(_textColor, textColor);
}

- (id)scrollerBackgroundImage {
    return self.backgroundImage;
}

@end
