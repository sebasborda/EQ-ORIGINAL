//
//  EQAppDelegate.m
//  EQ
//
//  Created by Sebastian Borda on 3/24/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQAppDelegate.h"
#import "EQLoginViewController.h"
#import "EQLoadingView.h"
#import "EQImagesManager.h"
#import "EQOrdersViewController.h"
#import "EQCommunicationsViewController.h"

@interface EQAppDelegate()

@property (nonatomic,strong) EQLoadingView *loadingView;

@end

@implementation EQAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[EQLoginViewController new]];
    self.loadingView = [[EQLoadingView alloc] initViewWithSize:CGSizeMake(768, 1024) showLargeImage:YES];
    self.loadingView.ownerView = self.window;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    //initialize image cache
    [EQImagesManager sharedInstance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)pushTabBarAtIndex:(int)index{
    [self.navigationController pushViewController:self.tabBarController animated:YES];
    [self.tabBarController selectTabAtIndex:index];
}

- (void)selectTabAtIndex:(int)index{
    [self.tabBarController selectTabAtIndex:index];
}

- (void)showPendingOrders{
    [self selectTabAtIndex:EQTabIndexOrders];
    EQOrdersViewController *controller = (EQOrdersViewController *)self.tabBarController.selectedViewController;
    if ([controller respondsToSelector:@selector(changeStatusFilter:)]) {
        [controller changeStatusFilter:@"pendiente"];
    }
}

- (void)showOperativeCommunications{
    [self selectTabAtIndex:EQTabIndexCommunications];
    [((EQCommunicationsViewController *)self.tabBarController.selectedViewController) changeToOperative];
}

- (void)showCommercialCommunications{
    [self selectTabAtIndex:EQTabIndexCommunications];
    [((EQCommunicationsViewController *)self.tabBarController.selectedViewController) changeToCommercial];
}

- (void)reStartNavigation{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.tabBarController reloadControllers];
}

- (void)showLoadingView{
    [self.loadingView show];
}

- (void)showLoadingViewWithMessage:(NSString *)message{
    [self.loadingView showWithMessage:message];
}

- (void)hideLoadingView{
    [self.loadingView hide];
}

@end
