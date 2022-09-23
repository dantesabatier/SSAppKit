//
//  SSInspectorView.m
//  SSAppKit
//
//  Created by Dante Sabatier on 7/15/11.
//  Copyright 2011 Dante Sabatier. All rights reserved.
//


#import "SSInspectorView.h"
#import "SSInspectorCell.h"
#import "SSInspectorHeaderView.h"
#import <SSFoundation/NSObject+SSAdditions.h>
#import <SSFoundation/NSArray+SSAdditions.h>
#import <SSFoundation/NSNumber+SSAdditions.h>
#import "SSValidatedButton.h"
#import "NSColor+SSAdditions.h"
#import "NSWindow+SSAdditions.h"

NSString * const SSInspectorViewHeaderTitleAttributesKey = @"SSInspectorViewHeaderTitleAttributesKey";
NSString * const SSInspectorViewHeaderHeightKey = @"SSInspectorViewHeaderHeightKey";

static char SSInspectorViewTitleObservationContext;
static char SSInspectorViewIconObservationContext;

#define SSInspectorViewExpandedItemIdentifiersPreferencesKey [NSString stringWithFormat:@"%@ Expanded Items %@", NSStringFromClass(self.class), [self autosaveName]]

@interface SSInspectorView() <SSInspectorCellDelegate> 

@end

@implementation SSInspectorView

+ (void)initialize {
    if (self == SSInspectorView.class) {
        [self exposeBinding:SSContentBinding];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            [self setValue:@{NSForegroundColorAttributeName: [NSColor labelColor]} forKey:SSInspectorViewHeaderTitleAttributesKey];
        }
#endif
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            [self setValue:@{NSForegroundColorAttributeName: [NSColor labelColor]} forKey:SSInspectorViewHeaderTitleAttributesKey];
        }
#endif
    }
    return self;
}

- (void)dealloc {
    [_cachedCells release];
    [_undefinedValues release];
    [_backgroundColor release];
	[_autosaveName release];

	[super ss_dealloc];
}

- (void)prepareForInterfaceBuilder {
    
}

- (void)drawRect:(CGRect)dirtyRect {
    id backgroundColor = self.backgroundColor;
    if (backgroundColor) {
#if !TARGET_OS_IPHONE && !TARGET_INTERFACE_BUILDER
        BOOL isActive = self.window.isActive;
        BOOL needsDisplayWhenWindowResignsKey = self.needsDisplayWhenWindowResignsKey;
        BOOL allowsVibrancy = NO;
#if defined(__MAC_10_10)
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
            allowsVibrancy = self.effectiveAppearance.allowsVibrancy;
        }
#endif
        if ((needsDisplayWhenWindowResignsKey && !isActive) || (allowsVibrancy && !isActive)) {
            backgroundColor = [NSColor windowBackgroundColor];
        }
        
        [NSGraphicsContext saveGraphicsState];
        [backgroundColor setFill];
        NSRectFill(self.bounds);
        [NSGraphicsContext restoreGraphicsState];
#endif
    }
}

#pragma mark layout

