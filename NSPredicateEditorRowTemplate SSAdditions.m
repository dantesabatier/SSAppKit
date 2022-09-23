//
//  NSPredicateEditorRowTemplate+SSAdditions.m
//  SSAppKit
//
//  Created by Dante Sabatier on 29/04/14.
//
//

#import "NSPredicateEditorRowTemplate+SSAdditions.h"
#import "SSAppKitUtilities.h"
#import <SSFoundation/NSObject+SSAdditions.h>

@implementation NSPredicateEditorRowTemplate (SSAdditions)

- (instancetype)initWithLocalizedCompoundTypes:(NSArray<NSNumber *> *)compoundTypes {
    self = [self initWithCompoundTypes:compoundTypes];
    if (self) {
        NSArray *templateViews = self.templateViews;
        for (id templateView in templateViews) {
            if ([templateView isKindOfClass:[NSPopUpButton class]]) {
                for (NSMenuItem *item in ((NSPopUpButton *)templateView).itemArray) {
                    NSString *localizedString = nil;
                    id representedObject = item.representedObject;
                    if (representedObject) {
                        if ([representedObject isKindOfClass:[NSNumber class]]) {
                            localizedString = [self.class localizedStringForPredicateType:[representedObject unsignedIntegerValue]];
                        }
                    } else if ([item.title isEqualToString:@"of the following are true"]) {
                        localizedString = SSAppKitLocalizedString(@"of the following are true", @"predicate editor row template item title");
                    }
                    
                    if (localizedString) {
                        item.title = localizedString;
                    }
                }
            }
        }
    }
    return self;
}

- (instancetype)initWithLeftExpressions:(NSArray<NSExpression *> *)leftExpressions rightExpressions:(NSArray<NSExpression *> *)rightExpressions modifier:(NSComparisonPredicateModifier)modifier operators:(NSArray<NSNumber *> *)operators options:(NSUInteger)options inEntityDescription:(NSEntityDescription *)entityDescription {
    self = [self initWithLeftExpressions:leftExpressions rightExpressions:rightExpressions modifier:modifier operators:operators options:options];
    if (self) {
        self.entityDescription = entityDescription;
        [self localizeTemplateViewsForKeyPathsInEntityDescription:entityDescription];
    }
    return self;
}

- (instancetype)initWithLeftExpressions:(NSArray<NSExpression *> *)leftExpressions rightExpressionAttributeType:(NSAttributeType)attributeType modifier:(NSComparisonPredicateModifier)modifier operators:(NSArray<NSNumber *> *)operators options:(NSUInteger)options inEntityDescription:(NSEntityDescription *)entityDescription {
    self = [self initWithLeftExpressions:leftExpressions rightExpressionAttributeType:attributeType modifier:modifier operators:operators options:options];
    if (self) {
        self.entityDescription = entityDescription;
        [self localizeTemplateViewsForKeyPathsInEntityDescription:entityDescription];
    }
    return self;
}

- (NSEntityDescription *)entityDescription {
    return [self associatedValueForKey:@"associatedEntityDescription"];
}

- (void)setEntityDescription:(NSEntityDescription *)entityDescription {
    [self setAssociatedValue:entityDescription forKey:@"associatedEntityDescription"];
}

