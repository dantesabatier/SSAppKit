//
//  SSDrawer.h
//  SSAppKit
//
//  Created by Dante Sabatier on 2/9/13.
//
//

#import <Cocoa/Cocoa.h>

@interface SSDrawer : NSObject {
@private
    NSWindow *_window;
    NSViewController *_contentViewController;
    NSViewController *_drawerViewController;
    NSRectEdge _preferredEdge;
}

@property (nonatomic, strong) IBOutlet NSViewController *contentViewController;
@property (nonatomic, strong) IBOutlet NSViewController *drawerViewController;
@property NSRectEdge preferredEdge;

@end
