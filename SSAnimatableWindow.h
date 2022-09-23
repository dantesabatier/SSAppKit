//
//  SSAnimatableWindow.h
//  SSAppKit
//
//  Created by Dante Sabatier on 19/09/13.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSAnimatableWindow : NSWindow {
@private
    NSWindow *_fullScreenWindow;
    CALayer *_presentationLayer;
    BOOL _disableConstrainedWindow;
}

@property (nonatomic, readonly, ss_strong) CALayer *presentationLayer;

- (void)beginAnimations:(void(^ __nullable)(CALayer *layer))block;
- (void)commitAnimationsWithDuration:(CFTimeInterval)duration timing:(nullable CAMediaTimingFunction *)timing block:(void (^ __nullable)(CALayer *layer))block;
- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
