//
//  SSImageView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 12/14/11.
//  Copyright (c) 2011 Dante Sabatier. All rights reserved.
//

#import "SSBackgroundView.h"

NS_ASSUME_NONNULL_BEGIN

@class SSImageView;
@protocol SSImageViewDelegate <NSObject>

@optional
#if !TARGET_OS_IPHONE
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060
- (nullable id <NSPasteboardWriting>)pasteboardWriterForImageView:(SSImageView *)imageView NS_AVAILABLE(10_7, NA);
- (void)imageView:(SSImageView *)imageView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint NS_AVAILABLE(10_7, NA);
- (void)imageView:(SSImageView *)imageView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation NS_AVAILABLE(10_7, NA);
- (BOOL)imageView:(SSImageView *)imageView ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session NS_AVAILABLE(10_7, NA);
- (void)imageView:(SSImageView *)imageView updateDraggingItemsForDrag:(id <NSDraggingInfo>)draggingInfo NS_AVAILABLE(10_7, NA);
#endif
- (BOOL)imageView:(SSImageView *)imageView writeToPasteboard:(NSPasteboard *)pasteboard NS_AVAILABLE(10_5, NA);
- (NSDragOperation)imageView:(SSImageView *)imageView validateDrop:(id <NSDraggingInfo>)info NS_AVAILABLE(10_5, NA);
- (BOOL)imageView:(SSImageView *)imageView acceptDrop:(id <NSDraggingInfo>)info NS_AVAILABLE(10_5, NA);
#endif
- (BOOL)imageViewShouldRemoveImage:(SSImageView *)imageView;

@end

#if TARGET_OS_IPHONE
@interface SSImageView : SSBackgroundView
#else
@interface SSImageView : SSBackgroundView
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060
<NSDraggingSource, NSDraggingDestination>
#endif
#endif 
{
@package
    NSDictionary *_imageProperties;
    CGImageRef _image;
    CGSize _maximumImageSize;
    SSRectResizingMethod _imageResizingMethod;
    struct {
        unsigned int doubleClickOpensImageEditPanel:1;
        unsigned int dragging:1;
        unsigned int delegateRespondsToPasteboardWriter:1;
        unsigned int delegateRespondsToDraggingSessionWillBegin:1;
        unsigned int delegateRespondsToDraggingSessionEnded:1;
        unsigned int delegateRespondsToIgnoreModifierKeys:1;
        unsigned int delegateRespondsToUpdateDraggingItems:1;
        unsigned int delegateRespondsToWriteItem:1;
        unsigned int delegateRespondsToValidateDrop:1;
        unsigned int delegateRespondsToAcceptDrop:1;
    } _flags;
    __ss_weak id <SSImageViewDelegate> _delegate;
    __ss_weak id _target;
    SEL _action;
}

@property (nullable, nonatomic, ss_weak) IBOutlet id <SSImageViewDelegate> delegate;
@property (nullable, nonatomic, ss_weak) id target NS_AVAILABLE(10_5, NA);
@property (nullable, nonatomic) SEL action NS_AVAILABLE(10_5, NA);
@property (nullable, nonatomic, readonly) CGImageRef image;
@property (nullable, nonatomic, readonly, copy) NSDictionary <NSString *, id>*imageProperties;
- (void)setImage:(nullable CGImageRef)image imageProperties:(nullable NSDictionary <NSString *, id>*)imageProperties;
- (CGImageRef)thumbnailWithMaximumSize:(CGSize)size CF_RETURNS_NOT_RETAINED;
@property (nonatomic) CGSize maximumImageSize;
@property (nonatomic) SSRectResizingMethod imageResizingMethod;
@property (nonatomic) BOOL doubleClickOpensImageEditPanel NS_AVAILABLE(10_5, NA);
@property (nonatomic, readonly) CGRect imageBounds;

@end

NS_ASSUME_NONNULL_END
