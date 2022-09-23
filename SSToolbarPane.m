//
//  SSToolbarPane.m
//  SSAppKit
//
//  Created by Dante Sabatier on 10/27/09.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSToolbarPane.h"

@implementation SSToolbarPane

- (BOOL)shouldBeReplacedByPane:(id <SSToolbarPane>)pane {
    return YES;
}

- (IBAction)showHelp:(id)sender {
	NSString *helpAnchor = ((id <SSToolbarPane>)self).helpAnchor;
    if (helpAnchor.length) {
        [[NSHelpManager sharedHelpManager] openHelpAnchor:helpAnchor inBook:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleHelpBookName"]];
    }
}

- (NSString *)identifier {
	return NSStringFromClass(self.class);
}

- (nullable NSImage *)icon {
	return nil;
}

- (nullable NSString *)helpAnchor {
    return nil;
}

@end
