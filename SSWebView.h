//
//  SSWebView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 08/09/14.
//
//

#import "SSLayoutView.h"

@protocol SSWebViewDelegate;

@interface SSWebView : SSLayoutView
#if TARGET_OS_IPHONE
<UIGestureRecognizerDelegate>
#else
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060
<NSDraggingSource, NSDraggingDestination>
#endif
#endif
{
@private
    NSMutableDictionary *_cachedCells;
    NSArray *_selectedObjects;
    NSArray *_content;
    CALayer *_contentLayer;
    struct {
        unsigned int isFirstResponder:1;
        unsigned int draggingObject:1;
        unsigned int allowsReordering:1;
        unsigned int delegateRespondsToValidateDrop:1;
        unsigned int delegateRespondsToAcceptDrop:1;
        unsigned int delegateRespondsToShouldRemove:1;
        unsigned int delegateRespondsToRemove:1;
    } _flags;
    __ss_weak id <SSWebViewDelegate> _delegate;
}

@property (nonatomic, ss_weak) IBOutlet id <SSWebViewDelegate> delegate;
@property (nonatomic, copy) NSArray *content;
@property (nonatomic, copy) NSArray *selectedObjects;
@property IBInspectable BOOL allowsReordering;
@property (readonly, getter = isFirstResponder) BOOL firstResponder;
@property (readonly) BOOL canDelete;

#if TARGET_OS_IPHONE
- (void)delete:(id)sender;
- (void)selectAll:(id)sender;
#else
- (IBAction)delete:(id)sender;
- (IBAction)selectAll:(id)sender;
#endif
- (IBAction)deselectAll:(id)sender;

@end

@protocol SSWebViewDelegate <NSObject>

@optional
#if !TARGET_OS_IPHONE
- (NSDragOperation)webView:(SSWebView *)webView validateDrop:(id <NSDraggingInfo>)info NS_AVAILABLE(10_5, NA);
- (BOOL)webView:(SSWebView *)webView acceptDrop:(id <NSDraggingInfo>)info NS_AVAILABLE(10_5, NA);
#endif
- (BOOL)webViewShouldRemove:(SSWebView *)webView;
- (void)webViewRemove:(SSWebView *)webView;

@end
