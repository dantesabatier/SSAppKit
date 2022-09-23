//
//  SSPopoverPresenterController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 17/02/16.
//
//

#import "SSPopoverPresenterController.h"
#import "SSPopover.h"
#import "SSPopoverView.h"
#import <foundation/NSObject+SSAdditions.h>

@implementation SSPopoverPresenterController

- (instancetype)initWithContentViewController:(__kindof UIViewController *)contentViewController;
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        _popover = [[SSPopover alloc] init];
        _popover.contentViewController = contentViewController;
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_popover release];
    [_sourceView release];
    
    [super ss_dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isBeingPresented && _sourceView && !CGRectIsEmpty(_sourceRect)) {
        CGRectEdge edge = CGRectMinXEdge;
        if (_permittedArrowDirections & SSPopoverArrowDirectionUp) {
            edge = CGRectMaxYEdge;
        } else if (_permittedArrowDirections & SSPopoverArrowDirectionDown) {
            edge = CGRectMinYEdge;
        } else if (_permittedArrowDirections & SSPopoverArrowDirectionLeft) {
            edge = CGRectMinXEdge;
        } else if (_permittedArrowDirections & SSPopoverArrowDirectionRight) {
            edge = CGRectMaxXEdge;
        }
        
        [_popover showRelativeToRect:[self.view convertRect:_sourceRect fromView:_sourceView] ofView:self.view preferredEdge:edge];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.isBeingDismissed) {
        [_popover close];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    NSLog(@"%@ %@", self.class, NSStringFromSelector(_cmd));
}

#pragma mark getters & setters

- (__kindof UIViewController *)contentViewController
{
    return _popover.contentViewController;
}

- (id <SSPopoverPresenterControllerDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<SSPopoverPresenterControllerDelegate>)delegate
{
    _delegate = delegate;
}

- (SSPopoverArrowDirection)permittedArrowDirections
{
    return _permittedArrowDirections;
}

- (void)setPermittedArrowDirections:(SSPopoverArrowDirection)permittedArrowDirections
{
    _permittedArrowDirections = permittedArrowDirections;
}

- (__kindof UIView *)sourceView
{
    return _sourceView;
}

- (void)setSourceView:(__kindof UIView *)sourceView
{
    SSNonAtomicRetainedSet(_sourceView, sourceView);
}

- (CGRect)sourceRect
{
    return _sourceRect;
}

- (void)setSourceRect:(CGRect)sourceRect
{
    _sourceRect = sourceRect;
}

- (SSPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}

@end
