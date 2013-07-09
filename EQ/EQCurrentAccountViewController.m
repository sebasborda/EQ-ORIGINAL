//
//  EQCurrentAccountViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCurrentAccountViewController.h"
#import "EQCurrentAccountCell.h"
#import "CtaCte.h"
#import "Cliente.h"
#import "EQCurrentAccountFooter.h"
#define cellIdentifier @"CurrentAccountCell"

@interface EQCurrentAccountViewController ()

@property (nonatomic, strong) EQCurrentAccountViewModel *viewModel;
@property (nonatomic, assign) BOOL hideDetails;

@end

@implementation EQCurrentAccountViewController

- (void)viewDidLoad{
    self.viewModel = [EQCurrentAccountViewModel new];
    self.viewModel.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"EQCurrentAccountCell" bundle: nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSDictionary *resume = [self.viewModel resume];
    self.thirtyDaysLabel.text = [NSString stringWithFormat:@"$%@",[resume objectForKey:@"30"]];
    self.fortyFiveDaysLabel.text = [NSString stringWithFormat:@"$%@",[resume objectForKey:@"45"]];
    self.ninetyDaysLabel.text = [NSString stringWithFormat:@"$%@",[resume objectForKey:@"90"]];
    self.moreThan90DaysLabel.text = [NSString stringWithFormat:@"$%@",[resume objectForKey:@"+90"]];
    self.totalLabel.text = [NSString stringWithFormat:@"%.2f",[[resume objectForKey:@"total"] floatValue]];
    
    if (self.viewModel.clientName) {
        [self.clientButton setTitle:self.viewModel.clientName forState:UIControlStateNormal];
    }
    
    [self.viewModel loadData];
}

-(void)modelDidUpdateData{
    [super modelDidUpdateData];
    [self.tableView reloadData];
    self.totalButton.enabled = self.viewModel.onlySubTotalAvailable;
    NSString *clientName = @"  Todos";
    if (self.viewModel.clientName) {
        clientName = [@"  " stringByAppendingString:self.viewModel.clientName];
    }
    
    [self.clientButton setTitle:clientName forState:UIControlStateNormal];
}

- (IBAction)companyButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel companies] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)sortButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:self.viewModel.sortFields delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)clientButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel clients] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)localityButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel localities] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        return 1;
    }
    
    return [[self.viewModel currentAccountList] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        return [self.viewModel.currentAccountList count];
    }

    return [[self.viewModel.currentAccountList objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EQCurrentAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (self.viewModel.onlySubTotalAvailable && self.hideDetails) {
        NSArray *accounts = [self.viewModel.currentAccountList objectAtIndex:indexPath.row];
        int gross = 0;
        int net = 0;
        int percept = 0;
        for (CtaCte *account in accounts) {
            gross += [account.importe integerValue];
            net += [account.importeConDescuento integerValue];
            percept += [account.importePercepcion integerValue];
        }
        CtaCte *ctacte = [accounts lastObject];
        cell.clientLabel.text = ctacte.cliente.nombre;
        cell.dateLabel.text = @"";
        cell.delayLabel.text = @"";
        cell.voucherLabel.text = @"";
        cell.conditionLabel.text = @"";
        cell.persepLabel.text = [NSString stringWithFormat:@"$%i", percept];
        cell.amountLabel.text = [NSString stringWithFormat:@"$%i", gross];
        cell.discountLabel.text = [NSString stringWithFormat:@"$%i", net];
    } else {
        CtaCte *ctaCte = [[self.viewModel.currentAccountList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.clientLabel.text = ctaCte.cliente.nombre;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        cell.dateLabel.text = [dateFormatter stringFromDate:ctaCte.fecha];
        cell.delayLabel.text = ctaCte.diasDeAtraso;
        cell.voucherLabel.text = ctaCte.comprobante;
        cell.conditionLabel.text = ctaCte.condicionDeVenta;
        cell.persepLabel.text = [NSString stringWithFormat:@"$%i", ctaCte.importePercepcion ? [ctaCte.importePercepcion integerValue] : 0];
        cell.amountLabel.text = [NSString stringWithFormat:@"$%i", ctaCte.importe ? [ctaCte.importe integerValue] : 0];
        cell.discountLabel.text = [NSString stringWithFormat:@"$%i", ctaCte.importeConDescuento ? [ctaCte.importeConDescuento integerValue] : 0];
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ((self.viewModel.onlySubTotalAvailable && self.hideDetails) || ![self.viewModel isSortingByClient]) {
        return nil;
    }
    
    NSArray *accounts = [self.viewModel.currentAccountList objectAtIndex:section];
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"EQCurrentAccountFooter" owner:nil options:nil];
    EQCurrentAccountFooter *footer = (EQCurrentAccountFooter *)[nibObjects objectAtIndex:0];
    CtaCte *ctacte = [accounts lastObject];
    footer.clientLabel.text = ctacte.cliente.nombre;
    int gross = 0;
    int net = 0;
    int percept = 0;
    for (CtaCte *account in accounts) {
        gross += [account.importe integerValue];
        net += [account.importeConDescuento integerValue];
        percept += [account.importePercepcion integerValue];
    }
    footer.grossLabel.text = [NSString stringWithFormat:@"$%i",gross];
    footer.netLabel.text = [NSString stringWithFormat:@"$%i",net];
    footer.perceptionLabel.text = [NSString stringWithFormat:@"$%i",percept];
    
    return footer;
}

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if ([self.popoverOwner isEqual:self.sortButton]) {
        [self.viewModel changeSortOrder:rowNumber];
    } else if ([self.popoverOwner isEqual:self.clientButton]) {
        [self.viewModel filterByClient:selectedData];
    } else if ([self.popoverOwner isEqual:self.localityButton]) {
        [self.viewModel filterBylocality:selectedData];
    } else if ([self.popoverOwner isEqual:self.companyButton]) {
        [self.viewModel filterByCompany:selectedData];
    } else if ([self.popoverOwner isEqual:self.totalButton]) {
        self.hideDetails = [selectedData isEqualToString:@"Subtotal"];
        [self.tableView reloadData];
    }
    
    NSString *buttonText = [NSString stringWithFormat:@"  %@", selectedData];
    [self.popoverOwner setTitle:buttonText forState:UIControlStateNormal];
    [self closePopover];
    [super tablePopover:sender selectedRow:rowNumber selectedData:selectedData];
}

- (IBAction)totalButtonAction:(id)sender {
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self.viewModel totals] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)emailButtonAction:(id)sender {
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
    compose.mailComposeDelegate = self;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    [compose setSubject:[NSString stringWithFormat:@"Listado Cuenta Corriente %@",[dateFormat stringFromDate:[NSDate date]]]];
    UIImage* image = [self captureView:self.tableView];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    [compose addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"CuentaCorriente.jpg"]];
    [self presentViewController:compose animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
