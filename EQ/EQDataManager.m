//
//  EQDataManager.m
//  EQ
//
//  Created by Sebastian Borda on 4/30/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQDataManager.h"
#import "NSDictionary+EQ.h"
#import "NSMutableDictionary+EQ.h"
#import "NSString+Number.h"
#import "EQSession.h"
#import "EQNetworkManager.h"
#import "EQDataAccessLayer.h"
#import "Articulo.h"
#import "CondPag.h"
#import "Vendedor.h"
#import "Expreso.h"
#import "LineaVTA.h"
#import "Provincia.h"
#import "ZonaEnvio.h"
#import "TipoIvas.h"
#import "Usuario.h"
#import "CtaCte.h"
#import "Precio.h"

@implementation EQDataManager

+ (EQDataManager *)sharedInstance
{
    static EQDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQDataManager alloc] init];
    });
    return sharedInstance;
}

- (void)updateData{
    [self updateShippingArea];
}

- (NSDictionary *)obtainCredentials{
    NSMutableDictionary *credentials = nil;
    Usuario *user = [[EQSession sharedInstance] user];
    if (user) {
        credentials = [NSMutableDictionary dictionary];
        [credentials setNotEmptyStringEscaped:user.nombreDeUsuario forKey:@"usuario"];
        [credentials setObject:user.password forKey:@"password"];
    }
    
    return credentials;
}

- (NSDictionary *)obtainLastUpdate{
    NSMutableDictionary *lastUpdate = nil;
    NSDate *lastSyncDate = [[EQSession sharedInstance] lastSyncDate];
    if (lastSyncDate) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        //TODO: cambiar 2012 por yyyy
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        lastUpdate = [NSMutableDictionary dictionary];
        [lastUpdate setNotEmptyStringEscaped:[dateFormat stringFromDate:lastSyncDate] forKey:@"timestamp"];
    }
    
    return lastUpdate;
}

