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
#import "Articulo+extra.h"
#import "CondPag.h"
#import "Vendedor.h"
#import "Expreso.h"
#import "LineaVTA.h"
#import "Provincia.h"
#import "ZonaEnvio.h"
#import "TipoIvas.h"
#import "Usuario.h"
#import "CtaCte.h"
#import "Precio+extra.h"
#import "Pedido+extra.h"
#import "Venta.h"
#import "Grupo.h"
#import "Disponibilidad.h"
#import "ItemPedido+extra.h"


@interface EQDataManager()

@property (nonatomic,assign) BOOL showLoading;
@property (nonatomic,assign) BOOL running;
@property (nonatomic,strong) FailRequest failBlock;

@end

@implementation EQDataManager

+ (EQDataManager *)sharedInstance {
    __strong static EQDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQDataManager alloc] init];
        sharedInstance.showLoading = YES;
        sharedInstance.running = NO;
        __weak EQDataManager *weakSelf = sharedInstance;
        sharedInstance.failBlock = ^(NSError *error){
            sharedInstance.running = NO;
            NSString *errorMessage = [NSString stringWithFormat:@"EQRequest fail error:%@ UserInfo:%@ \n Reinicie la aplicacion para terminar la carga de datos correctamente.",error ,error.userInfo];
            NSLog(@"%@",errorMessage);
            if (weakSelf.showLoading) {
                [APP_DELEGATE hideLoadingView];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hubo un error en la carga de datos" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        };
    });
    return sharedInstance;
}

- (void)updateDataShowLoading:(BOOL)show{
    if (!self.running) {
        self.running = YES;
        self.showLoading = show;
        [self updateShippingArea];
    }
}

- (void)updateCompleted{
    [[EQSession sharedInstance] dataUpdated];
    
    self.running = NO;
    [self sendPendingData];
}

- (void)sendPendingData{
    [self sendPendingOrders];
    [self sendPendingClients];
}

