//
//  EQCreateClientViewModel.h
//  EQ
//
//  Created by Sebastian Borda on 5/8/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQCreateClientViewModel.h"
 
#import "EQDataManager.h"
#import "Provincia.h"
#import "ZonaEnvio.h"
#import "Expreso.h"
#import "Vendedor.h"
#import "Vendedor.h"
#import "Provincia.h"
#import "LineaVTA.h"
#import "TipoIvas.h"
#import "CondPag.h"
#import "NSString+Number.h"
#import "EQSession.h"
#import "Usuario.h"
#import "Cliente+extra.h"
@interface EQCreateClientViewModel()

@property(nonatomic,assign) int selectedTaxAtIndex;
@property(nonatomic,assign) int selectedProvinceAtIndex;
@property(nonatomic,assign) int selectedPaymentConditionAtIndex;
@property(nonatomic,assign) int selectedCollectorAtIndex;
@property(nonatomic,assign) int selectedSellerAtIndex;
@property(nonatomic,assign) int selectedSalesLineAtIndex;
@property(nonatomic,assign) int selectedDeliveryAreaAtIndex;
@property(nonatomic,assign) int selectedExpressAtIndex;

@end

@implementation EQCreateClientViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedTaxAtIndex = -1;
        self.selectedProvinceAtIndex = -1;
        self.selectedPaymentConditionAtIndex = -1;
        self.selectedCollectorAtIndex = -1;
        self.selectedSellerAtIndex = -1;
        self.selectedSalesLineAtIndex = -1;
        self.selectedDeliveryAreaAtIndex = -1;
        self.selectedExpressAtIndex = -1;
    }
    return self;
}

- (void)loadData{
    if (self.clientID) {
        self.client = [Cliente findWithIdentifier:self.clientID];
    }
    
}

- (void)saveClient:(NSDictionary *)clientDictionary{
    if (!self.client) {
        self.client = [Cliente MR_createEntity];
    }
    
    self.client.codigoPostal = clientDictionary[@"zipcode"];
    self.client.cuit = clientDictionary[@"cuit"];
    self.client.descuento1 = [clientDictionary[@"discount1"] number];
    self.client.descuento2 = [clientDictionary[@"discount2"] number];
    self.client.descuento3 = [clientDictionary[@"discount3"] number];
    self.client.descuento4 = [clientDictionary[@"discount4"] number];
    self.client.diasDePago = clientDictionary[@"collectionDays"];
    self.client.domicilio = clientDictionary[@"address"];
    self.client.domicilioDeEnvio = clientDictionary[@"deliveryAddress"];
    self.client.encCompras = clientDictionary[@"purchaseManager"];
    self.client.horario = clientDictionary[@"schedule"];
    self.client.latitud = [[EQSession sharedInstance] currentLatitude];
    self.client.localidad = clientDictionary[@"locality"];
    self.client.longitud = [[EQSession sharedInstance] currentLongitude];
    self.client.mail = clientDictionary[@"email"];
    self.client.nombre = clientDictionary[@"name"];
    self.client.nombreDeFantasia = clientDictionary[@"alias"];
    self.client.observaciones = clientDictionary[@"observations"];
    self.client.propietario = clientDictionary[@"owner"];
    self.client.telefono = clientDictionary[@"phone"];
    self.client.web = clientDictionary[@"web"];
    self.client.activo = [NSNumber numberWithBool:YES];
    if (self.selectedCollectorAtIndex >= 0 )
        self.client.cobradorID = ((Vendedor *)[self obtainCollectorList][self.selectedCollectorAtIndex]).identifier;
    if (self.selectedPaymentConditionAtIndex >= 0 )
        self.client.condicionDePagoID = ((CondPag *)[self obtainPaymentConditionList][self.selectedPaymentConditionAtIndex]).identifier;
    if (self.selectedExpressAtIndex >= 0 )
        self.client.expresoID = ((Expreso *)[self obtainExpressList][self.selectedExpressAtIndex]).identifier;
    if (self.selectedTaxAtIndex >= 0 )
        self.client.ivaID = ((TipoIvas *)[self obtainTaxesList][self.selectedTaxAtIndex]).identifier;
    if (self.selectedSalesLineAtIndex >= 0 )
        self.client.lineaDeVentaID = ((LineaVTA *)[self obtainSalesLineList][self.selectedSalesLineAtIndex]).identifier;
    if (self.selectedSellerAtIndex >= 0 )
        self.client.vendedorID = ((Vendedor *)[self obtainSellersList][self.selectedSellerAtIndex]).identifier;
    else
        self.client.vendedorID = [EQSession sharedInstance].user.vendedorID;
    if (self.selectedProvinceAtIndex >= 0 )
        self.client.provinciaID = ((Provincia *)[self obtainProvinces][self.selectedProvinceAtIndex]).identifier;
    if (self.selectedDeliveryAreaAtIndex >= 0 )
        self.client.zonaEnvioID = ((ZonaEnvio *)[self obtainDeliveryAreaList][self.selectedDeliveryAreaAtIndex]).identifier;
    
    [[EQDataManager sharedInstance] sendClient:self.client];
    [EQSession sharedInstance].selectedClient = self.client;
}