- (void)layout {
    [super layout];
    [self sizeToFit];
    
    CGFloat maxW = self.enclosingScrollView.contentSize.width;
    CGFloat maxY = _contentInsets.top;
    CGFloat minX = _contentInsets.bottom;
    CGFloat maxX = _contentInsets.right;
    NSArray *content = self.content;
    for (id obj in content) {
        SSInspectorCell *cell = [self reusableCellForItem:obj];
        cell.frame = CGRectIntegral(CGRectMake(minX, maxY, maxW - (minX+maxX), CGRectGetHeight(cell.frame)));
        
        maxY += FLOOR(CGRectGetHeight(cell.frame) + _minimumLineSpacing);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGFloat maxY = _contentInsets.top;
	CGFloat minY = _contentInsets.top;
    NSArray *content = self.content;
    for (id obj in content) {
        SSInspectorCell *cell = [self reusableCellForItem:obj];
        maxY += CGRectGetHeight(cell.frame) + _minimumLineSpacing;
    }
    
    maxY += minY ? minY - _minimumLineSpacing : 0;
    return CGSizeMake(MAX(self.enclosingScrollView.contentSize.width, 0), MAX(FLOOR(maxY), self.enclosingScrollView.contentSize.height));
}

#pragma mark cells

- (SSInspectorCell *)newCellForItem:(SSInspectorItem *)item {
    CGRect frame = item.view.frame;
    frame.size.height += 17.0;
    frame.size.width = CGRectGetWidth(self.frame);
    
    SSInspectorCell *cell = [[SSInspectorCell alloc] initWithFrame:frame];
    cell.delegate = self;
    cell.contentView = item.view;
    
    if ([item respondsToSelector:@selector(accessoryView)]) {
        cell.headerView.accessoryView = item.accessoryView;
    }
    
    return cell;
}

- (SSInspectorCell *)reusableCellForItem:(SSInspectorItem *)item {
    NSString *identifier = item.identifier;
    if (!identifier) {
        SSDebugLog(@"%@ %@ invalid item \"%@\"", self.class, NSStringFromSelector(_cmd), item);
        return nil;
    }
    
    SSInspectorCell *cell = _cachedCells[identifier];
    if (!cell) {
        cell = [[self newCellForItem:item] autorelease];
        if (!_cachedCells) {
            _cachedCells = [[NSMutableDictionary alloc] initWithCapacity:100];
        }
        _cachedCells[identifier] = cell;
    }
    return cell;
}

- (CGRect)frameForItemAtIndex:(NSInteger)index {
    return [self cellForItemAtndex:index].frame;
}

- (SSInspectorCell *)cellForItemAtndex:(NSInteger)index {
    return [self reusableCellForItem:[_content safeObjectAtIndex:index]];
}

#pragma mark actions

- (void)expandItem:(SSInspectorItem *)item {
	SSInspectorCell *inspectorCell = [self reusableCellForItem:item];
    if (!inspectorCell.isExpanded) {
        [inspectorCell toggle:nil];
    }
}

- (void)collapseItem:(SSInspectorItem *)item {
	SSInspectorCell *inspectorCell = [self reusableCellForItem:item];
    if (inspectorCell.isExpanded) {
        [inspectorCell toggle:nil];
    } 
}

- (void)reloadItem:(SSInspectorItem *)item {
    SSInspectorCell *inspectorCell = [self reusableCellForItem:item];
    inspectorCell.contentView = item.view;
		
	NSString *title = item.title;
	if (!title || !title.length) {
		NSLog(@"%@ Warning!, item \"title\" property cannot be nil.", self);
		title = @" ";
	}
	
	SSInspectorHeaderView *headerView = inspectorCell.headerView;
    headerView.state = inspectorCell.isExpanded;
    if ([self valueForKey:SSInspectorViewHeaderTitleAttributesKey]) {
        headerView.attributedTitle = [[[NSAttributedString alloc] initWithString:title attributes:[self valueForKey:SSInspectorViewHeaderTitleAttributesKey]] autorelease];
    } else {
        headerView.title = title;
    }
    
    if ([item respondsToSelector:@selector(icon)]) {
        headerView.icon = [item icon];
    }
}

- (BOOL)isExpandable:(SSInspectorItem *)item {
	return !((SSInspectorCell *)item.view.superview).isExpanded;
}

#if TARGET_OS_IPHONE

#else

#pragma mark NSEvent

- (void)mouseDown:(NSEvent *)event {
	
}

#pragma mark NSView

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    if (!self.window) {
        return;
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidResignKeyNotification object:self.window];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setNeedsDisplay) name:NSWindowDidBecomeKeyNotification object:self.window];
    
    [self layout];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
	[super viewWillMoveToWindow:newWindow];
	
	[NSNotificationCenter.defaultCenter removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
	[NSNotificationCenter.defaultCenter removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
}

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    if (_backgroundColor) {
        self.enclosingScrollView.backgroundColor = _backgroundColor;
    }
}

#endif

#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((context == &SSInspectorViewTitleObservationContext) || (context == &SSInspectorViewIconObservationContext)) {
        [self reloadItem:object];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark SSInspectorCellDelegate

- (void)inspectorCellWillCollapse:(SSInspectorCell *)inspectorCell {
    
}

- (void)inspectorCellDidCollapse:(SSInspectorCell *)inspectorCell {
	NSString *identifier = inspectorCell.inspectorItem.identifier;
    NSArray *expandedIds = [[NSUserDefaults standardUserDefaults] arrayForKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey] ? [[NSUserDefaults standardUserDefaults] arrayForKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey] : @[];
	if ([expandedIds containsObject:identifier]) {
		NSMutableArray *ids = [[expandedIds mutableCopy] autorelease];
		[ids removeObject:identifier];
		
		[[NSUserDefaults standardUserDefaults] setObject:ids forKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey];
	}
	[self layout];
    //[self centerRectInVisibleArea:inspectorCell.frame];
}

