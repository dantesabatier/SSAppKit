//
//  NSPredicateEditorRowTemplate+SSAdditions.h
//  SSAppKit
//
//  Created by Dante Sabatier on 29/04/14.
//
//

#import <Cocoa/Cocoa.h>
#import <SSBase/SSDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSPredicateEditorRowTemplate (SSAdditions)

@property (nullable, nonatomic, ss_strong) NSEntityDescription *entityDescription;
- (instancetype)initWithLeftExpressions:(NSArray<NSExpression *> *)leftExpressions rightExpressions:(NSArray<NSExpression *> *)rightExpressions modifier:(NSComparisonPredicateModifier)modifier operators:(NSArray<NSNumber *> *)operators options:(NSUInteger)options inEntityDescription:(NSEntityDescription *)entityDescription;
- (instancetype)initWithLeftExpressions:(NSArray<NSExpression *> *)leftExpressions rightExpressionAttributeType:(NSAttributeType)attributeType modifier:(NSComparisonPredicateModifier)modifier operators:(NSArray<NSNumber *> *)operators options:(NSUInteger)options inEntityDescription:(NSEntityDescription *)entityDescription;
- (instancetype)initWithLocalizedCompoundTypes:(NSArray<NSNumber *> *)compoundTypes;
+ (nullable NSString *)localizedStringForOperatorType:(NSPredicateOperatorType)operatorType;
+ (nullable NSString *)localizedStringForKeyPath:(NSString *)keyPath inEntityDescription:(NSEntityDescription *)entityDescription NS_AVAILABLE(10_6, 4_0);
+ (NSArray <NSPredicateEditorRowTemplate *>*)localizedTemplatesWithAttributeKeyPaths:(NSArray <NSString*>*)keyPaths inEntityDescription:(NSEntityDescription *)entityDescription;
+ (void)localizeTemplateViews:(NSArray <NSView*> *)templateViews forKeyPathsInEntityDescription:(NSEntityDescription *)entityDescription;
- (void)localizeTemplateViewsForKeyPathsInEntityDescription:(NSEntityDescription *)entityDescription;
- (void)localizeTemplateViews;

@end

NS_ASSUME_NONNULL_END