- (NSArray *)obtainProvinces{
    return [Provincia MR_findAll];
}

- (NSArray *)obtainDeliveryAreaList{
    return [ZonaEnvio MR_findAll];
}

- (NSArray *)obtainExpressList{
    return [Expreso MR_findAll];
}

- (NSArray *)obtainSellersList{
    return [Vendedor MR_findAll];
}

- (NSArray *)obtainCollectorList{
    return [self obtainSellersList];
}

- (NSArray *)obtainSalesLineList{
    return [LineaVTA MR_findAll];
}

- (NSArray *)obtainPaymentConditionList{
    return [CondPag MR_findAll];
}

- (NSArray *)obtainTaxesList{
    return [TipoIvas MR_findAll];
}


- (void)selectedTaxAtIndex:(int)index{
    self.selectedTaxAtIndex = index;
}

- (void)selectedProvinceAtIndex:(int)index{
    self.selectedProvinceAtIndex = index;
}

- (void)selectedPaymentConditionAtIndex:(int)index{
    self.selectedPaymentConditionAtIndex = index;
}

- (void)selectedCollectorAtIndex:(int)index{
    self.selectedCollectorAtIndex = index;
}

- (void)selectedSellerAtIndex:(int)index{
    self.selectedSellerAtIndex = index;
}

- (void)selectedSalesLineAtIndex:(int)index{
    self.selectedSalesLineAtIndex = index;
}

- (void)selectedDeliveryAreaAtIndex:(int)index{
    self.selectedDeliveryAreaAtIndex = index;
}

- (void)selectedExpressAtIndex:(int)index{
    self.selectedExpressAtIndex = index;
}

- (NSString *)obtainSelectedSeller{
    return [self.client.vendedor.descripcion length] > 0 ? self.client.vendedor.descripcion : [self sellerName];
}

- (NSString *)obtainSelectedCollector{
    return [self.client.cobrador.descripcion length] > 0 ? self.client.cobrador.descripcion : @"Seleccione un cobrador";
}

- (NSString *)obtainSelectedProvince{
    return [self.client.provincia.descripcion length] > 0 ? self.client.provincia.descripcion : @"Seleccione una zona";
}

- (NSString *)obtainSelectedDeliveryArea{
    return [self.client.zonaEnvio.descripcion length] > 0 ? self.client.zonaEnvio.descripcion : @"Seleccione una zona de envio";
}

- (NSString *)obtainSelectedPaymentCondition{
    return [self.client.condicionDePago.descripcion length] > 0 ? self.client.condicionDePago.descripcion : @"seleccione una condición de pago";
}

- (NSString *)obtainSelectedExpress{
    return [self.client.expreso.descripcion length] > 0 ? self.client.expreso.descripcion : @"Seleccione un expreso";
}

- (NSString *)obtainSelectedTaxes{
    return [self.client.iva.descripcion length] > 0 ? self.client.iva.descripcion : @"Seleccione un tipo de IVA";
}

- (NSString *)obtainSelectedSalesLine{
    return [self.client.lineaDeVenta.descripcion length] > 0 ? self.client.lineaDeVenta.descripcion : @"Seleccione una línea de venta";
}

@end