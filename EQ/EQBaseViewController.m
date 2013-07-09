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
@property (nonatomic, strong) UIScrollView *scroll;

@end

@implementation EQBaseViewController 

- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataUpdated:) name:DATA_UPDATED_NOTIFICATION object:nil];
    self.scroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.view.frame = CGRectMake(0, 0, self.scroll.frame.size.width, self.scroll.frame.size.height);
    [self.scroll addSubview:self.view];
    self.view = self.scroll;
	[[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.viewModel loadTopBarData];
    [self loadTopBarInfo];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardDidShowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIKeyboardDidHideNotification];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.scroll.frame.size.height + 210)];
    [self.scroll setContentOffset:CGPointMake(0, 210) animated:YES];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [self.scroll setContentSize:CGSizeMake(self.scroll.frame.size.width, self.scroll.frame.size.height)];
    [self.scroll setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)dataUpdated:(NSNotification *)notification
{
    UIViewController *controller = self.tabBarController.selectedViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = ((UINavigationController *)controller).topViewController;
    }
    if ([controller isKindOfClass:[self class]]) {
        [self.viewModel loadTopBarData];
        [self loadTopBarInfo];
    }
}

- (void)loadTopBarInfo{
    self.pendingOrdersButton.hidden = [self.viewModel obtainPendigOrdersCount] == 0;
    [self.pendingOrdersButton setTitle:[NSString stringWithFormat:@"%i",[self.viewModel obtainPendigOrdersCount]] forState:UIControlStateNormal];
    
    self.goalsButton.hidden = [self.viewModel obtainUnreadGoalsCount] == 0;
    [self.goalsButton setTitle:[NSString stringWithFormat:@"%i",[self.viewModel obtainUnreadGoalsCount]] forState:UIControlStateNormal];
    
    int notificationsCount = [self.viewModel obtainUnreadOperativesCount] + [self.viewModel obtainUnreadCommercialsCount];
    self.notificationsButton.hidden = notificationsCount == 0;
    [self.notificationsButton setTitle:[NSString stringWithFormat:@"%i",notificationsCount] forState:UIControlStateNormal];
    self.sellerNameLabel.text = self.viewModel.sellerName;
    self.dateLabel.text = self.viewModel.currentDateWithFormat;
    self.syncDateLabel.text = self.viewModel.lastUpdateWithFormat;
    self.clientStatusLabel.text = self.viewModel.clientStatus;
    self.clientNameLabel.text = self.viewModel.activeClientName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pendingOrdersAction:(id)sender {
    [APP_DELEGATE showPendingOrders];
}

- (IBAction)notificationsAction:(id)sender {
    NSString *operatives = [NSString stringWithFormat:@"Operativas                    %i",[self.viewModel obtainUnreadOperativesCount]];
    NSString *commercials = [NSString stringWithFormat:@"Oportunidades comerciales     %i",[self.viewModel obtainUnreadCommercialsCount]];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:@[operatives,commercials] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)goalsAction:(id)sender {
    [APP_DELEGATE selectTabAtIndex:EQTabIndexGoals];
}

- (IBAction)logoutAction:(id)sender {
    self.logoutAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Esta a punto de cerrar la session, ¿Desea continuar?" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Continuar", nil];
    [self.logoutAlert  show];
}

- (IBAction)clientsButtonAction:(id)sender {
    [self.viewModel loadClients];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.clientsName delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (void)selectedActiveClientAtIndex:(int)index {
    [self.viewModel selectClientAtIndex:index];
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

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if ([self.chooseClientButton isEqual:self.popoverOwner]) {
        [self.chooseClientButton setTitle:@"" forState:UIControlStateNormal];
        [self closePopover];
        [self selectedActiveClientAtIndex:rowNumber];
        [self clientSelected:selectedData];
    } else if([self.notificationsButton isEqual:self.popoverOwner]) {
        if(rowNumber == 0){
            [APP_DELEGATE showOperativeCommunications];
        } else {
            [APP_DELEGATE showCommercialCommunications];
        }
        [self closePopover];
    }
}

- (void)clientSelected:(NSString *)clientName{
    if (![clientName isEqualToString:@"Todos"]) {
        self.clientNameLabel.text = clientName;
    }
}

@end
