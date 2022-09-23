//
//  SSProgressSheetController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/23/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSProgressSheetController.h"
#import "SSProgressView.h"
#import "SSStyledView.h"
#import "SSDarkTextField.h"
#import "NSColor+SSAdditions.h"
#import <SSBase/SSGeometry.h>

static BOOL __kSharedProgressSheetControllerCanBeDestroyed = NO;

@interface SSProgressSheetController () 

@end

@implementation SSProgressSheetController

static SSProgressSheetController * sharedProgressSheetController = nil;

+ (instancetype)sharedProgressSheetController {
#if defined(__MAC_10_6)
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedProgressSheetController = [[self.class alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            __kSharedProgressSheetControllerCanBeDestroyed = YES;
            [sharedProgressSheetController release];
            sharedProgressSheetController = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
	return sharedProgressSheetController;
}

- (instancetype)init {
	self = [super init];
	if (self) {
        BOOL ok = NO;
        NSString *nibName = self.nibName;
        //TODO: Update to use non-deprecated API
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_8)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        ok = [NSBundle loadNibNamed:nibName owner:self];
#pragma clang diagnostic pop
#else
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_7) {
            NSArray *topLevelObjects = nil;
            ok = [[NSBundle bundleForClass:self.class] loadNibNamed:nibName owner:self topLevelObjects:&topLevelObjects];
            SSSetAssociatedValueForKey(@"topLevelObjects", topLevelObjects, OBJC_ASSOCIATION_COPY);
        }
#endif
        
        if (!ok) {
            [NSException raise:NSGenericException format:@"%@, Warning!, Nib \"%@\" could not be loaded.", self.class, nibName];
        }
        
        if (!self.window) {
            [NSException raise:NSGenericException format:@"Nib \"%@\" was loaded but no \"window\" has been setted for class \"%@\".", nibName, self.class];
        }
        
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            titleField.textColor = [NSColor labelColor];
            statusField.textColor = [NSColor secondaryLabelColor];
        }
#endif
        self.title = @"";
        self.status = @"";
	}
	return self;
}

- (void)dealloc {
    if (self == sharedProgressSheetController && !__kSharedProgressSheetControllerCanBeDestroyed) {
        return;
    }
    
    SSSetAssociatedValueForKey(@"topLevelObjects", nil, OBJC_ASSOCIATION_COPY);
	
    [super ss_dealloc];
}

- (IBAction)open:(id)sender {
    _cancelled = NO;
    
    self.indeterminate = YES;
    
    [super open:sender];
}

- (IBAction)cancel:(id)sender {
    if (self.isCancelled) {
        return;
    }
    
    self.indeterminate = YES;
    
    _cancelled = YES;
    
    [super cancel:sender];
}

- (void)close {
	self.indeterminate = NO;
    self.doubleValue = self.minValue;
    self.title = @"";
    self.status = @"";
	
	[super close];
}

#pragma mark getters & setters

- (id<SSSheetControllerDelegate>)delegate {
    return nil;
}

- (void)setDelegate:(id<SSSheetControllerDelegate>)delegate {
    
}

- (NSString *)title {
	return titleField.stringValue;
}

- (void)setTitle:(NSString *)title {
    titleField.stringValue = title ? title : @"";
	[titleField display];
}

- (NSString *)status {
	return statusField.stringValue;
}

- (void)setStatus:(NSString *)status {
    statusField.stringValue = status ? status : @"";
	[statusField display];
}

- (double)minValue {
	return progressView.minValue;
}

- (void)setMinValue:(double)minValue {
	progressView.minValue = minValue;
}

- (double)maxValue {
	return progressView.maxValue;
}

- (void)setMaxValue:(double)maxValue {
	progressView.maxValue = maxValue;
}

- (double)doubleValue {
	return progressView.doubleValue;
}

- (void)setDoubleValue:(double)doubleValue {
    progressView.doubleValue = doubleValue;
}

- (BOOL)isIndeterminate {
	return progressView.isIndeterminate;
}

- (void)setIndeterminate:(BOOL)isIndeterminate {
	progressView.indeterminate = isIndeterminate;
}

- (BOOL)isCancelled {
    return _cancelled;
}

- (NSString *)nibName {
    return @"ProgressSheetController";
}

@end
