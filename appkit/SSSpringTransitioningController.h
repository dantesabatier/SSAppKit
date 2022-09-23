//
//  SSSpringTransitioningController.h
//  SSAppKit
//
//  Created by Dante Sabatier on 07/12/16.
//
//

#import "SSTransitioningController.h"

@interface SSSpringTransitioningController : SSTransitioningController

@property (nonatomic, assign) CGFloat damping;
@property (nonatomic, assign) CGFloat velocity;

@end
