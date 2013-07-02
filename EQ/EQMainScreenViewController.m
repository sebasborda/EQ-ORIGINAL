//
//  EQMainScreenViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQMainScreenViewController.h"
#import "EQMainScreenViewModel.h"

@interface EQMainScreenViewController ()

@property (nonatomic,strong) EQMainScreenViewModel *viewModel;
@property (nonatomic,strong) EQCreateClientViewController *createClient;

@end

@implementation EQMainScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewModel = [EQMainScreenViewModel new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.loggedUserLabel.text = [self.viewModel loggedUserName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sectionButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    [APP_DELEGATE pushTabBarAtIndex:button.tag];
}

- (IBAction)createClientButtonAction:(id)sender {
    self.createClient = [EQCreateClientViewController new];
    self.createClient.delegate = self;
    [self presentViewController:self.createClient animated:YES completion:nil];
}

- (void)clientCreateClosed{
    [self.createClient dismissViewControllerAnimated:YES completion:nil];
}

- (void)clientSelected:(NSString *)clientName{
    self.clientsButton.titleLabel.text = [NSString stringWithFormat:@"  %@",clientName];
    [self closePopover];
    [APP_DELEGATE pushTabBarAtIndex:EQTabIndexOrders];
}

@end
