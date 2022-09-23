//
//  NSApplication+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 6/29/12.
//
//

#import "NSApplication+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <SSFoundation/NSBundle+SSAdditions.h>

@implementation NSApplication (SSAdditions)

- (NSImage *)applicationIcon {
    NSImage *icon = NSBundle.mainBundle.icon;
    if (!icon) {
        icon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
    }
    return icon;
}

- (NSImage *)applicationAlertCautionIconImageOfSize:(CGSize)iconSize {
    NSImage *icon = self.applicationIcon;
    icon.size = CGSizeMake(iconSize.width*(CGFloat)0.5, iconSize.height*(CGFloat)0.5);
	
	NSImage *alertIcon = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kAlertCautionIcon)];
	alertIcon.size = iconSize;
    
	CGRect rect = CGRectZero;
	rect.size = iconSize;
	
	NSImage *image = [[NSImage alloc] initWithSize:iconSize];
	[image lockFocus];
	
	[alertIcon drawAtPoint:NSZeroPoint fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1.0];
	[icon drawAtPoint:CGPointMake(icon.size.width, 0) fromRect:CGRectZero operation:NSCompositeSourceOver fraction:1.0];
	
	[image unlockFocus];
	
	return [image autorelease];
}

- (NSImage *)applicationAlertCautionIconImage {
    return [self applicationAlertCautionIconImageOfSize:CGSizeMake(64.0, 64.0)];
}

#if NS_BLOCKS_AVAILABLE

- (void)beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)docWindow didEndBlock:(void (^)(NSInteger returnCode))block {
    [self beginSheet:sheet modalForWindow:docWindow modalDelegate:self didEndSelector:@selector(ss_application_blockSheetDidEnd:returnCode:contextInfo:) contextInfo:Block_copy((__bridge void *)block)];
}

- (void)ss_application_blockSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    void (^block)(NSInteger returnCode) = (__bridge void (^)(NSInteger))(contextInfo);
    block(returnCode);
    Block_release((__bridge void *)block);
}

#endif

@end