- (void)updateCost{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"precio_articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary *priceDictionary in jsonArray) {
            Precio *price = (Precio *)[adl objectForClass:[Precio class] withId:[[priceDictionary objectForKey:@"id"] number]];
            price.identifier = [[priceDictionary filterInvalidEntry:@"id"] number];
            price.importe = [[priceDictionary filterInvalidEntry:@"importe"] number];
            price.numero = [priceDictionary filterInvalidEntry:@"numero"];
            price.articulo = (Articulo *)[adl objectForClass:[Articulo class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[priceDictionary filterInvalidEntry:@"articulo_id"] number]]];

            [auxArray addObject:price];
        }
        
        [adl saveContext];
        [self updateUsers];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:success failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateNotifications{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"comunicacion" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        
        //Modify last update date
        [[EQSession sharedInstance] dataUpdated];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:success failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateOrders{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"pedido" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    SuccessRequest success = ^(NSArray *jsonArray){
    
        [self updateCurrentAccount];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:success failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateCurrentAccount{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"cuenta_corriente" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
         NSLog(@"ctacte result: %i", [jsonArray count]);
        for (NSDictionary *ctaCteDictionary in jsonArray) {
            CtaCte *ctaCte = (CtaCte *)[adl objectForClass:[CtaCte class] withId:[[ctaCteDictionary objectForKey:@"id"] number]];
            ctaCte.identifier = [[ctaCteDictionary filterInvalidEntry:@"id"] number];
            ctaCte.importe = [[ctaCteDictionary filterInvalidEntry:@"importe"] number];
            ctaCte.importePercepcion = [[ctaCteDictionary filterInvalidEntry:@"importe_percepcion"] number];
            ctaCte.empresa = [ctaCteDictionary filterInvalidEntry:@"empresa"];
            ctaCte.condicionDeVenta = [ctaCteDictionary filterInvalidEntry:@"condicion_de_venta"];
            ctaCte.comprobante = [ctaCteDictionary filterInvalidEntry:@"comprobante"];
            ctaCte.fecha = [ctaCteDictionary filterInvalidEntry:@"fecha"];
            ctaCte.importeConDescuento = [[ctaCteDictionary filterInvalidEntry:@"importe_con_desc"] number];
            ctaCte.cliente = (Cliente *)[adl objectForClass:[Cliente class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[ctaCteDictionary filterInvalidEntry:@"cliente_id"] number]]];
            ctaCte.vendedor = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[ctaCteDictionary filterInvalidEntry:@"vendedor_id"] number]]];
            [auxArray addObject:ctaCte];
        }
        
        [adl saveContext];
        [self updateNotifications];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:success failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updatePaymentCondition{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"condicion_pago" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* condPagDictionary in jsonArray) {
            CondPag *condPag = (CondPag *)[adl objectForClass:[CondPag class] withId:[condPagDictionary objectForKey:@"id"]];
            condPag.identifier = [[condPagDictionary filterInvalidEntry:@"id"] number];
            condPag.descripcion = [condPagDictionary filterInvalidEntry:@"descripcion"];
            condPag.codigo = [condPagDictionary filterInvalidEntry:@"codigo"];
            condPag.activo = [[condPagDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:condPag];
        }
        
        [adl saveContext];
        [self updateKindTaxes];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:successBlock failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateKindSales{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"linea_venta" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* ventaDictionary in jsonArray) {
            LineaVTA *venta = (LineaVTA *)[adl objectForClass:[LineaVTA class] withId:[ventaDictionary objectForKey:@"id"]];
            venta.identifier = [[ventaDictionary filterInvalidEntry:@"id"] number];
            venta.descripcion = [ventaDictionary filterInvalidEntry:@"descripcion"];
            venta.codigo = [ventaDictionary filterInvalidEntry:@"codigo"];
            venta.activo = [[ventaDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:venta];
        }
        
        [adl saveContext];
        [self updateExpress];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:successBlock failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateSales{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"venta" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    

    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:nil failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateShippingArea{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"zona_envio" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* envioDictionary in jsonArray) {
            ZonaEnvio *envio = (ZonaEnvio *)[adl objectForClass:[ZonaEnvio class] withId:[envioDictionary objectForKey:@"id"]];
            envio.identifier = [[envioDictionary filterInvalidEntry:@"id"] number];
            envio.descripcion = [envioDictionary filterInvalidEntry:@"descripcion"];
            envio.codigo = [envioDictionary filterInvalidEntry:@"codigo"];
            envio.activo = [[envioDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:envio];
        }
        
        [adl saveContext];
        [self updateProvince];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:successBlock failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateClients{
    SuccessRequest block = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
         NSLog(@"cliente result: %i", [jsonArray count]);
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* clienteDictionary in jsonArray) {
            Cliente *client = (Cliente *)[adl objectForClass:[Cliente class] withId:[clienteDictionary objectForKey:@"id"]];
            client.identifier = [[clienteDictionary filterInvalidEntry:@"id"] number];
            client.cobrador = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"cobrador_id"] number]]];
            client.codigoPostal = [clienteDictionary filterInvalidEntry:@"cod_postal"];
            client.codigo1 = [clienteDictionary filterInvalidEntry:@"codigo1"];
            client.codigo2 = [clienteDictionary filterInvalidEntry:@"codigo2"];
            client.condicionDePago = (CondPag *)[adl objectForClass:[CondPag class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"condicion_pago_id"] number]]];
            client.cuit = [clienteDictionary filterInvalidEntry:@"cuit"];
            client.descuento1 = [clienteDictionary filterInvalidEntry:@"descuento1"];
            client.descuento2 = [clienteDictionary filterInvalidEntry:@"descuento2"];
            client.descuento3 = [clienteDictionary filterInvalidEntry:@"descuento3"];
            client.descuento4 = [clienteDictionary filterInvalidEntry:@"descuento4"];
            client.diasDePago = [clienteDictionary filterInvalidEntry:@"dias_de_pago"];
            client.domicilio = [clienteDictionary filterInvalidEntry:@"domicilio"];
            client.domicilioDeEnvio = [clienteDictionary filterInvalidEntry:@"domicilio_envio"];
            client.propietario = [clienteDictionary filterInvalidEntry:@"dueno"];
            client.encCompras = [clienteDictionary filterInvalidEntry:@"enc_compras"];
            client.expreso = (Expreso *)[adl objectForClass:[Expreso class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"expreso_id"] number]]];
            client.horario = [clienteDictionary filterInvalidEntry:@"horario"];
            client.lineaDeVenta = (LineaVTA *)[adl objectForClass:[LineaVTA class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"linea_venta_id"] number]]];
            client.localidad = [clienteDictionary filterInvalidEntry:@"localidad"];
            client.mail = [clienteDictionary filterInvalidEntry:@"mail"];
            client.nombre = [clienteDictionary filterInvalidEntry:@"nombre"];
            client.nombreDeFantasia = [clienteDictionary filterInvalidEntry:@"nombre_fantasia"];
            client.observaciones = [clienteDictionary filterInvalidEntry:@"observaciones"];
            client.zona = (Provincia *)[adl objectForClass:[Provincia class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"provincia_id"] number]]];
            client.sucursal = [[clienteDictionary filterInvalidEntry:@"sucursal"] number];
            client.telefono = [clienteDictionary filterInvalidEntry:@"telefono"];
            client.iva = (TipoIvas *)[adl objectForClass:[TipoIvas class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"tipo_iva_id"] number]]];
            client.latitud = [clienteDictionary filterInvalidEntry:@"ubicacion_gps_lat"];
            client.longitud = [clienteDictionary filterInvalidEntry:@"ubicacion_gps_lng"];
            Vendedor *seller = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"vendedor_id"] number]]];
            client.vendedor = seller;
            client.zonaEnvio = (ZonaEnvio *)[adl objectForClass:[ZonaEnvio class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"zona_envio_id"] number]]];
            client.web = [clienteDictionary filterInvalidEntry:@"web"];
            client.actualizado = [NSNumber numberWithBool:YES];
            client.activo = [[clienteDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:client];
        }
        
        [adl saveContext];
        [self updateCost];
    };

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"cliente" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateProducts{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* articuloDictionary in jsonArray) {
            Articulo *art = (Articulo *)[adl objectForClass:[Articulo class] withId:[articuloDictionary objectForKey:@"id"]];
            art.identifier = [[articuloDictionary filterInvalidEntry:@"id"] number];
            NSMutableString *codigo = [NSMutableString stringWithString:[articuloDictionary filterInvalidEntry:@"codigo1"]];
            [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo2"]];
            [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo3"]];
            art.codigo = codigo;
            art.nombre = [articuloDictionary filterInvalidEntry:@"nombre"];
            art.descripcion = [articuloDictionary filterInvalidEntry:@"descripcion"];
            art.imagenURL = [articuloDictionary filterInvalidEntry:@"foto"];
            art.tipo = [articuloDictionary filterInvalidEntry:@"tipo"];
            art.multiploPedido = [[articuloDictionary filterInvalidEntry:@"multiplo_pedido"] number];
            art.minimoPedido = [[articuloDictionary filterInvalidEntry:@"minimo_pedido"] number];
            art.disponibilidadID = [[articuloDictionary filterInvalidEntry:@"disponibilidad_id"] number];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            art.creado = [dateFormat dateFromString:[articuloDictionary filterInvalidEntry:@"creado"]];
            art.modificado = [dateFormat dateFromString:[articuloDictionary filterInvalidEntry:@"modificado"]];
            
            art.cantidadPredeterminada = [[articuloDictionary filterInvalidEntry:@"cant_predeterm"] number];
            art.activo = [[articuloDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:art];
        }
        
        [adl saveContext];
        [self updateSellers];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateSellers{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* vendedorDictionary in jsonArray) {
            Vendedor *seller = (Vendedor *)[adl objectForClass:[Vendedor class] withId:[vendedorDictionary objectForKey:@"id"]];
            seller.identifier = [[vendedorDictionary filterInvalidEntry:@"id"] number];
            seller.codigo = [vendedorDictionary filterInvalidEntry:@"codigo"];
            seller.descripcion = [vendedorDictionary filterInvalidEntry:@"descripcion"];
            seller.activo = [[vendedorDictionary filterInvalidEntry:@"activo"] number];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.vendedor.identifier = %@", seller.identifier];
            Usuario *user = (Usuario *)[adl objectForClass:[Usuario class] withPredicate:predicate];
            seller.usuario = user;
            [auxArray addObject:seller];
        }
        
        [adl saveContext];
        [self updatePaymentCondition];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"vendedor" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateExpress{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary* expresoDictionary in jsonArray) {
            Expreso *express = (Expreso *)[adl objectForClass:[Expreso class] withId:[expresoDictionary objectForKey:@"id"]];
            express.identifier = [[expresoDictionary filterInvalidEntry:@"id"] number];
            express.codigo = [expresoDictionary filterInvalidEntry:@"codigo"];
            express.descripcion = [expresoDictionary filterInvalidEntry:@"descripcion"];
            express.activo = [[expresoDictionary filterInvalidEntry:@"activo"] number];
            
            [array addObject:express];
        }
        
        [adl saveContext];
        [self updateClients];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"expreso" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateProvince{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *provinces = [NSMutableArray array];
        for (NSDictionary* provinciaDictionary in jsonArray) {
            Provincia *province = (Provincia *)[adl objectForClass:[Provincia class] withId:[provinciaDictionary objectForKey:@"id"]];
            province.identifier = [[provinciaDictionary filterInvalidEntry:@"id"] number];
            province.codigo = [provinciaDictionary filterInvalidEntry:@"codigo"];
            province.descripcion = [provinciaDictionary filterInvalidEntry:@"descripcion"];
            province.activo = [[provinciaDictionary filterInvalidEntry:@"activo"] number];
            
            [provinces addObject:province];
        }
        
        [adl saveContext];
        [self updateProducts];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"provincia" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateKindTaxes{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *tipos = [NSMutableArray array];
        for (NSDictionary* ivaDictionary in jsonArray) {
            TipoIvas *iva = (TipoIvas *)[adl objectForClass:[TipoIvas class] withId:[ivaDictionary objectForKey:@"id"]];
            iva.identifier = [[ivaDictionary filterInvalidEntry:@"id"] number];
            iva.codigo = [ivaDictionary filterInvalidEntry:@"codigo"];
            iva.descripcion = [ivaDictionary filterInvalidEntry:@"descripcion"];
            iva.activo = [[ivaDictionary filterInvalidEntry:@"activo"] number];
            [tipos addObject:iva];
        }
        
        [adl saveContext];
        [self updateKindSales];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"tipo_iva" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)updateUsers{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSMutableArray *users = [NSMutableArray array];
        for (NSDictionary* usuarioDictionary in jsonArray) {
            NSNumber *identifier = [NSNumber numberWithInt:[[usuarioDictionary filterInvalidEntry:@"vendedor_id"] integerValue] + 31];
            NSString *usuario = [usuarioDictionary filterInvalidEntry:@"username"];
            NSString *password = [usuarioDictionary filterInvalidEntry:@"hashed_password"];
            Usuario *user = (Usuario *)[adl objectForClass:[Usuario class] withId:identifier];
            user.identifier = identifier;
            user.nombreDeUsuario = usuario;
            user.password = password;
            user.nombre = [usuarioDictionary filterInvalidEntry:@"display_name"];
            user.vendedor = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[usuarioDictionary filterInvalidEntry:@"vendedor_id"] number]]];
            [users addObject:user];
        }
        
        [adl saveContext];
        [self updateOrders];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"login" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdate]];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)sendClient:(Cliente *)client{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setNotNilObject:@"cliente" forKey:@"object"];
    [dictionary setNotNilObject:[client.identifier intValue] > 0 ? @"modificar":@"crear" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self parseClient:client]];

    __block Cliente *newClient = client;
    SuccessRequest block = ^(NSArray *jsonArray){
        NSDictionary * clientDictionary = [jsonArray lastObject];
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        newClient.identifier = [[clientDictionary filterInvalidEntry:@"obj_id"] number];
        newClient.actualizado = [NSNumber numberWithBool:YES];
        [adl saveContext];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (NSMutableDictionary *)parseClient:(Cliente *)client{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if([client.identifier intValue] > 0) {
        [dictionary setNotNilObject:client.identifier forKey:@"atributos[id]"];
    }
    [dictionary setNotNilObject:client.cobrador.identifier forKey:@"atributos[cobrador_id]"];
    [dictionary setNotEmptyStringEscaped:client.codigoPostal forKey:@"atributos[cod_postal]"];
    [dictionary setNotEmptyStringEscaped:client.codigo1 forKey:@"atributos[codigo1]"];
    [dictionary setNotEmptyStringEscaped:client.codigo2 forKey:@"atributos[codigo2]"];
    [dictionary setNotNilObject:client.condicionDePago.identifier forKey:@"atributos[condicion_pago_id]"];
    [dictionary setNotEmptyStringEscaped:client.cuit forKey:@"atributos[cuit]"];
    [dictionary setNotEmptyStringEscaped:client.descuento1 forKey:@"atributos[descuento1]"];
    [dictionary setNotEmptyStringEscaped:client.descuento2 forKey:@"atributos[descuento2]"];
    [dictionary setNotEmptyStringEscaped:client.descuento3 forKey:@"atributos[descuento3]"];
    [dictionary setNotEmptyStringEscaped:client.descuento4 forKey:@"atributos[descuento4]"];
    [dictionary setNotEmptyStringEscaped:client.diasDePago forKey:@"atributos[dias_de_pago]"];
    [dictionary setNotEmptyStringEscaped:client.domicilio forKey:@"atributos[domicilio]"];
    [dictionary setNotEmptyStringEscaped:client.domicilioDeEnvio forKey:@"atributos[domicilio_envio]"];
    [dictionary setNotEmptyStringEscaped:client.propietario forKey:@"atributos[dueno]"];
    [dictionary setNotEmptyStringEscaped:client.encCompras forKey:@"atributos[enc_compras]"];
    [dictionary setNotNilObject:client.expreso.identifier forKey:@"atributos[expreso_id]"];
    [dictionary setNotEmptyStringEscaped:client.horario forKey:@"atributos[horario]"];
    [dictionary setNotNilObject:client.lineaDeVenta.identifier forKey:@"atributos[linea_venta_id]"];
    [dictionary setNotEmptyStringEscaped:client.localidad forKey:@"atributos[localidad]"];
    [dictionary setNotEmptyStringEscaped:client.mail forKey:@"atributos[mail]"];
    [dictionary setNotEmptyStringEscaped:client.nombre forKey:@"atributos[nombre]"];
    [dictionary setNotEmptyStringEscaped:client.nombreDeFantasia forKey:@"atributos[nombre_fantasia]"];
    [dictionary setNotEmptyStringEscaped:client.observaciones forKey:@"atributos[observaciones]"];
    [dictionary setNotNilObject:client.zona.identifier forKey:@"atributos[provincia_id]"];
    [dictionary setNotNilObject:client.sucursal forKey:@"atributos[sucursal]"];
    [dictionary setNotEmptyStringEscaped:client.telefono forKey:@"atributos[telefono]"];
    [dictionary setNotNilObject:client.iva.identifier forKey:@"atributos[tipo_iva_id]"];
    [dictionary setNotEmptyStringEscaped:client.latitud forKey:@"atributos[ubicacion_gps_lat]"];
    [dictionary setNotEmptyStringEscaped:client.longitud forKey:@"atributos[ubicacion_gps_lng]"];
    [dictionary setNotNilObject:client.vendedor.identifier forKey:@"atributos[vendedor_id]"];
    [dictionary setNotNilObject:client.zonaEnvio.identifier forKey:@"atributos[zona_envio_id]"];
    [dictionary setNotEmptyStringEscaped:client.web forKey:@"atributos[web]"];
    
    return dictionary;
}
@end
