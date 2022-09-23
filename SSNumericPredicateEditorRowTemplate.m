//
//  SSNumericPredicateEditorRowTemplate.m
//  SSAppKit
//
//  Created by Dante Sabatier on 08/03/13.
//
//

#import "SSNumericPredicateEditorRowTemplate.h"
#import "NSPredicateEditorRowTemplate+SSAdditions.h"
#import <SSBase/SSDefines.h>
#import <SSFoundation/NSObject+SSAdditions.h>

@interface SSNumericPredicateEditorRowTemplate ()

@property (nonatomic, copy) NSArray *constants;

@end

@implementation SSNumericPredicateEditorRowTemplate

- (instancetype)initWithLeftExpressionsForKeyPath:(NSString *)keyPath rightExpressionsForConstants:(NSArray <NSDictionary<NSString *, id>*> *)constants inEntityDescription:(nullable NSEntityDescription *)entityDescription {
    NSMutableArray *rightExpressions = [NSMutableArray arrayWithCapacity:constants.count];
    for (NSDictionary<NSString *, id>*constant in constants) {
        [rightExpressions addObject:[NSExpression expressionForConstantValue:constant]];
    }
    
    self = [super initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressions:rightExpressions modifier:NSDirectPredicateModifier operators:@[@(NSEqualToPredicateOperatorType)] options:0];
    if (self) {
        self.entityDescription = entityDescription;
        self.constants = constants;
    }
    return self;
}

- (instancetype)initWithLeftExpressionsForKeyPath:(NSString *)keyPath rightExpressionsForConstants:(NSArray *)constants {
    return [self initWithLeftExpressionsForKeyPath:keyPath rightExpressionsForConstants:constants inEntityDescription:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    SSNumericPredicateEditorRowTemplate *copy = [super copyWithZone:zone];
    copy->_templateViews = [_templateViews ss_retain];
    
    return copy;
}

- (void)dealloc {
    [_constants release];
    [_templateViews release];
    
    [super ss_dealloc];
}

#pragma mark NSPredicateEditorRowTemplate

- (double)matchForPredicate:(NSPredicate *)predicate {
    double match = [super matchForPredicate:predicate];
    if (!match && [predicate isKindOfClass:[NSComparisonPredicate class]] && [(self.leftExpressions.firstObject).keyPath isEqualToString:((NSComparisonPredicate *)predicate).leftExpression.keyPath])
        match = 1.0;
    return match;
}

- (NSArray *)templateViews {
    if (!_templateViews) {
        NSMenu *menu = [[[NSMenu alloc] init] autorelease];
        NSArray *constants = [_constants sortedArrayUsingDescriptors:@[[[[NSSortDescriptor alloc] initWithKey:SSNumericPredicateEditorRowTemplateRightExpressionsConstantRepresentedObject ascending:YES] autorelease]]];
        for (NSDictionary *constant in constants) {
            NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
            item.title = constant[SSNumericPredicateEditorRowTemplateRightExpressionsConstantTitle];
            item.representedObject = constant[SSNumericPredicateEditorRowTemplateRightExpressionsConstantRepresentedObject];
            
            [menu addItem:item];
        }
        
        NSPopUpButton *button = [[[NSPopUpButton alloc] initWithFrame:CGRectMake(0, 0, 180, 22) pullsDown:NO] autorelease];
        button.menu = menu;
        
        NSMutableArray *templateViews = [[super.templateViews mutableCopy] autorelease];
        if (self.entityDescription) {
            [self.class localizeTemplateViews:templateViews forKeyPathsInEntityDescription:self.entityDescription];
        }
        
        templateViews[2] = button;
        
        _templateViews = [templateViews copy];
    }
    
    return _templateViews;
}

- (void)setPredicate:(NSPredicate *)predicate {
    [(NSPopUpButton *)self.templateViews[2] selectItemAtIndex:[(NSPopUpButton *)self.templateViews[2] indexOfItemWithRepresentedObject:((NSComparisonPredicate *)predicate).rightExpression.constantValue]];
}

- (NSPredicate *)predicateWithSubpredicates:(NSArray *)subpredicates {
    NSComparisonPredicate *predicate = (NSComparisonPredicate *)[super predicateWithSubpredicates:subpredicates];
    return [NSComparisonPredicate predicateWithLeftExpression:predicate.leftExpression rightExpression:[NSExpression expressionForConstantValue:((NSPopUpButton *)self.templateViews[2]).selectedItem.representedObject] modifier:predicate.comparisonPredicateModifier type:predicate.predicateOperatorType options:0];
}

#pragma mark getters & setters

- (NSArray *)constants {
    return _constants;
}

- (void)setConstants:(NSArray *)constants {
    SSNonAtomicCopiedSet(_constants, constants);
}

@end
