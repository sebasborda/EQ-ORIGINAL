//
//  EQCurrentAccountViewController.m
//  EQ
//
//  Created by Sebastian Borda on 4/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCurrentAccountViewController.h"
#import "EQCurrentAccountCell.h"
#import "CtaCte+extra.h"
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
    self.thirtyDaysLabel.text = [NSString stringWithFormat:@"$%i",[[resume objectForKey:@"30"] integerValue]];
    self.fortyFiveDaysLabel.text = [NSString stringWithFormat:@"$%i",[[resume objectForKey:@"45"] integerValue]];
    self.ninetyDaysLabel.text = [NSString stringWithFormat:@"$%i",[[resume objectForKey:@"90"] integerValue]];
    self.moreThan90DaysLabel.text = [NSString stringWithFormat:@"$%i",[[resume objectForKey:@"+90"] integerValue]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.tableView = nil;
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
        float gross = 0;
        float net = 0;
        float percept = 0;
        for (CtaCte *account in accounts) {
            gross += [account.importe floatValue];
            net += [account.importeConDescuento floatValue];
            percept += [account.importePercepcion floatValue];
        }
        CtaCte *ctacte = [accounts lastObject];
        cell.clientLabel.text = ctacte.cliente.nombre;
        cell.dateLabel.text = @"";
        cell.delayLabel.text = @"";
        cell.voucherLabel.text = @"";
        cell.conditionLabel.text = @"";
        cell.persepLabel.text = [NSString stringWithFormat:@"$%.0f", percept];
        cell.amountLabel.text = [NSString stringWithFormat:@"$%.0f", gross];
        cell.discountLabel.text = [NSString stringWithFormat:@"$%.0f", net];
    } else {
        CtaCte *ctaCte = [[self.viewModel.currentAccountList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.clientLabel.text = ctaCte.cliente.nombre;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        cell.dateLabel.text = [dateFormatter stringFromDate:ctaCte.fecha];
        cell.delayLabel.text = [NSString stringWithFormat:@"%i",ctaCte.diasDeAtraso];
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
    float gross = 0;
    float net = 0;
    float percept = 0;
    for (CtaCte *account in accounts) {
        gross += [account.importe floatValue];
        net += [account.importeConDescuento floatValue];
        percept += [account.importePercepcion floatValue];
    }
    footer.grossLabel.text = [NSString stringWithFormat:@"$%.0f",gross];
    footer.netLabel.text = [NSString stringWithFormat:@"$%.0f",net];
    footer.perceptionLabel.text = [NSString stringWithFormat:@"$%.0f",percept];
    
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
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
        compose.mailComposeDelegate = self;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        [compose setSubject:[NSString stringWithFormat:@"Listado Cuenta Corriente %@",[dateFormat stringFromDate:[NSDate date]]]];
        UIImage* image = [self captureView:self.tableView];
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        [compose addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"CuentaCorriente.jpg"]];
        [self presentViewController:compose animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"El mail no puede ser enviado" message:@"Verifique que su iPad tiene una cuenta de mail configurada" delegate:nil cancelButtonTitle:@"Continuar" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
