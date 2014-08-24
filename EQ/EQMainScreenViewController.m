//
//  EQMainScreenViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/19/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQMainScreenViewController.h"
#import "EQMainScreenViewModel.h"
#import "EQSession.h"
#import "EQDataManager.h"

@interface EQMainScreenViewController () 

@property (nonatomic,strong) EQMainScreenViewModel *viewModel;
@property (nonatomic,strong) EQCreateClientViewController *createClient;
@property (nonatomic,strong) UIAlertView *updateDataAlert;
@property (nonatomic,strong) UIAlertView *updateImagesAlert;

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
    self.loggedUserLabel.text = [[self.viewModel loggedUserName] uppercaseString];
    self.versionLabel.text = [NSString stringWithFormat:@"Número de versión: %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (IBAction)sectionButtonAction:(id)sender{
    UIButton *button = (UIButton *)sender;
    [APP_DELEGATE selectTabAtIndex:button.tag];
}

- (IBAction)createClientButtonAction:(id)sender {
    self.createClient = [EQCreateClientViewController new];
    self.createClient.delegate = self;
    [self presentViewController:self.createClient animated:YES completion:nil];
}

- (IBAction)updateDataAction:(id)sender {
    self.updateDataAlert = [[UIAlertView alloc] initWithTitle:@"Actualizar datos" message:@"La actualización puede tardar varios minutos" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
    [self.updateDataAlert show];
}

- (IBAction)updateImages:(id)sender {
    self.updateImagesAlert = [[UIAlertView alloc] initWithTitle:@"Actualizar imagenes de articulos" message:@"La actualización puede tardar varios minutos" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Aceptar", nil];
    [self.updateImagesAlert show];
}

- (void)createClientCancelled{
    [self.createClient dismissViewControllerAnimated:YES completion:nil];
}

- (void)clientSaved{
    [self.createClient dismissViewControllerAnimated:YES completion:nil];
    [APP_DELEGATE selectTabAtIndex:EQTabIndexOrders];
}

- (void)clientSelected:(NSString *)clientName{
    self.chooseClientButton.titleLabel.text = [NSString stringWithFormat:@"  %@",clientName];
    [self closePopover];
    [APP_DELEGATE selectTabAtIndex:EQTabIndexOrders];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        if (self.updateDataAlert == alertView) {
            self.updateImagesAlert = nil;
            [[EQSession sharedInstance] forceSynchronization];
        } else if (self.updateImagesAlert == alertView) {
            [[EQDataManager sharedInstance] forceDownloadArticlesImage];
        }
    }

}

@end
