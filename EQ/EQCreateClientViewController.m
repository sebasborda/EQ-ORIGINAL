//
//  EQCreateClientViewController.m
//  EQ
//
//  Created by Sebastian Borda on 5/8/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCreateClientViewController.h"
#import "NSMutableDictionary+EQ.h"
#import "Provincia.h"
#import "ZonaEnvio.h"
#import "Expreso.h"
#import "Vendedor.h"
#import "Vendedor.h"
#import "Provincia.h"
#import "LineaVTA.h"
#import "TipoIvas.h"
#import "CondPag.h"
#import "EQSession.h"

@interface EQCreateClientViewController ()

@property (nonatomic,strong) NSMutableString *ErrorMessage;
@property (nonatomic,strong) EQCreateClientViewModel *viewModel;

@end

@implementation EQCreateClientViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.viewModel = [EQCreateClientViewModel new];
        self.viewModel.delegate = self;
        [self.viewModel loadData];
    }
    return self;
}

- (id)initWithClientId:(NSNumber *)clientId
{
    self = [super init];
    if (self) {
        self.viewModel = [EQCreateClientViewModel new];
        self.viewModel.delegate = self;
        self.viewModel.clientID = clientId;
        [self.viewModel loadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Cliente *client = self.viewModel.client;
    if (client) {
        self.clientNameTextField.text = client.nombre;
        self.clientAliasTextField.text = client.nombreDeFantasia;
        self.clientPhoneTextField.text = client.telefono;
        self.clientWebTextField.text = client.web;
        self.clientZipCodeTextField.text = client.codigoPostal;
        self.CUITTextField.text = client.cuit;
        self.clientEmailTextField.text = client.mail;
        self.clientAddressTextField.text = client.domicilio;
        self.deliveryAddressTextField.text = client.domicilioDeEnvio;
        self.clientLocalityTextField.text = client.localidad;
        self.ownerNameTextField.text = client.propietario;
        self.purchaseManagerTextField.text = client.encCompras;
        self.branchTextField.text = [client.sucursal stringValue];
        self.scheduleTextField.text = client.horario;
        self.code1TextField.text = client.codigo1;
        self.code2TextField.text = client.codigo2;
        self.collectionDaysTextField.text = client.diasDePago;
        self.discount1TextField.text = [client.descuento1 stringValue];
        self.discount2TextField.text = [client.descuento2 stringValue];
        self.discount3TextField.text = [client.descuento3 stringValue];
        self.discount4TextField.text = [client.descuento4 stringValue];
        self.observationsTextField.text = client.observaciones;
    }
    
    [self.provinceButton setTitle:[self.viewModel obtainSelectedProvince] forState:UIControlStateNormal];
    [self.paymentConditionButton setTitle:[self.viewModel obtainSelectedPaymentCondition] forState:UIControlStateNormal];
    [self.sellerButton setTitle:[self.viewModel obtainSelectedSeller] forState:UIControlStateNormal];
    [self.collectorButton setTitle:[self.viewModel obtainSelectedCollector] forState:UIControlStateNormal];
    [self.expressButton setTitle:[self.viewModel obtainSelectedExpress] forState:UIControlStateNormal];
    [self.taxesButton setTitle:[self.viewModel obtainSelectedTaxes] forState:UIControlStateNormal];
    [self.salesLineButton setTitle:[self.viewModel obtainSelectedSalesLine] forState:UIControlStateNormal];
    [self.deliveryAreaButton setTitle:[self.viewModel obtainSelectedDeliveryArea] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[EQSession sharedInstance] startMonitoring];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[EQSession sharedInstance] stopMonitoring];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addMessageError:(NSMutableString *)messageError {
    if ([self.ErrorMessage length] > 0) {
        [self.ErrorMessage appendString:@"\n"];
        [self.ErrorMessage appendString:messageError];
    } else{
        self.ErrorMessage = messageError;
    }
}

- (NSString *)validateNonEmptyTextField:(UITextField *)textField withName:(NSString *)name{
    if ([textField.text length] == 0) {
        [self addMessageError:[NSMutableString stringWithFormat:@"%@ no puede estar vacio.", name]];
        return @"";
    }
    
    return textField.text;
}

-(BOOL) validEmail:(NSString*) emailString {
    if ([emailString length] > 0) {
        NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
        NSLog(@"%i", regExMatches);
        if (regExMatches == 0) {
            [self addMessageError:[NSMutableString stringWithString:@"Email invalido"]];
            return NO;
        }
    }

    return YES;
}

- (NSArray *)descriptions:(NSArray *)values{
    NSMutableArray *descriptions = [NSMutableArray new];
    for (id value in values) {
        [descriptions addObject:[value performSelector:@selector(descripcion)]];
    }
    
    return descriptions;
}

- (IBAction)deliveryAreaButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainDeliveryAreaList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)provinceButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainProvinces]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)expressButonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainExpressList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)sellerButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainSellersList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)collectorButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainCollectorList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)salesLineButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainSalesLineList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)paymentConditionButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainPaymentConditionList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)taxesButtonAction:(id)sender {
    [self.textFieldList makeObjectsPerformSelector:@selector(resignFirstResponder)];
    EQTablePopover *popover = [[EQTablePopover alloc] initWithData:[self descriptions:[self.viewModel obtainTaxesList]] delegate:self];
    UIButton *button = (UIButton *)sender;
    [self presentPopoverInView:button withContent:popover];
}

