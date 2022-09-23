//
//  SSPopoverView.h
//  SSAppKit
//
//  Created by Dante Sabatier on 14/10/12.
//
//

#import "SSBackgroundView.h"

#if TARGET_OS_IPHONE
@interface SSPopoverView : SSBackgroundView
#else
@interface SSPopoverView : SSBackgroundView
#if MAC_OS_X_VERSION_MAX_ALLOWED > 1060
<NSDraggingSource>
#endif
#endif 
{
@private
    CGSize _arrowSize;
    SSRectPosition _arrowPosition;
}

@property CGSize arrowSize;
@property SSRectPosition arrowPosition;

@end
