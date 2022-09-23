//
//  SSControl.m
//  SSAppKit
//
//  Created by Dante Sabatier on 18/09/12.
//
//

#import "SSControl.h"

@implementation SSControl

#pragma mark SSKeyValueBinding

- (nullable NSDictionary<NSString *, id> *)infoForBinding:(NSString *)binding {
    if ([self associatedValueForKey:SSObjectAssociatedBindingsKey][binding]) {
        return [self associatedValueForKey:SSObjectAssociatedBindingsKey][binding];
    }
    return [super infoForBinding:binding];
}

#pragma mark NSKeyValueBindingCreation

- (Class)valueClassForBinding:(NSString *)binding {
    if ([binding isEqualToString:SSContentBinding]) {
        return [NSArray class];
    } else if ([binding isEqualToString:SSSelectionIndexesBinding]) {
        return [NSIndexSet class];
    } else if ([binding isEqualToString:SSSelectedIndexBinding] || [binding isEqualToString:SSZoomValueBinding]) {
        return [NSNumber class];
    }
    
    return [super valueClassForBinding:binding];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	if ([self infoForBinding:binding])
        [self unbind:binding];
	
	void *context = [self contextForBinding:binding];
	if (context) {
		[self setInfo: @{SSObservedObjectKey: observable, SSObservedKeyPathKey: keyPath, SSOptionsKey: options ? options : @{}} forBinding:binding];
		[observable addObserver:self forKeyPath:keyPath options:0 context:context];
    } else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }
}

- (void)unbind:(NSString *)binding {
	if ([self contextForBinding:binding]) {
		[[self controllerForBinding:binding] removeObserver:self forKeyPath:[self keyPathForBinding:binding]];
		[self setInfo:nil forBinding:binding];
    } else {
        [super unbind:binding];
    }
}

@end