- (void)sendPendingOrders{
    EQDataAccessLayer *dal = [EQDataAccessLayer sharedInstance];
    NSArray *orders = [dal objectListForClass:[Pedido class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.actualizado == false"]];
    for (Pedido *order in orders) {
        [self sendOrder:order];
        [NSThread sleepForTimeInterval:5];
    }
}

- (void)sendPendingClients{
    EQDataAccessLayer *dal = [EQDataAccessLayer sharedInstance];
    NSArray *clients = [dal objectListForClass:[Cliente class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.actualizado == false"]];
    for (Cliente *client in clients) {
        [self sendClient:client];
        [NSThread sleepForTimeInterval:5];
    }
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

- (void)updatePageCompleted:(NSNumber *)page ForClass:(Class)class{
    NSString *className = NSStringFromClass(class);
    NSString *key = [className stringByAppendingString:@"PageUpdated"];
    NSString *keyDate = [className stringByAppendingString:@"PageUpdatedDate"];
    [[NSUserDefaults standardUserDefaults] setObject:page forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:keyDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.showLoading) {
        [APP_DELEGATE hideLoadingView];
    }
}

- (int)obtainNextPageForClass:(Class)class{
    NSString *className = NSStringFromClass(class);
    NSString *key = [className stringByAppendingString:@"PageUpdated"];
    NSString *keyDate = [className stringByAppendingString:@"PageUpdatedDate"];
    NSString *keyObject = [className stringByAppendingString:@"LastUpdate"];
    
    NSNumber *pageNumber = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSDate *lastPageSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:keyDate];
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:keyObject];
    
    //lastPageSyncDate mas reciente que lastSyncDate
    BOOL pageUpdateimcompleted = [lastPageSyncDate compare:lastSyncDate] == NSOrderedDescending;
    return !lastSyncDate || pageUpdateimcompleted ? [pageNumber intValue] + 1 : 1;
}

- (void)updateCompletedFor:(Class)class{
    NSString *className = NSStringFromClass(class);
    NSString *key = [className stringByAppendingString:@"LastUpdate"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.showLoading) {
        [APP_DELEGATE hideLoadingView];
    }
}

- (NSMutableDictionary *)obtainLastUpdateFor:(Class)class{
    NSString *className = NSStringFromClass(class);
    NSString *key = [className stringByAppendingString:@"LastUpdate"];
    NSDate *lastSyncDate = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSMutableDictionary *lastUpdate = [NSMutableDictionary dictionary];
    if (lastSyncDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
        [lastUpdate setNotEmptyStringEscaped:[dateFormatter stringFromDate:lastSyncDate] forKey:@"timestamp"];
    }
    
    return lastUpdate;
}

- (void)executeRequestWithParameters:(NSMutableDictionary *)parameters successBlock:(SuccessRequest)success failBlock:(FailRequest)fail{
    if (self.showLoading) {
        NSString *object = [[parameters[@"object"] stringByReplacingOccurrencesOfString:@"_" withString:@" "] uppercaseString];
        NSString *message = [NSString stringWithFormat:@"CARGANDO %@",object];
        if ([[parameters allKeys] containsObject:@"page"]) {
            message = [message stringByAppendingFormat:@" - PAGINA %@",parameters[@"page"]];
        }
        [APP_DELEGATE showLoadingViewWithMessage:message];
    }
    
    fail = fail ? fail : self.failBlock;
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:success failRequestBlock:fail];
    [EQNetworkManager makeRequest:request];
}

- (void)updateCost{
    int page = [self obtainNextPageForClass:[Precio class]];
    [self updateCostPage:page];
}

- (void)updateCostPage:(int)page{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"precio_articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Precio class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        if ([jsonArray count] > 0) {
            int firstId = 10000 * (page - 1);
            NSArray *pricesArray = [adl objectListForClass:[Precio class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier >= %i", firstId]];
            for (NSDictionary *priceDictionary in jsonArray) {
                Precio *price = nil;
                if ([pricesArray count] > 0) {
                    NSNumber *priceID = [[priceDictionary objectForKey:@"id"] number];
                    price = [[pricesArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Precio *evaluatedObject, NSDictionary *bindings) {
                        return [evaluatedObject.identifier isEqualToNumber:priceID];
                    }]] lastObject];
                }

                
                price = price ? price : (Precio *)[adl createManagedObject:@"Precio"];
                
                price.identifier = [[priceDictionary filterInvalidEntry:@"id"] number];
                price.importe = [[priceDictionary filterInvalidEntry:@"importe"] number];
                price.numero = [priceDictionary filterInvalidEntry:@"numero"];
                price.articuloID = [[priceDictionary filterInvalidEntry:@"articulo_id"] number];
            }
            
            [adl saveContext];
            int nextPage = page + 1;
            [self updatePageCompleted:dictionary[@"page"] ForClass:[Precio class]];
            [self updateCostPage:nextPage];
        } else {
            [self updateCompletedFor:[Precio class]];
            [self updateUsers];
        }
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)updateNotifications{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"comunicacion" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[NSObject class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        //TODO: implementar
        [self updateCompletedFor:[NSObject class]];
        [self updateGroups];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)updateOrders{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"pedido" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Pedido class]]];
   
    SuccessRequest success = ^(NSArray *jsonArray){
         EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *objectsList = [NSMutableArray array];
        for (NSDictionary *dictionary in jsonArray) {
            NSNumber *identifier = [dictionary[@"id"] number];
            Pedido *pedido = (Pedido *)[adl objectForClass:[Pedido class] withId:[[dictionary objectForKey:@"id"] number]];;
            pedido.identifier = identifier;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
            pedido.fecha = [dateFormatter dateFromString:dictionary[@"fecha"]];
            pedido.activo = [dictionary[@"activo"] number];
            pedido.descuento = [dictionary[@"descuento"] number];
            pedido.estado = [dictionary filterInvalidEntry:@"estado"] != nil ? [dictionary[@"estado"] lowercaseString] : @"pendiente";
            pedido.subTotal = [dictionary[@"subtotal"] number];
            pedido.latitud = [dictionary filterInvalidEntry:@"ubicacion_gps_lat"];
            pedido.longitud = [dictionary filterInvalidEntry:@"ubicacion_gps_lng"];
            pedido.total = [dictionary[@"total"] number];
            pedido.observaciones = [dictionary filterInvalidEntry:@"observaciones"];
            pedido.descuento3 = [dictionary[@"descuento3"] number];
            pedido.descuento4 = [dictionary[@"descuento4"] number];
            pedido.clienteID = [[dictionary filterInvalidEntry:@"cliente_id"] number];
            pedido.vendedorID = [[dictionary filterInvalidEntry:@"vendedor_id"] number];
            pedido.sincronizacion = [NSDate date];
            
            [objectsList addObject:pedido];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Pedido class]];
        [self updateItemPedido];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)updateItemPedido{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"pedido_articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[ItemPedido class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        for (NSDictionary *dictionary in jsonArray) {
            ItemPedido *item = (ItemPedido *)[adl objectForClass:[ItemPedido class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.articuloID == %@ && SELF.pedido.identifier == %@",[[dictionary objectForKey:@"articulo_id"] number],[[dictionary objectForKey:@"pedido_id"] number]]];
            if (!item) {
                item = (ItemPedido *)[adl createManagedObject:@"ItemPedido"];
            }
            
            item.articuloID = [[dictionary filterInvalidEntry:@"articulo_id"] number];
            item.cantidad = [[dictionary filterInvalidEntry:@"cantidad_pedida"] number];
            item.descuento1 = [[dictionary filterInvalidEntry:@"descuento1"] number];
            item.descuento2 = [[dictionary filterInvalidEntry:@"descuento2"] number];
            item.descuentoMonto = [[dictionary filterInvalidEntry:@"descuento_monto"] number];
            item.importeConDescuento = [[dictionary filterInvalidEntry:@"precio_con_descuento"] number];
            item.importeFinal = [[dictionary filterInvalidEntry:@"importe_final"] number];
            item.precioUnitario = [[dictionary filterInvalidEntry:@"precio_unitario"] number];
            item.pedido = (Pedido *)[adl objectForClass:[Pedido class] withId:[[dictionary filterInvalidEntry:@"pedido_id"] number]];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[ItemPedido class]];
        [self updateCurrentAccount];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)updateCurrentAccount{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@"cuenta_corriente" forKey:@"object"];
    [params setObject:@"listar" forKey:@"action"];
    [params addEntriesFromDictionary:[self obtainCredentials]];
    [params addEntriesFromDictionary:[self obtainLastUpdateFor:[CtaCte class]]];
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary *ctaCteDictionary in jsonArray) {
            CtaCte *ctaCte = (CtaCte *)[adl objectForClass:[CtaCte class] withId:[[ctaCteDictionary objectForKey:@"id"] number]];
            ctaCte.identifier = [[ctaCteDictionary filterInvalidEntry:@"id"] number];
            ctaCte.importe = [[ctaCteDictionary filterInvalidEntry:@"importe"] number];
            ctaCte.importePercepcion = [[ctaCteDictionary filterInvalidEntry:@"importe_percepcion"] number];
            ctaCte.empresa = [ctaCteDictionary filterInvalidEntry:@"empresa"];
            ctaCte.condicionDeVenta = [ctaCteDictionary filterInvalidEntry:@"condicion_de_venta"];
            ctaCte.comprobante = [ctaCteDictionary filterInvalidEntry:@"comprobante"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
            ctaCte.fecha = [dateFormatter dateFromString:ctaCteDictionary[@"fecha"]];
            ctaCte.importeConDescuento = [[ctaCteDictionary filterInvalidEntry:@"importe_con_desc"] number];
            ctaCte.cliente = (Cliente *)[adl objectForClass:[Cliente class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[ctaCteDictionary filterInvalidEntry:@"cliente_id"] number]]];
            ctaCte.vendedor = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[ctaCteDictionary filterInvalidEntry:@"vendedor_id"] number]]];
            [auxArray addObject:ctaCte];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[CtaCte class]];
        [self updateNotifications];
    };
    
    [self executeRequestWithParameters:params successBlock:success failBlock:nil];
}

