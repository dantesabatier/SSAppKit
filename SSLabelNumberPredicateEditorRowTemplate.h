//
//  SSLabelNumberPredicateEditorRowTemplate.h
//  SSAppKit
//
//  Created by Dante Sabatier on 2/10/13.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSLabelNumberPredicateEditorRowTemplate : NSPredicateEditorRowTemplate {
@package
    NSArray *_templateViews;
}

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath inEntityDescription:(nullable NSEntityDescription *)entityDescription NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
