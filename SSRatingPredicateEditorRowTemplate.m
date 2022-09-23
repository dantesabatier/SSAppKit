//
//  SSRatingPredicateEditorRowTemplate.m
//  SSAppKit
//
//  Created by Dante Sabatier on 2/10/13.
//
//

#import "SSRatingPredicateEditorRowTemplate.h"
#import "NSPredicateEditorRowTemplate+SSAdditions.h"
#import "SSRatingIndicator.h"
#import <SSBase/SSDefines.h>

@implementation SSRatingPredicateEditorRowTemplate

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath inEntityDescription:(NSEntityDescription *)entityDescription {
    self = [super initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressions:@[[NSExpression expressionForConstantValue:@0], [NSExpression expressionForConstantValue:@1], [NSExpression expressionForConstantValue:@2], [NSExpression expressionForConstantValue:@3], [NSExpression expressionForConstantValue:@4], [NSExpression expressionForConstantValue:@5]] modifier:NSDirectPredicateModifier operators:@[@(NSEqualToPredicateOperatorType), @(NSGreaterThanPredicateOperatorType), @(NSLessThanPredicateOperatorType)] options:0];
    if (self) {
        self.entityDescription = entityDescription;
    }
    return self;
}

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath {
    return [self initWithExpressionsForKeyPath:keyPath inEntityDescription:nil];
}

- (void)dealloc {
    [_templateViews release];
    
    [super ss_dealloc];
}

#pragma mark NSPredicateEditorRowTemplate

- (NSArray *)templateViews {
    if (!_templateViews) {
        NSMutableArray *templateViews = [[super.templateViews mutableCopy] autorelease];
        if (self.entityDescription) {
            [self.class localizeTemplateViews:templateViews forKeyPathsInEntityDescription:self.entityDescription];
        }
        
        templateViews[2] = [[[SSRatingIndicator alloc] initWithFrame:CGRectMake(0, 0, 180, 22)] autorelease];
        _templateViews = [templateViews copy];
    }
    
    return _templateViews;
}

- (void)setPredicate:(NSPredicate *)predicate {
    super.predicate = predicate;
    
    ((NSControl *)self.templateViews[2]).integerValue = [((NSComparisonPredicate *)predicate).rightExpression.constantValue integerValue];
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *)subpredicates {
    NSComparisonPredicate *predicate = (NSComparisonPredicate *)[super predicateWithSubpredicates:subpredicates];
    return [NSComparisonPredicate predicateWithLeftExpression:predicate.leftExpression rightExpression:[NSExpression expressionForConstantValue:@(((NSControl *)self.templateViews[2]).integerValue)] modifier:predicate.comparisonPredicateModifier type:predicate.predicateOperatorType options:0];
}

@end
