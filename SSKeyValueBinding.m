//
//  SSKeyValueBinding.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSKeyValueBinding.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import <foundation/NSArray+SSAdditions.h>
#else
#import <SSFoundation/NSArray+SSAdditions.h>
#endif

@implementation NSObject (SSKeyValueBindingAdditions)

- (id)valueForBinding:(NSString *)binding {
	id controller = [self controllerForBinding:binding];
    if (!controller) {
        return ([(id <SSKeyValueBinding>)self infoForBinding:binding])[SSUnboundValueKey];
    }
    
	id value = [controller valueForKeyPath:[self keyPathForBinding:binding]];
	
    NSValueTransformer *transformer = [self valueTransformerForBinding:binding];
    if ([transformer isKindOfClass:[NSValueTransformer class]]) {
        value = [transformer transformedValue:value];
    }
	
	return value;
}

- (void)setValue:(id)value forBinding:(NSString *)binding {
    NSValueTransformer *transformer = [self valueTransformerForBinding:binding];
    if ([transformer isKindOfClass:[NSValueTransformer class]] && [[transformer class] allowsReverseTransformation]) {
        value = [transformer reverseTransformedValue:value];
    }
    
	id controller = [self controllerForBinding:binding];
	if (controller) {
		[controller setValue:value forKeyPath:[self keyPathForBinding:binding]];
		return;
	}
    
	NSDictionary *info = nil;
    if (value) {
        info = @{SSUnboundValueKey: value};
    }
    
	[(id <SSKeyValueBinding>)self setInfo:info forBinding:binding];
	[self observeValueForKeyPath:nil ofObject:nil change:nil context:[(id <SSKeyValueBinding>)self contextForBinding:binding]];
}

- (id)controllerForBinding:(NSString *)binding {
    return [(id <SSKeyValueBinding>)self infoForBinding:binding][SSObservedObjectKey];
}

- (NSString *)keyPathForBinding:(NSString *)binding {
    return [(id <SSKeyValueBinding>)self infoForBinding:binding][SSObservedKeyPathKey];
}

- (NSValueTransformer *)valueTransformerForBinding:(NSString *)binding {
	NSDictionary *bindingOptions = [(id <SSKeyValueBinding>)self infoForBinding:binding][SSOptionsKey];
    if (bindingOptions[SSValueTransformerBindingOption]) {
        return bindingOptions[SSValueTransformerBindingOption];
    }
    
    if (bindingOptions[SSValueTransformerNameBindingOption]) {
        return [NSValueTransformer valueTransformerForName:bindingOptions[SSValueTransformerNameBindingOption]];
    }
    
    return nil;
}

@end

@interface SSBinder : NSObject

@end

@implementation SSBinder

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    NSDictionary *bindings = [[self.associatedObject associatedValueForKey:SSObjectAssociatedBindingsKey] copy];
    for (NSString *binding in bindings.allKeys) {
        [self unbind:binding];
    }
    [bindings release];
    
    [super ss_dealloc];
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(nullable NSDictionary<NSString *, id> *)options {
    [self unbind:binding];
    
    id associatedObject = self.associatedObject;
    //NSLog(@"%@ binding:%@ toObject:%@ withKeyPath:%@ options:%@", [associatedObject class], binding, [observable class], keyPath, options);
    if (![associatedObject infoForBinding:binding]) {
        [associatedObject addObserver:self forKeyPath:binding options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:[associatedObject contextForBinding:binding]];
        
        [associatedObject setInfo:@{SSObservedObjectKey:observable, SSObservedKeyPathKey:keyPath, SSOptionsKey:options ? options : @{}} forBinding:binding];
    }
    
    if (![observable infoForBinding:keyPath]) {
        [observable addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:[observable contextForBinding:keyPath]];
        
        [observable setInfo:@{SSObservedObjectKey:associatedObject, SSObservedKeyPathKey:binding, SSOptionsKey:options ? options : @{}} forBinding:keyPath];
    }
}

