//
//  SSRatingPredicateEditorRowTemplate.h
//  SSAppKit
//
//  Created by Dante Sabatier on 2/10/13.
//
//

#import <AppKit/AppKit.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSRatingPredicateEditorRowTemplate : NSPredicateEditorRowTemplate {
@private
    NSArray *_templateViews;
}

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath inEntityDescription:(nullable NSEntityDescription *)entityDescription NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
