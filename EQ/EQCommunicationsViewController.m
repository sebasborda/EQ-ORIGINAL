//
//  EQCommunicationsViewController.m
//  EQ
//
//  Created by Sebastian Borda on 6/13/13.
//  Copyright (c) 2013 EQ. All rights reserved.
//

#import "EQCommunicationsViewController.h"
#import "EQCommunicationsViewModel.h"

@interface EQCommunicationsViewController ()

@property (nonatomic,strong) EQCommunicationsViewModel *viewModel;

@end

@implementation EQCommunicationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad{
    self.viewModel = [EQCommunicationsViewModel new];
//    self.viewModel.delegate = self;
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