+ (NSArray <NSPredicateEditorRowTemplate *>*)localizedTemplatesWithAttributeKeyPaths:(NSArray <NSString*>*)keyPaths inEntityDescription:(NSEntityDescription *)entityDescription {
    NSMutableArray *templates = [NSMutableArray arrayWithCapacity:keyPaths.count];
    [templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLocalizedCompoundTypes:@[@(NSAndPredicateType), @(NSOrPredicateType)]] autorelease]];
    
	for (NSString *keyPath in keyPaths) {
        @autoreleasepool {
            NSAttributeDescription *attributeDescription = (entityDescription.attributesByName)[keyPath];
            if (attributeDescription.isTransient) {
                continue;
            }
            
            NSAttributeType attributeType = attributeDescription.attributeType;
            switch (attributeType) {
                case NSStringAttributeType:
                    [templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressionAttributeType:attributeType modifier:NSDirectPredicateModifier operators:@[@(NSContainsPredicateOperatorType), @(NSEqualToPredicateOperatorType), @(NSNotEqualToPredicateOperatorType), @(NSBeginsWithPredicateOperatorType), @(NSEndsWithPredicateOperatorType)] options:NSCaseInsensitivePredicateOption|NSDiacriticInsensitivePredicateOption inEntityDescription:entityDescription] autorelease]];
                    break;
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:
                case NSDoubleAttributeType:
                case NSDecimalAttributeType:
                case NSFloatAttributeType:
                    [templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressionAttributeType:attributeType modifier:NSDirectPredicateModifier operators:@[@(NSLessThanPredicateOperatorType), @(NSLessThanOrEqualToPredicateOperatorType), @(NSGreaterThanPredicateOperatorType), @(NSGreaterThanOrEqualToPredicateOperatorType), @(NSEqualToPredicateOperatorType), @(NSNotEqualToPredicateOperatorType)] options:0 inEntityDescription:entityDescription] autorelease]];
                    break;
                case NSBooleanAttributeType:
                    [templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressionAttributeType:attributeType modifier:NSDirectPredicateModifier operators:@[@(NSEqualToPredicateOperatorType), @(NSNotEqualToPredicateOperatorType)] options:0 inEntityDescription:entityDescription] autorelease]];
                    break;
                case NSDateAttributeType:
                    [templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:@[[NSExpression expressionForKeyPath:keyPath]] rightExpressionAttributeType:attributeType modifier:NSDirectPredicateModifier operators:@[@(NSEqualToPredicateOperatorType), @(NSGreaterThanPredicateOperatorType), @(NSLessThanPredicateOperatorType)] options:0 inEntityDescription:entityDescription] autorelease]];
                    break;
                default:
                    break;
            }
        }
    }
    return templates;
}

+ (NSString *)localizedStringForPredicateType:(NSCompoundPredicateType)predicateType {
    NSString *localizedString = nil;
    switch (predicateType) {
        case NSAndPredicateType:
            localizedString = SSAppKitLocalizedString(@"All", @"predicate editor row template item title");
            break;
        case NSOrPredicateType:
            localizedString = SSAppKitLocalizedString(@"Any", @"predicate editor row template item title");
            break;
        default:
            break;
    }
    return localizedString;
}

+ (NSString *)localizedStringForOperatorType:(NSPredicateOperatorType)operatorType {
    NSString *localizedString = nil;
    switch (operatorType) {
        case NSLessThanPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is less than", @"predicate editor row template item title");
            break;
        case NSLessThanOrEqualToPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is less than or equal to", @"predicate editor row template item title");
            break;
        case NSGreaterThanPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is greater than", @"predicate editor row template item title");
            break;
        case NSGreaterThanOrEqualToPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is greater than or equal to", @"predicate editor row template item title");
            break;
        case NSEqualToPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is", @"predicate editor row template item title");
            break;
        case NSNotEqualToPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"is not", @"predicate editor row template item title");
            break;
        case NSMatchesPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"matches", @"predicate editor row template item title");
            break;
        case NSLikePredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"like", @"predicate editor row template item title");
            break;
        case NSBeginsWithPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"begins with", @"predicate editor row template item title");
            break;
        case NSEndsWithPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"ends with", @"predicate editor row template item title");
            break;
        case NSInPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"in", @"predicate editor row template item title");
            break;
        case NSContainsPredicateOperatorType:
            localizedString = SSAppKitLocalizedString(@"contains", @"predicate editor row template item title");
            break;
        case NSCustomSelectorPredicateOperatorType:
        case NSBetweenPredicateOperatorType:
            break;
    }
    return localizedString;
}

