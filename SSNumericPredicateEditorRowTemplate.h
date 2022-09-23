//
//  SSNumericPredicateEditorRowTemplate.h
//  SSAppKit
//
//  Created by Dante Sabatier on 08/03/13.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>
#import "SSAppKitConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSNumericPredicateEditorRowTemplate : NSPredicateEditorRowTemplate {
@package
    NSArray *_templateViews;
    NSArray *_constants;
}

- (instancetype)initWithLeftExpressionsForKeyPath:(NSString *)keyPath rightExpressionsForConstants:(NSArray <NSDictionary<NSString *, id>*> *)constants inEntityDescription:(nullable NSEntityDescription *)entityDescription NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLeftExpressionsForKeyPath:(NSString *)keyPath rightExpressionsForConstants:(NSArray <NSDictionary<NSString *, id>*> *)constants;

@end

NS_ASSUME_NONNULL_END