- (void)inspectorCellWillExpand:(SSInspectorCell *)inspectorCell {
    
}

- (void)inspectorCellDidExpand:(SSInspectorCell *)inspectorCell {
	NSString *identifier = inspectorCell.inspectorItem.identifier;
    NSArray *expandedIds = [[NSUserDefaults standardUserDefaults] arrayForKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey] ? [[NSUserDefaults standardUserDefaults] arrayForKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey] : @[];
	if (![expandedIds containsObject:identifier]) {
		NSMutableSet *ids = [NSMutableSet setWithArray:expandedIds];
		[ids addObject:identifier];
		
		[[NSUserDefaults standardUserDefaults] setObject:ids.allObjects forKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey];
	}
	[self layout];
    //[self centerRectInVisibleArea:inspectorCell.frame];
}

#pragma mark getters & setters

- (NSArray *)undefinedKeys {
    return @[SSInspectorViewHeaderTitleAttributesKey, SSInspectorViewHeaderHeightKey];
}

- (NSMutableDictionary *)undefinedValues {
    if (!_undefinedValues) {
        _undefinedValues = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return _undefinedValues;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return [self.undefinedKeys containsObject:key] ? (self.undefinedValues)[key] : [super valueForUndefinedKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([self.undefinedKeys containsObject:key]) {
        [self.undefinedValues setValue:value forKey:key];
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

- (id)backgroundColor {
    return _backgroundColor;
}

- (void)setBackgroundColor:(id)backgroundColor {
    SSNonAtomicCopiedSet(_backgroundColor, backgroundColor);
    self.enclosingScrollView.backgroundColor = backgroundColor;
    [self setNeedsDisplay];
}

- (NSArray *)content {
    return _content;
}

- (void)setContent:(NSArray *)content {
    if ([_content isEqualToArray:content]) {
        return;
    }
    for (id item in _content) {
        [item removeObserver:self forKeyPath:SSInspectorItemIconBinding];
        [item removeObserver:self forKeyPath:SSInspectorItemTitleBinding];
        
        SSInspectorCell *cell = [self reusableCellForItem:item];
        cell.inspectorItem = nil;
		[cell removeFromSuperview];
    }
    
    SSNonAtomicCopiedSet(_content, content);
    
    for (id item in content) {
        @autoreleasepool {
            [item addObserver:self forKeyPath:SSInspectorItemIconBinding options:0 context:&SSInspectorViewIconObservationContext];
            [item addObserver:self forKeyPath:SSInspectorItemTitleBinding options:0 context:&SSInspectorViewTitleObservationContext];
            
            SSInspectorCell *cell = [self reusableCellForItem:item];
            cell.inspectorItem = item;
            
            [self reloadItem:item];
            
            BOOL expanded = (_autosaveExpandedItems && _autosaveName && [[[NSUserDefaults standardUserDefaults] arrayForKey:SSInspectorViewExpandedItemIdentifiersPreferencesKey] containsObject:[item identifier]]);
            
            SSInspectorHeaderView *headerView = cell.headerView;
            headerView.state = expanded ? 1 : 0;
            
            if (expanded) {
                [self expandItem:item];
            } else {
                [self collapseItem:item];
            }
            
            [self addSubview:cell];
        }
    }
    
	[self layout];
}

- (CGFloat)minimumLineSpacing {
    return _minimumLineSpacing;
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing {
    _minimumLineSpacing = minimumLineSpacing;
    self.needsLayout = YES;
}

- (NSEdgeInsets)contentInsets {
    return _contentInsets;
}

- (void)setContentInsets:(NSEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    self.needsLayout = YES;
}

- (NSString *)autosaveName {
    return _autosaveName;
}

- (void)setAutosaveName:(NSString *)autosaveName {
    SSNonAtomicCopiedSet(_autosaveName, autosaveName);
}

- (BOOL)autosaveExpandedItems {
    return _autosaveExpandedItems;
}

- (void)setAutosaveExpandedItems:(BOOL)autosaveExpandedItems {
    _autosaveExpandedItems = autosaveExpandedItems;
}

- (BOOL)allowsVibrancy {
    return NO;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)isFlipped {
	return YES;
}

@end
