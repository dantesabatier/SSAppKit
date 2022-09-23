//
//  SSAppKitConstants.h
//  SSAppKit
//
//  Created by Dante Sabatier on 22/02/17.
//
//

#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#if !TARGET_OS_IPHONE
#import <AppKit/NSKeyValueBinding.h>
#import <AppKit/NSImage.h>
#endif

#if TARGET_OS_IPHONE
typedef NSString * NSBindingName NS_TYPED_EXTENSIBLE_ENUM;
typedef NSString * NSImageName NS_TYPED_EXTENSIBLE_ENUM;
#endif

extern NSImageName const SSImageNameThemeBackground NS_SWIFT_NAME(themeBackground);

typedef NSString * SSNumericPredicateEditorRowTemplateRightExpressionsConstant NS_TYPED_EXTENSIBLE_ENUM;

extern SSNumericPredicateEditorRowTemplateRightExpressionsConstant const SSNumericPredicateEditorRowTemplateRightExpressionsConstantTitle;
extern SSNumericPredicateEditorRowTemplateRightExpressionsConstant const SSNumericPredicateEditorRowTemplateRightExpressionsConstantRepresentedObject;

extern NSBindingName const SSObjectAssociatedBindingsKey;
extern NSBindingName const SSUnboundValueKey;
extern NSBindingName const SSObservedKeyPathKey;
extern NSBindingName const SSObservedObjectKey;
extern NSBindingName const SSOptionsKey;
extern NSBindingName const SSValueTransformerBindingOption;
extern NSBindingName const SSValueTransformerNameBindingOption;
extern NSBindingName const SSSelectionIndexPathBinding;
extern NSBindingName const SSContentBinding;
extern NSBindingName const SSSortDescriptorsBinding;
extern NSBindingName const SSValueBinding;
extern NSBindingName const SSSelectionIndexesBinding;
extern NSBindingName const SSSelectedIndexBinding;
extern NSBindingName const SSAnimatesBinding NS_SWIFT_NAME(animates);
extern NSBindingName const SSZoomValueBinding NS_SWIFT_NAME(zoomValue);