- (void)unbind:(NSString *)binding {
    id associatedObject = self.associatedObject;
    //NSLog(@"%@ unbind:%@", [associatedObject class], binding);
    id observable = [associatedObject controllerForBinding:binding];
    NSString *keyPath = [associatedObject keyPathForBinding:binding];
    if ([observable infoForBinding:keyPath]) {
        [observable removeObserver:self forKeyPath:keyPath context:[observable contextForBinding:binding]];
        [observable setInfo:nil forBinding:binding];
    }
    
    if ([associatedObject infoForBinding:binding]) {
        [associatedObject removeObserver:self forKeyPath:binding context:[associatedObject contextForBinding:binding]];
        [associatedObject setInfo:nil forBinding:binding];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    id associatedObject = self.associatedObject;
    //NSLog(@"%@ observeValueForKeyPath:%@ ofObject:%@ change:%@ context:%@", [associatedObject class], keyPath, [object class], change, context);
    if ([object isEqual:associatedObject]) {
        NSString *binding = [object keyPathForBinding:keyPath];
        if (binding) {
            id observable = [object controllerForBinding:keyPath];
            if (observable) {
                id newValue = [object valueForKey:keyPath];
                id oldValue = [observable valueForKeyPath:binding];
                Class class = [observable valueClassForBinding:binding];
                if (!class) {
                    class = [oldValue superclass];
                }
                
                if ([newValue isKindOfClass:class] && ![newValue isEqual:oldValue]) {
                    [observable setValue:newValue forKeyPath:binding];
                }
            }
        }
    } else {
        NSDictionary *associatedBindings = [associatedObject associatedValueForKey:SSObjectAssociatedBindingsKey];
        NSString *binding = [associatedBindings.allKeys firstObjectPassingTest:^BOOL(NSString *key) {
            return [associatedBindings[key][SSObservedKeyPathKey] isEqualToString:keyPath] && [associatedBindings[key][SSObservedObjectKey] isEqual:object];
        }];
        if (binding) {
            id newValue = [associatedObject valueForBinding:binding];
            id oldValue = [associatedObject valueForKey:binding];
            if (![newValue isEqual:oldValue]) {
                [associatedObject setValue:newValue forKey:binding];
            }
        }
    }
}

@end

@implementation NSObject (SSKeyValueBindingCreation)

#if TARGET_OS_IPHONE

+ (void)exposeBinding:(NSString *)binding {
    
}

- (NSArray *)exposedBindings {
    return nil;
}

- (nullable Class)valueClassForBinding:(NSString *)binding {
    return nil;
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(nullable NSDictionary<NSString *, id> *)options {
    NSParameterAssert(binding != nil);
    NSParameterAssert(observable != nil);
    NSParameterAssert(keyPath != nil);
    
    SSBinder *binder = [self associatedValueForKey:@"associatedBinder"];
    if (!binder) {
        binder = [[[SSBinder alloc] init] autorelease];
        binder.associatedObject = self;
        [self setAssociatedValue:binder forKey:@"associatedBinder"];
    }
    [binder bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString *)binding {
    [[self associatedValueForKey:@"associatedBinder"] unbind:binding];
}

- (NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(NSString *)binding {
    return nil;
}

- (nullable NSDictionary<NSString *, id> *)infoForBinding:(NSString *)binding {
    return [self associatedValueForKey:SSObjectAssociatedBindingsKey][binding];
}

#endif

- (void)setInfo:(nullable NSDictionary<NSString *, id> *)info forBinding:(NSString *)binding {
    NSMutableDictionary *associatedBindings = [self associatedValueForKey:SSObjectAssociatedBindingsKey];
    if (!associatedBindings) {
        associatedBindings = [NSMutableDictionary dictionary];
        [self setAssociatedValue:associatedBindings forKey:SSObjectAssociatedBindingsKey];
    }
    
    [associatedBindings setValue:info forKey:binding];
}

- (nullable void *)contextForBinding:(NSString *)binding {
    return NULL;
}

@end

