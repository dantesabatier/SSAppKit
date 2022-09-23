//
//  SSDarkTableView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 12/09/12.
//
//

#import "SSDarkTableView.h"
#import "NSScrollView+SSAdditions.h"
#import "NSView+SSAdditions.h"

@implementation SSDarkTableView

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    
#if 1
    if (self.usesAlternatingRowBackgroundColors) {
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            self.alternatingRowBackgroundColors = @[[NSColor colorWithCalibratedWhite:0.0 alpha:0.16], [NSColor colorWithCalibratedWhite:0.0 alpha:0.33]];
        } else {
             self.alternatingRowBackgroundColors = @[[NSColor colorWithCalibratedWhite:0.0 alpha:0.8], [NSColor colorWithCalibratedWhite:0.0 alpha:0.86]];
        }
    }
    self.backgroundColor = [NSColor clearColor];
    self.gridColor = [NSColor colorWithCalibratedWhite:0.9 alpha:0.16];
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
        self.highlightColor = [NSColor colorWithCalibratedWhite:0.26 alpha:0.33];
    } else {
        self.highlightColor = [NSColor colorWithCalibratedWhite:0.26 alpha:0.8];
    } 
    //self.enclosingScrollView.bounces = NO;
    self.enclosingScrollView.drawsBackground = NO;
    
#endif
}

- (BOOL)needsDisplayWhenWindowResignsKey
{
    return NO;
}

@end
