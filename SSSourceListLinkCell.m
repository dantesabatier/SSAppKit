//
//  SSLinkCell.m
//  SSAppKit
//
//  Created by Dante Sabatier on 10/10/12.
//
//

#import "SSSourceListLinkCell.h"
#import <SSBase/SSDefines.h>

@implementation SSSourceListLinkCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	if (self) {
        _buttonCell.buttonType = NSMomentaryLightButton;
        _buttonCell.bezelStyle = NSTexturedRoundedBezelStyle;
        _buttonCell.bordered = NO;
        _buttonCell.highlightsBy = NSNoCellMask;
        _buttonCell.imagePosition = NSImageOnly;
        _buttonCell.imageScaling = NSImageScaleProportionallyDown;
        _buttonCell.image = [NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate];
    }
    return self;
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    if ([controlView isKindOfClass:[NSTableView class]])
        _buttonCell.backgroundStyle = self.isHighlighted && controlView.window.isKeyWindow && (controlView.window.firstResponder == controlView) ? NSBackgroundStyleDark : NSBackgroundStyleLight;
    
	[super drawWithFrame:cellFrame inView:controlView];
}

- (CGRect)buttonRectForBounds:(CGRect)bounds {
    if ([self.controlView isKindOfClass:[NSTableView class]]) {
        if (self.isHighlighted) {
            return [super buttonRectForBounds:bounds];
        }
        return CGRectZero;
    }
    
    CGRect buttonRect = [super buttonRectForBounds:bounds];
#if 0
    if (!NSIsEmptyRect(buttonRect)) {
        buttonRect.origin.y = CGRectGetMaxY(bounds) - (MAX([self.string sizeWithAttributes:@{NSFontAttributeName : self.font}].height, 13.0)*(CGFloat)0.5) - (CGRectGetHeight(buttonRect)*(CGFloat)0.5);
    }
#endif
    return buttonRect;
}

@end
