//
//  EQBaseViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewController.h"
#import "EQTablePopover.h"
#import "EQSession.h"
#import "EQPopover.h"
#import <QuartzCore/QuartzCore.h>

@interface EQBaseViewController ()

@property (nonatomic, strong) UIPopoverController *popoverVC;
@property (nonatomic, strong) EQBaseViewModel *viewModel;
@property (nonatomic, strong) UIAlertView *logoutAlert;

@end

@implementation EQBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
    
    self.sellerNameLabel.text = self.viewModel.sellerName;
    self.dateLabel.text = self.viewModel.currentDateWithFormat;
    self.syncDateLabel.text = self.viewModel.lastUpdateWithFormat;
    self.clientStatusLabel.text = self.viewModel.clientStatus;
    self.clientNameLabel.text = self.viewModel.clientName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pendingOrdersAction:(id)sender {
    [self notImplemented];
}

- (IBAction)notificationsAction:(id)sender {
    [self notImplemented];
}

- (IBAction)goalsAction:(id)sender {
    [self notImplemented];
}

- (IBAction)logoutAction:(id)sender {
    self.logoutAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Esta a punto de cerrar la session, ¿Desea continuar?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Continuar", nil];
    [self.logoutAlert  show];
    
}

- (void)logout{
    [[EQSession sharedInstance] endSession];
    [APP_DELEGATE reStartNavigation];
}

- (void)startLoading{
    [APP_DELEGATE showLoadingView];
}

- (void)stopLoading{
    [APP_DELEGATE hideLoadingView];
}

- (void)presentPopoverInView:(UIButton *)view withContent:(UIViewController *)content{
    self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:content];
    [self.popoverVC presentPopoverFromRect:view.frame inView:view.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    if ([content conformsToProtocol:@protocol(EQPopover)]) {
        [self.popoverVC setPopoverContentSize:[((id<EQPopover>)content) popoverSize] animated:NO];
    }
    
    self.popoverOwner = view;
}

- (BOOL)isButtonPopoverOwner:(UIButton *)view{
    return [self.popoverOwner isEqual:view];
}

- (void)closePopover{
    [self.popoverVC dismissPopoverAnimated:YES];
}

- (void)modelWillStartDataLoading{
    [self startLoading];
}

- (void)modelDidUpdateData{
    [self stopLoading];
}

- (void)modelDidFinishWithError:(NSError *)error{
    [self stopLoading];
}

- (UIImage *)captureView:(UIView *)view {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)notImplemented{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Funcionalidad no implementada" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.logoutAlert == alertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self logout];
        }
    }
}

@end
