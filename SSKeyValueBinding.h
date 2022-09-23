//
//  SSKeyValueBinding.h
//  SSAppKit
//
//  Created by Dante Sabatier on 7/11/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//

#import "SSAppKitConstants.h"
#if TARGET_OS_IPHONE
#import <CoreData/CoreData.h>
#import <foundation/NSObject+SSAdditions.h>
#else
#import <SSFoundation/NSObject+SSAdditions.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol SSKeyValueBinding <SSObject>

- (nullable NSDictionary<NSString *, id> *)infoForBinding:(NSString *)binding;
- (void)setInfo:(nullable NSDictionary<NSString *, id> *)info forBinding:(NSString *)binding;
- (nullable void *)contextForBinding:(NSString *)binding NS_RETURNS_INNER_POINTER;

@end

@interface NSObject (SSKeyValueBindingAdditions)

- (nullable id)valueForBinding:(NSString *)binding;
- (void)setValue:(nullable id)value forBinding:(NSString *)binding;
- (nullable id)controllerForBinding:(NSString *)binding;
- (nullable NSString *)keyPathForBinding:(NSString *)binding;
- (nullable NSValueTransformer *)valueTransformerForBinding:(NSString *)binding;

@end

@interface NSObject (SSKeyValueBindingCreation) <SSKeyValueBinding>

#if TARGET_OS_IPHONE
+ (void)exposeBinding:(NSString *)binding;
@property (nullable, readonly, copy) NSArray<NSString *> *exposedBindings;
- (nullable Class)valueClassForBinding:(NSString *)binding;
- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(nullable NSDictionary<NSString *, id> *)options;
- (void)unbind:(NSString *)binding;
- (nullable NSDictionary<NSString *, id> *)infoForBinding:(NSString *)binding;
- (nullable NSArray<NSAttributeDescription *> *)optionDescriptionsForBinding:(NSString *)aBinding;
#endif
- (void)setInfo:(nullable NSDictionary<NSString *, id> *)info forBinding:(NSString *)binding;
- (nullable void *)contextForBinding:(NSString *)binding NS_RETURNS_INNER_POINTER;

@end

NS_ASSUME_NONNULL_END