- (void)updatePaymentCondition{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"condicion_pago" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[CondPag class]]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[CondPag class]];
        [self updateKindTaxes];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)updateKindSales{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"linea_venta" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[LineaVTA class]]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[LineaVTA class]];
        [self updateExpress];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)updateSales{
    int page = [self obtainNextPageForClass:[Venta class]];
    [self updateSalesPage:page];
}

- (void)updateSalesPage:(int)page{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"venta" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Venta class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *dal = [EQDataAccessLayer sharedInstanceForBatch];
        if ([jsonArray count] > 0) {
            int firstId = 10000 * (page - 1);
            NSArray *salesArray = [dal objectListForClass:[Venta class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier >= %i", firstId]];

            for (NSDictionary *dictionary in jsonArray) {
                NSNumber *identifier = [dictionary[@"id"] number];
                Venta *venta = nil;
                if ([salesArray count] > 0) {
                    venta = [[salesArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Venta *evaluatedObject, NSDictionary *bindings) {
                        return [evaluatedObject.identifier isEqualToNumber:identifier];
                    }]] lastObject];
                }
                
                venta = venta ? venta : (Venta *)[dal createManagedObject:@"Venta"];
                if (![venta.identifier isEqualToNumber:identifier]) {
                    venta.identifier = identifier;
                    venta.importe = [dictionary[@"importe"] number];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    venta.fecha = [dateFormatter dateFromString:dictionary[@"fecha"]];
                    venta.cantidad =  [dictionary[@"cantidad"] number];
                    venta.comprobante =  dictionary[@"comprobante"];
                    venta.empresa =  dictionary[@"empresa"];
                    venta.clienteID = [[dictionary filterInvalidEntry:@"cliente_id"] number];
                    venta.vendedorID = [[dictionary filterInvalidEntry:@"vendedor_id"] number];
                    venta.articuloID =  [[dictionary filterInvalidEntry:@"articulo_id"] number];
                }
            }
            
            [dal saveContext];
            int nextPage = page + 1;
            [self updatePageCompleted:dictionary[@"page"] ForClass:[Venta class]];
            [self updateSalesPage:nextPage];
        } else {
            [self updateCompletedFor:[Venta class]];
            [self updateCompleted];
        }
        
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)updateShippingArea{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"zona_envio" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[ZonaEnvio class]]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[ZonaEnvio class]];
        [self updateProvince];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)updateClients{
    SuccessRequest block = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* clienteDictionary in jsonArray) {
            Cliente *client = (Cliente *)[adl objectForClass:[Cliente class] withId:[clienteDictionary objectForKey:@"id"]];
            client.identifier = [[clienteDictionary filterInvalidEntry:@"id"] number];
            client.cobrador = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"cobrador_id"] number]]];
            client.codigoPostal = [clienteDictionary filterInvalidEntry:@"cod_postal"];
            client.codigo1 = [clienteDictionary filterInvalidEntry:@"codigo1"];
            client.codigo2 = [clienteDictionary filterInvalidEntry:@"codigo2"];
            client.condicionDePagoID = [[clienteDictionary filterInvalidEntry:@"condicion_pago_id"] number];
            client.cuit = [clienteDictionary filterInvalidEntry:@"cuit"];
            client.descuento1 = [[clienteDictionary filterInvalidEntry:@"descuento1"] number];
            client.descuento2 = [[clienteDictionary filterInvalidEntry:@"descuento2"] number];
            client.descuento3 = [[clienteDictionary filterInvalidEntry:@"descuento3"] number];
            client.descuento4 = [[clienteDictionary filterInvalidEntry:@"descuento4"] number];
            client.diasDePago = [clienteDictionary filterInvalidEntry:@"dias_de_pago"];
            client.domicilio = [clienteDictionary filterInvalidEntry:@"domicilio"];
            client.domicilioDeEnvio = [clienteDictionary filterInvalidEntry:@"domicilio_envio"];
            client.propietario = [clienteDictionary filterInvalidEntry:@"dueno"];
            client.encCompras = [clienteDictionary filterInvalidEntry:@"enc_compras"];
            client.expresoID = [[clienteDictionary filterInvalidEntry:@"expreso_id"] number];
            client.horario = [clienteDictionary filterInvalidEntry:@"horario"];
            client.lineaDeVentaID = [[clienteDictionary filterInvalidEntry:@"linea_venta_id"] number];
            client.localidad = [clienteDictionary filterInvalidEntry:@"localidad"];
            client.mail = [clienteDictionary filterInvalidEntry:@"mail"];
            client.nombre = [clienteDictionary filterInvalidEntry:@"nombre"];
            client.nombreDeFantasia = [clienteDictionary filterInvalidEntry:@"nombre_fantasia"];
            client.observaciones = [clienteDictionary filterInvalidEntry:@"observaciones"];
            client.provinciaID = [[clienteDictionary filterInvalidEntry:@"provincia_id"] number];
            client.sucursal = [[clienteDictionary filterInvalidEntry:@"sucursal"] number];
            client.telefono = [clienteDictionary filterInvalidEntry:@"telefono"];
            client.ivaID = [[clienteDictionary filterInvalidEntry:@"tipo_iva_id"] number];
            client.latitud = [clienteDictionary filterInvalidEntry:@"ubicacion_gps_lat"];
            client.longitud = [clienteDictionary filterInvalidEntry:@"ubicacion_gps_lng"];
            Vendedor *seller = (Vendedor *)[adl objectForClass:[Vendedor class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.identifier == %@",[[clienteDictionary filterInvalidEntry:@"vendedor_id"] number]]];
            client.vendedor = seller;
            client.zonaEnvioID = [[clienteDictionary filterInvalidEntry:@"zona_envio_id"] number];
            client.web = [clienteDictionary filterInvalidEntry:@"web"];
            client.actualizado = [NSNumber numberWithBool:YES];
            client.activo = [[clienteDictionary filterInvalidEntry:@"activo"] number];
            
            [auxArray addObject:client];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Cliente class]];
        [self updateCost];
    };

    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"cliente" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Cliente class]]];
    
    [self executeRequestWithParameters:dictionary successBlock:block failBlock:nil];
}

