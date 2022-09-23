//
//  SSBooleanPredicateEditorRowTemplate.m
//  SSAppKit
//
//  Created by Dante Sabatier on 29/04/14.
//
//

#import "SSBooleanPredicateEditorRowTemplate.h"
#import "SSAppKitUtilities.h"

@implementation SSBooleanPredicateEditorRowTemplate

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath inEntityDescription:(NSEntityDescription *)entityDescription {
    self = [super initWithLeftExpressionsForKeyPath:keyPath rightExpressionsForConstants:@[@{SSNumericPredicateEditorRowTemplateRightExpressionsConstantTitle: SSAppKitLocalizedString(@"true", @"predicate editor row template item title"), SSNumericPredicateEditorRowTemplateRightExpressionsConstantRepresentedObject: @YES}, @{SSNumericPredicateEditorRowTemplateRightExpressionsConstantTitle: SSAppKitLocalizedString(@"false", @"predicate editor row template item title"), SSNumericPredicateEditorRowTemplateRightExpressionsConstantRepresentedObject: @YES}] inEntityDescription:entityDescription];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithExpressionsForKeyPath:(NSString *)keyPath {
    return [self initWithExpressionsForKeyPath:keyPath inEntityDescription:nil];
}

@end
