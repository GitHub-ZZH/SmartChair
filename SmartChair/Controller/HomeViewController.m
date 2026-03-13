//
//  HomeViewController.m
//  SmartChair
//
//  Created by 张志恒 on 2025/12/25.
//

#import "HomeViewController.h"
#import "DeviceViewController.h"
#import "SideViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SideViewController *sidebarVC = [[SideViewController alloc] init];
    UINavigationController *sidebarNav =
        [[UINavigationController alloc] initWithRootViewController:sidebarVC];
    sidebarVC.view.backgroundColor = [UIColor lightGrayColor];
    
    UIViewController *detailVC = [[DeviceViewController alloc] init];
    UINavigationController *detailNav =
        [[UINavigationController alloc] initWithRootViewController:detailVC];
    detailVC.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    self.viewControllers = @[sidebarNav, detailNav];
//    self.preferredSplitBehavior = UISplitViewControllerSplitBehaviorTile;
//    self.primaryBackgroundStyle = UISplitViewControllerBackgroundStyleSidebar;
}

@end