- (IBAction)saveButtonAction:(id)sender {
    NSMutableDictionary *clientDictionary = [NSMutableDictionary new];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.clientNameTextField withName:@"Nombre"] forKey:@"name"];
    [clientDictionary setNotEmptyString:self.clientAliasTextField.text forKey:@"alias"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.clientAddressTextField withName:@"Domicilio"] forKey:@"address"];
    [clientDictionary setNotEmptyString:self.clientZipCodeTextField.text forKey:@"zipcode"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.clientLocalityTextField withName:@"Localidad"] forKey:@"locality"];
    if ([self validEmail:self.clientEmailTextField.text]) {
        [clientDictionary setNotEmptyString:self.clientEmailTextField.text forKey:@"email"];
    }
    
    [clientDictionary setNotEmptyString:self.ownerNameTextField.text forKey:@"owner"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.clientPhoneTextField withName:@"Telefono"] forKey:@"phone"];
    [clientDictionary setNotEmptyString:self.clientWebTextField.text forKey:@"web"];
    [clientDictionary setNotEmptyString:self.purchaseManagerTextField.text forKey:@"purchaseManager"];
    
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.deliveryAddressTextField withName:@"Domicilio de entrega"] forKey:@"deliveryAddress"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.branchTextField withName:@"Sucursal"] forKey:@"branch"];
    [clientDictionary setNotEmptyString:self.scheduleTextField.text forKey:@"schedule"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.CUITTextField withName:@"CUIT"] forKey:@"cuit"];
    [clientDictionary setNotEmptyString:[self validateNonEmptyTextField:self.code1TextField withName:@"Codigo 1"] forKey:@"code1"];
    [clientDictionary setNotEmptyString:self.code2TextField.text forKey:@"code2"];
    [clientDictionary setNotEmptyString:self.collectionDaysTextField.text forKey:@"collectionDays"];
    [clientDictionary setNotEmptyString:self.discount1TextField.text forKey:@"discount1"];
    [clientDictionary setNotEmptyString:self.discount2TextField.text forKey:@"discount2"];
    [clientDictionary setNotEmptyString:self.discount3TextField.text forKey:@"discount3"];
    [clientDictionary setNotEmptyString:self.discount4TextField.text forKey:@"discount4"];
    [clientDictionary setNotEmptyString:self.observationsTextField.text forKey:@"observations"];
    [clientDictionary setNotNilObject:[[EQSession sharedInstance] currentLatitude] forKey:@"latitude"];
    [clientDictionary setNotNilObject:[[EQSession sharedInstance] currentLongitude] forKey:@"longitude"];
    
    if ([self.ErrorMessage length] == 0) {
        [self.viewModel saveClient:clientDictionary];
        [self.delegate clientSaved];
    } else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Solucione los siguientes errores"
                                                        message:self.ErrorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)cancelButtonAction:(id)sender {
    [self.delegate createClientCancelled];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.ErrorMessage = nil;
}

- (void)tablePopover:(EQTablePopover *)sender selectedRow:(int)rowNumber selectedData:(NSString *)selectedData{
    if (selectedData) {
        if ([self isButtonPopoverOwner:self.provinceButton]) {
            [self.viewModel selectedProvinceAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.deliveryAreaButton]) {
            [self.viewModel selectedDeliveryAreaAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.expressButton]) {
            [self.viewModel selectedExpressAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.sellerButton]) {
            [self.viewModel selectedSellerAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.collectorButton]) {
            [self.viewModel selectedCollectorAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.salesLineButton]) {
            [self.viewModel selectedSalesLineAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.paymentConditionButton]) {
            [self.viewModel selectedPaymentConditionAtIndex:rowNumber];
        } else if ([self isButtonPopoverOwner:self.taxesButton]) {
            [self.viewModel selectedTaxAtIndex:rowNumber];
        }
        
        [self.popoverOwner setTitle:selectedData forState:UIControlStateNormal];
    }

    [self closePopover];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

@end