- (void)updateProducts{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* articuloDictionary in jsonArray) {
            Articulo *art = (Articulo *)[adl objectForClass:[Articulo class] withId:[articuloDictionary objectForKey:@"id"]];
            art.identifier = [[articuloDictionary filterInvalidEntry:@"id"] number];
            NSMutableString *codigo = [NSMutableString stringWithString:[articuloDictionary filterInvalidEntry:@"codigo1"]];
            [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo2"]];
            [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo3"]];
            art.codigo = codigo;
            art.nombre = [articuloDictionary filterInvalidEntry:@"post_title"];
            art.descripcion = [articuloDictionary filterInvalidEntry:@"descripcion"];
            art.imagenURL = [articuloDictionary filterInvalidEntry:@"foto"];
            if(art.imagenURL){
                NSLog(@"producto: %@ url: %@", art.nombre, art.imagenURL);
            }
            art.tipo = [articuloDictionary filterInvalidEntry:@"tipo"];
            NSNumber *multiplo = [[articuloDictionary filterInvalidEntry:@"multiplo_pedido"] number];
            art.multiploPedido = [multiplo intValue] > 0 ? multiplo : @3;
            art.minimoPedido = [[articuloDictionary filterInvalidEntry:@"minimo_pedido"] number];
            art.disponibilidadID = [[articuloDictionary filterInvalidEntry:@"disponibilidad_id"] number];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
            art.creado = [dateFormatter dateFromString:[articuloDictionary filterInvalidEntry:@"creado"]];
            art.modificado = [dateFormatter dateFromString:[articuloDictionary filterInvalidEntry:@"modificado"]];
            
            art.cantidadPredeterminada = [[articuloDictionary filterInvalidEntry:@"cant_predeterm"] number];
            art.activo = [[articuloDictionary filterInvalidEntry:@"activo"] number];
            art.grupoID = [[articuloDictionary filterInvalidEntry:@"term_id"] number];
            [auxArray addObject:art];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Articulo class]];
        [self updateSellers];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Articulo class]]];
    
    [self executeRequestWithParameters:dictionary successBlock:block failBlock:nil];
}

