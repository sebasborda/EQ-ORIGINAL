//
//  ALTabBarController.m
//  ALCommon
//
//  Created by Andrew Little on 10-08-17.
//  Copyright (c) 2010 Little Apps - www.myroles.ca. All rights reserved.
//

#import "ALTabBarController.h"
#import "EQOrdersViewController.h"

#define TOP_BAR_HEIGHT -1

@implementation ALTabBarController

@synthesize customTabBarView;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hideExistingTabBar];
    
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"TabBarView" owner:self options:nil];
    self.customTabBarView = [nibObjects objectAtIndex:0];
    UIViewController *controller = [self.viewControllers objectAtIndex:0];
    int y = controller.view.frame.size.height + TOP_BAR_HEIGHT;
    int h = self.customTabBarView.frame.size.height;
    int w = self.customTabBarView.frame.size.width;
    [self.customTabBarView setFrame:CGRectMake(0, y, w, h)];
    self.customTabBarView.delegate = self;
    
    UINavigationController *nav = [self.viewControllers objectAtIndex:0];
    [nav pushViewController:[EQOrdersViewController new] animated:NO];
    
    [self.view addSubview:self.customTabBarView];
}

- (void)hideExistingTabBar{
	for(UIView *view in self.view.subviews){
		if([view isKindOfClass:[UITabBar class]]){
			view.hidden = YES;
			break;
		}
	}
}

-(void) selectTabAtIndex:(int)index{
    [self.customTabBarView selectTabAtIndex:index];
}

#pragma mark ALTabBarDelegate

-(void)tabWasSelected:(NSInteger)index {
    self.selectedIndex = index;
}

@end