+ (NSString *)localizedStringForKeyPath:(NSString *)keyPath inEntityDescription:(NSEntityDescription *)entityDescription {
    static NSMutableDictionary *detailedLocalizationDictionary = nil;
#if ((!TARGET_OS_IPHONE && defined(__MAC_10_6)) || (TARGET_OS_IPHONE && defined(__IPHONE_4_0)))
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *localizationDictionary = entityDescription.managedObjectModel.localizationDictionary;
        [localizationDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
            @autoreleasepool {
                NSArray *components = [key componentsSeparatedByString:@"/"];
                NSUInteger numberOfComponents = components.count;
                if (numberOfComponents ) {
                    NSString *dictionaryKey = nil;
                    NSString *firstComponent = components[0];
                    if ([firstComponent isEqualToString:@"Entity"]) {
                        dictionaryKey = @"EntityNames";
                    } else if ([firstComponent isEqualToString:@"ErrorString"]) {
                        dictionaryKey = @"ErrorStrings";
                    } else if ([firstComponent isEqualToString:@"Property"]) {
                        switch (numberOfComponents) {
                            case 2:
                                dictionaryKey = @"Properties";
                                break;
                            case 4:
                                dictionaryKey = components[3];
                                break;
                            default:
                                break;
                        }
                    }
                    
                    if (dictionaryKey) {
                        if (!detailedLocalizationDictionary) {
                            detailedLocalizationDictionary = [[NSMutableDictionary alloc] initWithCapacity:localizationDictionary.count];
                        }
                            
                        NSMutableDictionary *dictionary = detailedLocalizationDictionary[dictionaryKey];
                        if (!dictionary) {
                            dictionary = [NSMutableDictionary dictionary];
                            detailedLocalizationDictionary[dictionaryKey] = dictionary;
                        }
                        dictionary[components[1]] = value;
                    }
                }
            }
        }];
        
        __block id __unsafe_unretained observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [detailedLocalizationDictionary release];
            detailedLocalizationDictionary = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
#endif
    NSString *key = [keyPath componentsSeparatedByString:@"."].lastObject;
    if (detailedLocalizationDictionary[entityDescription.name][key]) {
        return detailedLocalizationDictionary[entityDescription.name][key];
    } else if (detailedLocalizationDictionary[@"Properties"][key]) {
        return detailedLocalizationDictionary[@"Properties"][key];
    }
    return key;
}

+ (void)localizeTemplateViews:(NSArray <NSView*> *)templateViews forKeyPathsInEntityDescription:(NSEntityDescription *)entityDescription {
    [templateViews enumerateObjectsUsingBlock:^(id templateView, NSUInteger idx, BOOL *stop) {
        if ([templateView isKindOfClass:[NSPopUpButton class]]) {
            for (NSMenuItem *item in ((NSPopUpButton *)templateView).itemArray) {
                NSString *localizedString = nil;
                id representedObject = item.representedObject;
                if ([representedObject isKindOfClass:[NSNumber class]]) {
                    localizedString = [self.class localizedStringForOperatorType:[representedObject unsignedIntegerValue]];
                } else if ([representedObject isKindOfClass:[NSExpression class]] && [representedObject expressionType] == NSKeyPathExpressionType) {
                    localizedString = [self.class localizedStringForKeyPath:[representedObject keyPath] inEntityDescription:entityDescription];
                }
                
                if (localizedString) {
                    item.title = localizedString;
                }
            }
        }
    }];
}

- (void)localizeTemplateViewsForKeyPathsInEntityDescription:(NSEntityDescription *)entityDescription {
    [self.class localizeTemplateViews:self.templateViews forKeyPathsInEntityDescription:entityDescription];
}

- (void)localizeTemplateViews {
    [self.class localizeTemplateViews:self.templateViews forKeyPathsInEntityDescription:self.entityDescription];
}

@end
