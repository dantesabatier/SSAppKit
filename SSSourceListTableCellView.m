//
//  SSSourceListTableCellView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/13.
//
//

#import "SSSourceListTableCellView.h"
#import <SSBase/SSDefines.h>

@implementation SSSourceListTableCellView

- (void)awakeFromNib {
    ((NSButtonCell *)self.button.cell).bezelStyle = NSInlineBezelStyle;
}

- (void)dealloc {
    self.button = nil;
    
    [super ss_dealloc];
}

#if 1

- (void)viewWillDraw {
    [super viewWillDraw];
    
    if (!self.button.isHidden) {
        [self.button sizeToFit];
        
        CGRect textFrame = self.textField.frame;
        CGRect buttonFrame = self.button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetWidth(buttonFrame), CGRectGetMidY(textFrame) - (CGRectGetHeight(buttonFrame)*(CGFloat)0.5));
        self.button.frame = buttonFrame;
        textFrame.size.width = CGRectGetMinX(buttonFrame) - CGRectGetMinX(textFrame);
        self.textField.frame = textFrame;
    }
}

#endif

@end
