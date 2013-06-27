//
//  EQSalesViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQSalesViewController.h"
#import "EQSalesViewModel.h"
#import "EQSalesCell.h"
#import "Venta.h"
#import "Articulo.h"
#import "EQSalesFooter.h"

#define cellIdentifier @"SalesCell"

@interface EQSalesViewController ()

@property (nonatomic, strong) EQSalesViewModel *viewModel;
@property (nonatomic, assign) BOOL hideDetails;

@end

@implementation EQSalesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel = [EQSalesViewModel new];
    self.viewModel.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"EQSalesCell" bundle: nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.viewModel initializeData];
    [self.viewModel loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)periodFilterButtonAction:(id)sender {
    EQCustomDateFilterPopover *dateFilter = [[EQCustomDateFilterPopover alloc] initWithStartDate:self.viewModel.periodStart endDate:self.viewModel.periodEnd delegate:self];
    [self presentPopoverInView:sender withContent:dateFilter];
}

- (IBAction)clientFilterButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel clients] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)groupFilterButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel groupsName] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)modeButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel totals] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)sortButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.sortFields delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        return 1;
    }
    
    return [[self.viewModel salesList] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        return [self.viewModel.salesList count];
    }
    
    return [[self.viewModel.salesList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EQSalesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        NSArray *sales = [self.viewModel.salesList objectAtIndex:indexPath.row];
        float gross = 0;
        int quantity = 0;
        for (Venta *sale in sales) {
            gross += [sale.importe floatValue];
            quantity += [sale.cantidad integerValue];
        }
        Venta *sale = [sales lastObject];
        cell.clientLabel.text = sale.cliente.nombre;
        cell.periodLabel.text = @"";
        cell.articleLabel.text = @"";
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", gross];
        cell.quantityLabel.text = [NSString stringWithFormat:@"%i", quantity];
    } else {
        Venta *sale = [[self.viewModel.salesList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.clientLabel.text = sale.cliente.nombre;
        cell.articleLabel.text = sale.articulo.nombre;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy.MM"];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
        cell.periodLabel.text = [dateFormatter stringFromDate:sale.fecha];
        cell.quantityLabel.text = [sale.cantidad stringValue];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%.2f", sale.importe ? [sale.importe floatValue] : 0];
    }

    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ((self.viewModel.onlySubTotalAvailable && self.hideDetails) || ![self.viewModel isSortingByClient]) {
        return 0;
    }
    
    return 50;
}

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if ([self.popoverOwner isEqual:self.sortButton]) {
        [self.viewModel changeSortOrder:rowNumber];
        [self closePopover];
    } else if ([self.popoverOwner isEqual:self.clientFilterButton]) {
        [self.viewModel filterByClient:selectedData];
        [self closePopover];
    } else if ([self.popoverOwner isEqual:self.groupFilterButton]) {
        [self.viewModel filterByGroup:selectedData];
        [self closePopover];
    } else if ([self.popoverOwner isEqual:self.modeButton]) {
        self.hideDetails = [selectedData isEqualToString:@"Subtotal"];
        [self closePopover];
        [self.tableView reloadData];
    }
    
    NSString *buttonText = [NSString stringWithFormat:@"  %@", selectedData];
    [self.popoverOwner setTitle:buttonText forState:UIControlStateNormal];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ((self.viewModel.onlySubTotalAvailable && self.hideDetails) || ![self.viewModel isSortingByClient]) {
        return nil;
    }
    
    NSArray *sales = [self.viewModel.salesList objectAtIndex:section];
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"EQSalesFooter" owner:nil options:nil];
    EQSalesFooter *footer = (EQSalesFooter *)[nibObjects objectAtIndex:0];
    Venta *sale = [sales lastObject];
    footer.groupedFieldLabel.text = sale.cliente.nombre;
    float gross = 0;
    int quantity = 0;
    for (Venta *sale in sales) {
        gross += [sale.importe integerValue];
        quantity += [sale.cantidad integerValue];
    }
    footer.priceLabel.text = [NSString stringWithFormat:@"$%.2f",gross];
    footer.quantityLabel.text = [NSString stringWithFormat:@"%i",quantity];
    
    return footer;
}

-(void)modelDidUpdateData{
    [super modelDidUpdateData];
    [self.tableView reloadData];
    self.modeButton.enabled = self.viewModel.onlySubTotalAvailable;
}

- (void)dateFilter:(EQDateFilterPopover *)sender didSelectStartDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    if ([self.popoverOwner isEqual:self.periodFilterButton]) {
        self.viewModel.periodStart = startDate;
        self.viewModel.periodEnd = endDate;
    }
    
    if (startDate == nil && endDate == nil) {
        [self.popoverOwner setTitle:@"  Todas" forState:UIControlStateNormal];
    } else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM.yyyy"];
        NSString *title = [NSString stringWithFormat:@" %@ a %@",[dateFormat stringFromDate:startDate],[dateFormat stringFromDate:endDate]];
        [self.popoverOwner setTitle:title forState:UIControlStateNormal];
    }
    
    [self.viewModel loadData];
    [self closePopover];
}

@end
