//
//  SSPopoverFirstResponderStealingSuppression.h
//  SSAppKit
//
//  Created by Dante Sabatier on 16/07/14.
//
//

#import <Foundation/Foundation.h>

@protocol SSPopoverFirstResponderStealingSuppression <NSObject>

@property (nonatomic, readonly) BOOL suppressFirstResponderWhenPopoverShows;

@end