- (void)updateSellers{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *auxArray = [NSMutableArray array];
        for (NSDictionary* vendedorDictionary in jsonArray) {
            Vendedor *seller = (Vendedor *)[adl objectForClass:[Vendedor class] withId:[vendedorDictionary objectForKey:@"id"]];
            seller.identifier = [[vendedorDictionary filterInvalidEntry:@"id"] number];
            seller.codigo = [vendedorDictionary filterInvalidEntry:@"codigo"];
            seller.descripcion = [vendedorDictionary filterInvalidEntry:@"descripcion"];
            seller.activo = [[vendedorDictionary filterInvalidEntry:@"activo"] number];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.vendedor.identifier == %@", seller.identifier];
            Usuario *user = (Usuario *)[adl objectForClass:[Usuario class] withPredicate:predicate];
            seller.usuario = user;
            [auxArray addObject:seller];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Vendedor class]];
        [self updatePaymentCondition];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"vendedor" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Vendedor class]]];
    
    [self executeRequestWithParameters:dictionary successBlock:block failBlock:nil];
}

- (void)updateExpress{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[Expreso class]];
        [self updateClients];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"expreso" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[Expreso class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

- (void)updateProvince{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[Provincia class]];
        [self updateAvailability];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"provincia" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[Provincia class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

- (void)updateKindTaxes{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[TipoIvas class]];
        [self updateKindSales];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"tipo_iva" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[TipoIvas class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

- (void)updateUsers{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
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
        [self updateCompletedFor:[Usuario class]];
        [self updateOrders];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"login" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[Usuario class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

- (void)updateGroups{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *grupos = [NSMutableArray array];
        for (NSDictionary* dictionary in jsonArray) {
            NSNumber *identifier = [[dictionary filterInvalidEntry:@"term_id"] number];
            Grupo *group = (Grupo *)[adl objectForClass:[Grupo class] withId:identifier];
            group.identifier = identifier;
            group.nombre = [dictionary filterInvalidEntry:@"name"];
            group.parentID = [[dictionary filterInvalidEntry:@"parent"] number];
            group.descripcion = [dictionary filterInvalidEntry:@"description"];
            group.count = [[dictionary filterInvalidEntry:@"count"] number];
            group.relevancia = @0;
            [grupos addObject:group];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Grupo class]];
        [self updateSales];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"categoria" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[Grupo class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

- (void)updateAvailability{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstanceForBatch];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary* dictionary in jsonArray) {
            NSNumber *identifier = [[dictionary filterInvalidEntry:@"id"] number];
            Disponibilidad *disponibilidad = (Disponibilidad *)[adl objectForClass:[Disponibilidad class] withId:identifier];
            disponibilidad.identifier = identifier;
            disponibilidad.descripcion = [dictionary filterInvalidEntry:@"descripcion"];
            [array addObject:disponibilidad];
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Disponibilidad class]];
        [self updateProducts];
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"listar" forKey:@"action"];
    [parameters setObject:@"disponibilidad" forKey:@"object"];
    [parameters addEntriesFromDictionary:[self obtainCredentials]];
    [parameters addEntriesFromDictionary:[self obtainLastUpdateFor:[Disponibilidad class]]];
    
    [self executeRequestWithParameters:parameters successBlock:block failBlock:nil];
}

#pragma mark - update server

- (void)sendClient:(Cliente *)client{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setNotNilObject:@"cliente" forKey:@"object"];
    [dictionary setNotNilObject:[client.identifier intValue] > 0 ? @"modificar":@"crear" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self parseClient:client]];

    __block Cliente *newClient = client;
    SuccessRequest block = ^(NSDictionary *clientDictionary){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSNumber *identifier = [clientDictionary filterInvalidEntry:@"obj_id"];
        if (identifier) {
            newClient.identifier = identifier;
        }
        
        newClient.actualizado = [NSNumber numberWithBool:YES];
        [adl saveContext];
    };
    
    FailRequest failBlock = ^(NSError *error){
        NSLog(@"send client fail error:%@ UserInfo:%@",error ,error.userInfo);
        newClient.actualizado = [NSNumber numberWithBool:NO];
        [[EQDataAccessLayer sharedInstance] saveContext];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:failBlock];
    [EQNetworkManager makeRequest:request];
}

