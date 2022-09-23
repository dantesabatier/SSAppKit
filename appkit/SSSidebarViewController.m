//
//  SSSidebarViewController.m
//  SSAppKit
//
//  Created by Dante Sabatier on 16/02/16.
//
//

#import "SSSidebarViewController.h"
#import "SSSidebarPresenterViewController.h"
#import <foundation/NSArray+SSAdditions.h>

#define SSSidebarViewControllerTableViewHeight 54.0

@interface SSSidebarViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation SSSidebarViewController

- (instancetype)initWithContentViewControllers:(NSArray <__kindof UIViewController *> *)contentViewControllers sidebarPresenterViewController:(__kindof UIViewController *)sidebarPresenterViewController;
{
    self = [super init];
    if (self) {
        self.sidebarPresenterViewController = sidebarPresenterViewController;
        self.contentViewControllers = contentViewControllers;
    }
    return self;
}

- (void)dealloc
{
    self.contentViewControllers = nil;
    self.selectedContentViewController = nil;
    self.sidebarPresenterViewController = nil;
    self.shown = NO;
    
    [super ss_dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray <__kindof UIViewController *> *contentViewControllers = self.contentViewControllers;
    NSInteger numberOfItems = contentViewControllers.count;
    UITableView *tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - SSSidebarViewControllerTableViewHeight * numberOfItems) * 0.5, self.view.frame.size.width, SSSidebarViewControllerTableViewHeight * numberOfItems) style:UITableViewStylePlain] autorelease];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.opaque = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.bounces = NO;
    
    [self.view addSubview:tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.contentViewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    NSArray <__kindof UIViewController *> *contentViewControllers = self.contentViewControllers;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:22.0];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[[UIView alloc] init] autorelease];
    }
    cell.textLabel.text = [contentViewControllers valueForKey:@"title"][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SSSidebarViewControllerTableViewHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedContentViewController = self.contentViewControllers[indexPath.row];
    [self.sidebarPresenterViewController dismissSidebarViewControllerAnimated:YES completion:nil];
}

#pragma mark getters & setters

- (NSArray <__kindof UIViewController *> *)contentViewControllers
{
    return [self associatedValueForKey:@"contentViewControllers"];
}

- (void)setContentViewControllers:(NSArray<__kindof UIViewController *> *)contentViewControllers
{
    for (__kindof UIViewController *contentViewController in self.contentViewControllers) {
        [contentViewController.view removeFromSuperview];
        [contentViewController removeFromParentViewController];
    }
    
    [self setNonAtomicRetainedAssociatedValue:contentViewControllers forKey:@"contentViewControllers"];
    
    for (__kindof UIViewController *contentViewController in self.contentViewControllers) {
        [self.sidebarPresenterViewController addChildViewController:contentViewController];
    }
    
    [(UITableView *)[self.view.subviews firstObjectPassingTest:^BOOL(__kindof UIView * _Nonnull obj) {
        return [obj isKindOfClass:[UITableView class]];
    }] reloadData];
}

- (__kindof UIViewController *)selectedContentViewController
{
    __kindof UIViewController *selectedContentViewController = [self associatedValueForKey:@"selectedContentViewController"];
    if (!selectedContentViewController) {
        selectedContentViewController = self.contentViewControllers.firstObject;
        self.selectedContentViewController = selectedContentViewController;
    }
    return selectedContentViewController;
}

- (void)setSelectedContentViewController:(__kindof UIViewController * _Nullable)selectedContentViewController
{
    [self setWeakAssociatedValue:selectedContentViewController forKey:@"selectedContentViewController"];
}

- (__kindof UIViewController *)sidebarPresenterViewController
{
    return [self associatedValueForKey:@"sidebarPresenterViewController"];
}

- (void)setSidebarPresenterViewController:(__kindof SSSidebarPresenterViewController * _Nullable)sidebarPresenterViewController
{
    [self setWeakAssociatedValue:sidebarPresenterViewController forKey:@"sidebarPresenterViewController"];
}

- (BOOL)isShown
{
    NSNumber *number = [self associatedValueForKey:@"shown"];
    return number.boolValue;
}

- (void)setShown:(BOOL)shown
{
    if (shown) {
        [self setNonAtomicRetainedAssociatedValue:@(shown) forKey:@"shown"];
    } else {
        [self setNonAtomicRetainedAssociatedValue:nil forKey:@"shown"];
    }
}

@dynamic shown;
@dynamic contentViewControllers;
@dynamic selectedContentViewController;
@dynamic sidebarPresenterViewController;

@end
