//
//  EQOrdersViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQOrdersViewController.h"
#import "EQNewOrderViewController.h"
#import "EQOrdersViewModel.h"

#define cellIdentifier @"OrderCell"

@interface EQOrdersViewController ()

@property (nonatomic, strong) EQOrdersViewModel *viewModel;
@property (nonatomic, assign) bool viewLoaded;

@end

@implementation EQOrdersViewController

-(void)viewDidLoad{
    self.viewModel = [EQOrdersViewModel new];
    self.viewModel.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"EQOrderCell" bundle: nil];
    [self.ordersTable registerNib:nib forCellReuseIdentifier:@"OrderCell"];
    
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.viewModel.clientName) {
        [self.clientFilterButton setTitle:self.viewModel.clientName forState:UIControlStateNormal];
    }
    if (!self.viewLoaded) {
        [self.viewModel loadData];
    }
    
    self.viewLoaded = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.viewLoaded = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.ordersTable = nil;
}

- (IBAction)newOrderButtonAction:(id)sender {
    if ([self.viewModel canCreateOrder]) {
        [self.navigationController pushViewController:[EQNewOrderViewController new] animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Para crear un pedido debe tener un cliente seleccionado y este debe tener una lista de precios." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)clientFilterAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.clientsList delegate:self];
    [self presentPopoverInView:sender withContent:popover];
}

- (IBAction)syncFilterAction:(id)sender {
    EQDateFilterPopover *dateFilter = [[EQDateFilterPopover alloc] initWithStartDate:self.viewModel.startSyncDate endDate:self.viewModel.endSyncDate delegate:self];
    [self presentPopoverInView:sender withContent:dateFilter];
}

- (IBAction)billingFilterAction:(id)sender {
    EQDateFilterPopover *dateFilter = [[EQDateFilterPopover alloc] initWithStartDate:self.viewModel.startBillingDate endDate:self.viewModel.endBillingDate delegate:self];
    [self presentPopoverInView:sender withContent:dateFilter];
}

- (IBAction)statusFilterAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.statusList delegate:self];
    [self presentPopoverInView:sender withContent:popover];
}

- (IBAction)orderButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.sortFields delegate:self];
    [self presentPopoverInView:sender withContent:popover];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel.orders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EQOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell loadOrder:[self.viewModel.orders objectAtIndex:indexPath.row]];
    float red = 210.f / 255.f;
    float green = 210.f / 255.f;
    float blue = 210.f / 255.f;
    cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? [UIColor colorWithRed:red green:green blue:blue alpha:1] : [UIColor whiteColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    EQOrderCell *cell = (EQOrderCell *)[tableView cellForRowAtIndexPath:indexPath];
    EQNewOrderViewController *newOrderController = [[EQNewOrderViewController alloc] initWithOrder:cell.pedido];
    [newOrderController disableInteraction];
    [self.navigationController pushViewController:newOrderController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)editOrder:(Pedido *)order{
    EQNewOrderViewController *newOrderController = [[EQNewOrderViewController alloc] initWithOrder:order];
    [self.navigationController pushViewController:newOrderController animated:YES];
}

- (void)copyOrder:(Pedido *)order{
    if ([order.clienteID intValue] > 0) {
        EQNewOrderViewController *newOrderController = [[EQNewOrderViewController alloc] initWithClonedOrder:[order copy]];
        [self.navigationController pushViewController:newOrderController animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Para crear un pedido debe tener un cliente seleccionado." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)cancelOrder:(Pedido *)pedido{
    [self.viewModel cancelOrder:pedido];
}

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if ([self.popoverOwner isEqual:self.clientFilterButton]) {
        [self.viewModel defineClient:selectedData];
        [self.popoverOwner setTitle:[NSString stringWithFormat:@"  %@",selectedData] forState:UIControlStateNormal];
        [self closePopover];
    } else if ([self.popoverOwner isEqual:self.statusFilterButton]) {
        [self.viewModel defineStatus:selectedData];
        [self.popoverOwner setTitle:[NSString stringWithFormat:@"  %@",selectedData] forState:UIControlStateNormal];
        [self closePopover];
    } else if ([self.popoverOwner isEqual:self.orderFilterButton]) {
        [self.viewModel changeSortOrder:rowNumber];
        [self.popoverOwner setTitle:[NSString stringWithFormat:@"  %@",selectedData] forState:UIControlStateNormal];
        [self closePopover];
    }
    
    [super tablePopover:sender selectedRow:rowNumber selectedData:selectedData];
}

- (void)dateFilter:(EQDateFilterPopover *)sender didSelectStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if ([self.popoverOwner isEqual:self.syncFilterButton]) {
        self.viewModel.startSyncDate = startDate;
        self.viewModel.endSyncDate = endDate;
    } else if([self.popoverOwner isEqual:self.billingFilterButton]){
        self.viewModel.startBillingDate = startDate;
        self.viewModel.endBillingDate = endDate;
    }
    
    if (startDate == nil && endDate == nil) {
        [self.popoverOwner setTitle:@"  Todas" forState:UIControlStateNormal];
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd.MM.yyyy"];
        NSString *title = [NSString stringWithFormat:@" %@ a %@",[dateFormat stringFromDate:startDate],[dateFormat stringFromDate:endDate]];
        [self.popoverOwner setTitle:title forState:UIControlStateNormal];
    }
    
    [self.viewModel loadData];
    [self closePopover];
}

- (void)modelDidUpdateData{
    [self.ordersTable reloadData];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"%.2f",[self.viewModel total]];
    NSString *clientName = @"  Todos";
    if (self.viewModel.clientName) {
        clientName = [@"  " stringByAppendingString:self.viewModel.clientName];
        self.totalPriceLabel.hidden = NO;
        self.totalMessageLabel.hidden = NO;
        self.totalPriceLabel.text =  [NSString stringWithFormat:@"%.2f",[self.viewModel total]];
    } else {
        self.totalPriceLabel.hidden = YES;
        self.totalMessageLabel.hidden = YES;
    }
    
    [self.clientFilterButton setTitle:clientName forState:UIControlStateNormal];
    [super modelDidUpdateData];
}

- (void)changeStatusFilter:(NSString *)status{
    [self.statusFilterButton setTitle:[@"  " stringByAppendingString:status] forState:UIControlStateNormal];
    [self.viewModel defineStatus:status];
    self.viewLoaded = YES;
}

@end