- (NSMutableDictionary *)parseClient:(Cliente *)client{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if([client.identifier intValue] > 0) {
        [dictionary setNotNilObject:client.identifier forKey:@"id"];
    }
    [dictionary setNotNilObject:client.cobrador.identifier forKey:@"atributos[cobrador_id]"];
    [dictionary setNotEmptyStringEscaped:client.codigoPostal forKey:@"atributos[cod_postal]"];
    [dictionary setNotEmptyStringEscaped:client.codigo1 forKey:@"atributos[codigo1]"];
    [dictionary setNotEmptyStringEscaped:client.codigo2 forKey:@"atributos[codigo2]"];
    [dictionary setNotNilObject:client.condicionDePagoID forKey:@"atributos[condicion_pago_id]"];
    [dictionary setNotEmptyStringEscaped:client.cuit forKey:@"atributos[cuit]"];
    [dictionary setObject:client.descuento1 forKey:@"atributos[descuento1]"];
    [dictionary setObject:client.descuento2 forKey:@"atributos[descuento2]"];
    [dictionary setObject:client.descuento3 forKey:@"atributos[descuento3]"];
    [dictionary setObject:client.descuento4 forKey:@"atributos[descuento4]"];
    [dictionary setNotEmptyStringEscaped:client.diasDePago forKey:@"atributos[dias_de_pago]"];
    [dictionary setNotEmptyStringEscaped:client.domicilio forKey:@"atributos[domicilio]"];
    [dictionary setNotEmptyStringEscaped:client.domicilioDeEnvio forKey:@"atributos[domicilio_envio]"];
    [dictionary setNotEmptyStringEscaped:client.propietario forKey:@"atributos[dueno]"];
    [dictionary setNotEmptyStringEscaped:client.encCompras forKey:@"atributos[enc_compras]"];
    [dictionary setNotNilObject:client.expresoID forKey:@"atributos[expreso_id]"];
    [dictionary setNotEmptyStringEscaped:client.horario forKey:@"atributos[horario]"];
    [dictionary setNotNilObject:client.lineaDeVentaID forKey:@"atributos[linea_venta_id]"];
    [dictionary setNotEmptyStringEscaped:client.localidad forKey:@"atributos[localidad]"];
    [dictionary setNotEmptyStringEscaped:client.mail forKey:@"atributos[mail]"];
    [dictionary setNotEmptyStringEscaped:client.nombre forKey:@"atributos[nombre]"];
    [dictionary setNotEmptyStringEscaped:client.nombreDeFantasia forKey:@"atributos[nombre_fantasia]"];
    [dictionary setNotEmptyStringEscaped:client.observaciones forKey:@"atributos[observaciones]"];
    [dictionary setNotNilObject:client.provinciaID forKey:@"atributos[provincia_id]"];
    [dictionary setNotNilObject:client.sucursal forKey:@"atributos[sucursal]"];
    [dictionary setNotEmptyStringEscaped:client.telefono forKey:@"atributos[telefono]"];
    [dictionary setNotNilObject:client.ivaID forKey:@"atributos[tipo_iva_id]"];
    [dictionary setNotEmptyStringEscaped:client.latitud forKey:@"atributos[ubicacion_gps_lat]"];
    [dictionary setNotEmptyStringEscaped:client.longitud forKey:@"atributos[ubicacion_gps_lng]"];
    [dictionary setNotNilObject:client.vendedor.identifier forKey:@"atributos[vendedor_id]"];
    [dictionary setNotNilObject:client.zonaEnvioID forKey:@"atributos[zona_envio_id]"];
    [dictionary setNotEmptyStringEscaped:client.web forKey:@"atributos[web]"];
    [dictionary setObject:client.activo forKey:@"atributos[activo]"];
    
    return dictionary;
}

