//
//  SSValidatedButton.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2010 Dante Sabatier. All rights reserved.
//

#import <AppKit/AppKit.h>

@protocol SSValidatedButton <NSValidatedUserInterfaceItem>

@optional
@property (nonatomic) NSControlStateValue state;

@end

@protocol SSButtonValidations

- (BOOL)validateButton:(id <SSValidatedButton>)button;

@end

@interface SSValidatedButton : NSButton <SSValidatedButton>

- (void)validate;

@end
