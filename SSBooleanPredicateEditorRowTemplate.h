//
//  SSBooleanPredicateEditorRowTemplate.h
//  SSAppKit
//
//  Created by Dante Sabatier on 29/04/14.
//
//

#import "SSNumericPredicateEditorRowTemplate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSBooleanPredicateEditorRowTemplate : SSNumericPredicateEditorRowTemplate

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath inEntityDescription:(nullable NSEntityDescription *)entityDescription;
- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