- (void)sendOrder:(Pedido *)order{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setNotNilObject:@"pedido" forKey:@"object"];
    [dictionary setNotNilObject:[order.identifier intValue] > 0 ? @"modificar":@"crear" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self parseOrder:order]];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"POST"];
    
    __block Pedido *newOrder = order;
    SuccessRequest block = ^(NSDictionary *clientDictionary){
        NSNumber *identifier = [clientDictionary filterInvalidEntry:@"obj_id"];
        if (identifier) {
            newOrder.identifier = identifier;
        }
        
        newOrder.sincronizacion = [NSDate date];
        newOrder.actualizado = [NSNumber numberWithBool:YES];
        [[EQDataAccessLayer sharedInstance] saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_NOTIFICATION object:nil];
    };
    
    FailRequest failBlock = ^(NSError *error){
        NSLog(@"send order fail error:%@ UserInfo:%@",error ,error.userInfo);
         newOrder.actualizado = [NSNumber numberWithBool:NO];
        [[EQDataAccessLayer sharedInstance] saveContext];
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_NOTIFICATION object:nil];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:failBlock];
    [EQNetworkManager makeRequest:request];
}

- (NSMutableDictionary *)parseOrder:(Pedido *)order{
    NSMutableArray *items = [NSMutableArray array];
    for (ItemPedido *item in order.items) {
        NSMutableDictionary *itemDictionary = [NSMutableDictionary dictionary];
        float descuento = [item totalSinDescuento] - [item totalConDescuento];
        [itemDictionary setObject:item.articuloID forKey:@"articulo_id"];
        [itemDictionary setObject:item.cantidad forKey:@"cantidad_pedida"];
        [itemDictionary setObject:item.pedido.cliente.descuento1 ? item.pedido.cliente.descuento1 : @0 forKey:@"descuento1"];
        [itemDictionary setObject:item.pedido.cliente.descuento2 ? item.pedido.cliente.descuento2 : @0 forKey:@"descuento2"];
        [itemDictionary setObject:[NSNumber numberWithFloat:descuento] forKey:@"descuento_monto"];
        [itemDictionary setObject:[NSNumber numberWithFloat:[item totalConDescuento]] forKey:@"importe_final"];
        [itemDictionary setObject:[NSNumber numberWithFloat:[item.articulo.precio priceForClient:item.pedido.cliente]] forKey:@"precio_con_descuento"];
        [itemDictionary setObject:item.articulo.precio.importe forKey:@"precio_unitario"];
        
        [items addObject:itemDictionary];
    }
    
    NSMutableDictionary *orderDictionary = [NSMutableDictionary dictionary];
    if([order.identifier intValue] > 0) {
        [orderDictionary setNotNilObject:order.identifier forKey:@"id"];
    }
    [orderDictionary setValue:order.clienteID forKey:@"cliente_id"];
    [orderDictionary setValue:order.vendedorID forKey:@"vendedor_id"];
    [orderDictionary setValue:order.latitud forKey:@"ubicacion_gps_lat"];
    [orderDictionary setValue:order.longitud forKey:@"ubicacion_gps_lng"];
    [orderDictionary setValue:order.observaciones forKey:@"observaciones"];
    [orderDictionary setValue:order.activo forKey:@"activo"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-3];
    [orderDictionary setValue:[dateFormatter stringFromDate:order.fecha] forKey:@"fecha"];
    [orderDictionary setValue:items forKey:@"articulos"];
    [orderDictionary setValue:[order total] forKey:@"total"];
    [orderDictionary setValue:[order subTotal] forKey:@"subtotal"];
    [orderDictionary setValue:order.estado forKey:@"estado"];
    [orderDictionary setValue:order.descuento forKey:@"descuento"];
    [orderDictionary setValue:order.descuento3 forKey:@"descuento3"];
    [orderDictionary setValue:order.descuento4 forKey:@"descuento4"];
    return orderDictionary;
}

@end
