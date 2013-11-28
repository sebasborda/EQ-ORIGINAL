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
#import "Venta.h"
#import "Grupo.h"
#import "Disponibilidad.h"
#import "ItemPedido+extra.h"
#import "EQImagesManager.h"
#import "ItemFacturado.h"
#import "Catalogo+extra.h"
#import "AFImageRequestOperation.h"
#import "CatalogoImagen.h"

#define OBJECTS_PER_PAGE 5000
#define DATE_FORMATTER [[NSDateFormatter alloc] init]

@interface EQDataManager()

@property (nonatomic,assign) BOOL showLoading;
@property (nonatomic,assign) BOOL running;
@property (nonatomic,strong) FailRequest failBlock;
@property (nonatomic,assign) BOOL dataUpdated;
@property (nonatomic,strong) NSPredicate *objectIDPredicate;

@end

@implementation EQDataManager

+ (EQDataManager *)sharedInstance {
    __strong static EQDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[EQDataManager alloc] init];
        sharedInstance.showLoading = YES;
        sharedInstance.running = NO;
        sharedInstance.objectIDPredicate = [NSPredicate predicateWithFormat:@"identifier == $OBJECT_ID"];
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
        self.dataUpdated = NO;
        self.running = YES;
        self.showLoading = show;
        // start load
        if (show) {
            [self updateShippingArea];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self updateShippingArea];
            });
        }
    }
}

- (void)updateCompleted{
    self.running = NO;
    [[EQSession sharedInstance] dataUpdated];
    if (self.dataUpdated) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_UPDATED_NOTIFICATION object:nil];
    }
}

- (void)sendPendingData{
    [self sendPendingOrders];
    [self sendPendingClients];
    [self sendPendingCommunications];
}

- (void)sendPendingCommunications{
    EQDataAccessLayer *dal = [EQDataAccessLayer sharedInstance];
    NSArray *communications = [dal objectListForClass:[Comunicacion class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.actualizado == false"]];
    for (Comunicacion *communication in communications) {
        [self sendCommunication:communication];
        [NSThread sleepForTimeInterval:5];
    }
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
        NSDateFormatter *dateFormatter = DATE_FORMATTER;
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
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
    EQRequest *request = [[EQRequest alloc] initWithParams:parameters successRequestBlock:success failRequestBlock:fail runInBackground:!self.showLoading];
    [EQNetworkManager makeRequest:request];
}

- (void)updateCost{
    int page = [self obtainNextPageForClass:[Precio class]];
    BOOL override = page==1 && [[[self obtainLastUpdateFor:[Precio class]] allKeys] count] != 0;
    [self updateCostPage:page forceOverride:override ];
}

- (void)updateCostPage:(int)page forceOverride:(BOOL)override{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"precio_articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Precio class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        NSNumber *active = [NSNumber numberWithBool:!override];
        if ([jsonArray count] > 0) {
            NSEntityDescription *entity = [[adl.managedObjectModel entitiesByName]
                                           objectForKey:@"Precio"];
            int groups = [jsonArray count] / 200;
            groups += [jsonArray count] % 200 > 0 ? 1 : 0;
            for (int j = 0; j < groups ; j++) {
                int base = 200 * j;
                int max = base + 200 < [jsonArray count] ? base + 200 : [jsonArray count];
                @autoreleasepool {
                    for (int i = base; i < max; i++) {
                        NSDictionary *priceDictionary = [jsonArray objectAtIndex:i];
                        Precio *price = (Precio *)[adl createManagedObjectWithEntity:entity];
                        price.identifier = [priceDictionary objectForKey:@"id"];
                        price.importe = [[priceDictionary filterInvalidEntry:@"importe"] number];
                        price.numero = [priceDictionary filterInvalidEntry:@"numero"];
                        price.articuloID = [priceDictionary filterInvalidEntry:@"articulo_id"];
                        price.activo = active;
                        self.dataUpdated = YES;
                    }
                    [adl saveContext];
                }
            }
            int nextPage = page + 1;
            [self updatePageCompleted:dictionary[@"page"] ForClass:[Precio class]];
            [self updateCostPage:nextPage forceOverride:override];
        } else {
            if (page > 1 && override) {
                [self changePricesList];
            }
            [self updateCompletedFor:[Precio class]];
            [self updateUsers];
        }
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)changePricesList{
    NSManagedObjectContext *context = [[EQDataAccessLayer sharedInstance] managedObjectContext];
    NSError *error = nil;
    @autoreleasepool {
        NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Precio"];
        //Get old prices
        allRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.activo == %@",[NSNumber numberWithBool:YES]];
        NSArray *objects = [context executeFetchRequest:allRequest error:&error];
        //Delete old prices
        for (Precio *price in objects) {
            [context deleteObject:price];
        }
        [[EQDataAccessLayer sharedInstance] saveContext];
    }
    
    @autoreleasepool {
        NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Precio"];
        allRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.activo == %@",[NSNumber numberWithBool:NO]];
        //fetch new prices
        NSArray *newObjects = [context executeFetchRequest:allRequest error:&error];
        [newObjects setValue:[NSNumber numberWithBool:YES] forKey:@"activo"];
        //now save your changes back.
        [[EQDataAccessLayer sharedInstance] saveContext];
    }
}

- (void)updateNotifications{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"comunicacion" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Comunicacion class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary *dictionary in jsonArray) {
            NSString *identifier = dictionary[@"id"];
            Comunicacion *notification = (Comunicacion *)[adl objectForClass:[Comunicacion class] withId:identifier];
            notification.identifier = identifier;
            notification.titulo = dictionary[@"titulo"];
            notification.descripcion = dictionary[@"descripcion"];
            notification.clienteID = [dictionary filterInvalidEntry:@"cliente_id"];
            notification.senderID = dictionary[@"sender_id"];
            notification.receiverID = dictionary[@"receiver_id"];
            notification.threadID = dictionary[@"thread_id"];
            notification.tipo = dictionary[@"tipo"];
            if (dictionary[@"leido"] != [NSNull null]) {
                notification.leido = [NSDate dateWithTimeIntervalSince1970:[[dictionary[@"leido"] number] doubleValue]];
            }
            notification.activo = [dictionary[@"activo"] number];
            notification.actualizado = [NSNumber numberWithBool:YES];
            notification.codigoSerial = [dictionary[@"codigo_serial"] number];
            NSDateFormatter *dateFormatter = DATE_FORMATTER;
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            notification.creado = [dateFormatter dateFromString:dictionary[@"creado"]];
            self.dataUpdated = YES;
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Comunicacion class]];
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary *dictionary in jsonArray) {
            NSString *identifier = dictionary[@"id"];
            Pedido *pedido = (Pedido *)[adl objectForClass:[Pedido class] withId:identifier];
            pedido.identifier = identifier;
            NSDateFormatter *dateFormatter = DATE_FORMATTER;
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            pedido.fecha = [dateFormatter dateFromString:dictionary[@"fecha"]];
            pedido.activo = [dictionary[@"activo"] number];
            pedido.descuento = [dictionary[@"descuento"] number];
            pedido.estado = [dictionary filterInvalidEntry:@"estado"] != nil ? [dictionary[@"estado"] lowercaseString] : @"pendiente";
            pedido.subTotal = [dictionary[@"subtotal"] number];
            pedido.latitud = [[dictionary filterInvalidEntry:@"ubicacion_gps_lat"] number];
            pedido.longitud = [[dictionary filterInvalidEntry:@"ubicacion_gps_lng"] number];
            pedido.total = [dictionary[@"total"] number];
            pedido.observaciones = [dictionary filterInvalidEntry:@"observaciones"];
            pedido.descuento3 = [dictionary[@"descuento3"] number];
            pedido.descuento4 = [dictionary[@"descuento4"] number];
            pedido.clienteID = [dictionary filterInvalidEntry:@"cliente_id"];
            pedido.vendedorID = [dictionary filterInvalidEntry:@"vendedor_id"];
            pedido.actualizado = [NSNumber numberWithBool:YES];
            pedido.sincronizacion = [NSDate date];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary *dictionary in jsonArray) {
            NSString *identifier = [[dictionary objectForKey:@"articulo_id"] stringByAppendingFormat:@"-%@",[dictionary objectForKey:@"pedido_id"]];
            
            NSString* articuloID = [dictionary filterInvalidEntry:@"articulo_id"];
            NSString* pedidoID = [dictionary filterInvalidEntry:@"pedido_id"];
            ItemPedido *item = (ItemPedido *)[adl objectForClass:[ItemPedido class] withPredicate:[NSPredicate predicateWithFormat:@"articuloID == %@ && pedido.identifier == %@",articuloID,pedidoID]];
            if (!item) {
                item = (ItemPedido *)[adl createManagedObject:@"ItemPedido"];
            }
            
            item.identifier = identifier;
            item.articuloID = articuloID;
            item.cantidad = [[dictionary filterInvalidEntry:@"cantidad_pedida"] number];
            item.cantidadFacturada = [[dictionary filterInvalidEntry:@"cantidad_facturada"] number];
            item.descuento1 = [[dictionary filterInvalidEntry:@"descuento1"] number];
            item.descuento2 = [[dictionary filterInvalidEntry:@"descuento2"] number];
            item.descuentoMonto = [[dictionary filterInvalidEntry:@"descuento_monto"] number];
            item.importeConDescuento = [[dictionary filterInvalidEntry:@"precio_con_descuento"] number];
            item.importeFinal = [[dictionary filterInvalidEntry:@"importe_final"] number];
            item.precioUnitario = [[dictionary filterInvalidEntry:@"precio_unitario"] number];
            item.pedido = (Pedido *)[adl objectForClass:[Pedido class] withId:pedidoID];
            NSDateFormatter *dateFormatter = DATE_FORMATTER;
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *fecha_facturado = [dictionary filterInvalidEntry:@"fecha_facturado"];
            NSArray *dates = [fecha_facturado componentsSeparatedByString:@","];
            for (NSString *date in dates) {
                NSDate *fecha = [dateFormatter dateFromString:date];
                ItemFacturado *facturado = (ItemFacturado *)[adl objectForClass:[ItemFacturado class] withPredicate:[NSPredicate predicateWithFormat:@"SELF.facturado == %@ && SELF.itemId == %@",fecha,item.identifier]];
                if (!facturado) {
                    facturado = (ItemFacturado *)[adl createManagedObject:@"ItemFacturado"];
                    facturado.itemId = item.identifier;
                    facturado.facturado = fecha;
                }
            }
            
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary *ctaCteDictionary in jsonArray) {
            CtaCte *ctaCte = (CtaCte *)[adl objectForClass:[CtaCte class] withId:[ctaCteDictionary objectForKey:@"id"]];
            ctaCte.identifier = [ctaCteDictionary filterInvalidEntry:@"id"];
            ctaCte.importe = [[ctaCteDictionary filterInvalidEntry:@"importe"] number];
            ctaCte.importePercepcion = [[ctaCteDictionary filterInvalidEntry:@"importe_percepcion"] number];
            ctaCte.empresa = [ctaCteDictionary filterInvalidEntry:@"empresa"];
            ctaCte.condicionDeVenta = [ctaCteDictionary filterInvalidEntry:@"condicion_de_venta"];
            ctaCte.comprobante = [ctaCteDictionary filterInvalidEntry:@"comprobante"];
            NSDateFormatter *dateFormatter = DATE_FORMATTER;
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            ctaCte.fecha = [dateFormatter dateFromString:ctaCteDictionary[@"fecha"]];
            ctaCte.importeConDescuento = [[ctaCteDictionary filterInvalidEntry:@"importe_con_desc"] number];
            ctaCte.clienteID = [ctaCteDictionary filterInvalidEntry:@"cliente_id"];
            ctaCte.vendedorID = [ctaCteDictionary filterInvalidEntry:@"vendedor_id"];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* condPagDictionary in jsonArray) {
            CondPag *condPag = (CondPag *)[adl objectForClass:[CondPag class] withId:[condPagDictionary objectForKey:@"id"]];
            condPag.identifier = [condPagDictionary filterInvalidEntry:@"id"];
            condPag.descripcion = [condPagDictionary filterInvalidEntry:@"descripcion"];
            condPag.codigo = [condPagDictionary filterInvalidEntry:@"codigo"];
            condPag.activo = [[condPagDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* ventaDictionary in jsonArray) {
            LineaVTA *venta = (LineaVTA *)[adl objectForClass:[LineaVTA class] withId:[ventaDictionary objectForKey:@"id"]];
            venta.identifier = [ventaDictionary filterInvalidEntry:@"id"];
            venta.descripcion = [ventaDictionary filterInvalidEntry:@"descripcion"];
            venta.codigo = [ventaDictionary filterInvalidEntry:@"codigo"];
            venta.activo = [[ventaDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
        }
        
        [adl saveContext];
        [self updateCompletedFor:[LineaVTA class]];
        [self updateExpress];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)updateSales{
    int page = [self obtainNextPageForClass:[Venta class]];
    BOOL override = page==1 && [[[self obtainLastUpdateFor:[Venta class]] allKeys] count] != 0;
    [self updateSalesPage:page forceOverride:override];
}

- (void)updateSalesPage:(int)page forceOverride:(BOOL)override{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"venta" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary setObject:[NSNumber numberWithInt:page] forKey:@"page"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Venta class]]];
    
    SuccessRequest success = ^(NSArray *jsonArray){
        NSNumber *active = [NSNumber numberWithBool:!override];
        EQDataAccessLayer *dal = [EQDataAccessLayer sharedInstance];
        if ([jsonArray count] > 0) {
            NSEntityDescription *entity = [[dal.managedObjectModel entitiesByName] objectForKey:@"Venta"];
            int groups = [jsonArray count] / 200;
            groups += [jsonArray count] % 200 > 0 ? 1 : 0;
            for (int j = 0; j < groups ; j++) {
                int base = 200 * j;
                int max = base + 200 < [jsonArray count] ? base + 200 : [jsonArray count];
                @autoreleasepool {
                    for (int i = base; i < max; i++) {
                        NSDictionary *salesDictionary = [jsonArray objectAtIndex:i];
                        Venta *venta = (Venta *)[dal createManagedObjectWithEntity:entity];
                        venta.identifier = salesDictionary[@"id"];
                        venta.importe = [salesDictionary[@"importe"] number];
                        NSDateFormatter *dateFormatter = DATE_FORMATTER;
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                        venta.fecha = [dateFormatter dateFromString:salesDictionary[@"fecha"]];
                        venta.cantidad =  [salesDictionary[@"cantidad"] number];
                        venta.comprobante =  salesDictionary[@"comprobante"];
                        venta.empresa =  salesDictionary[@"empresa"];
                        venta.clienteID = [salesDictionary filterInvalidEntry:@"cliente_id"];
                        venta.vendedorID = [salesDictionary filterInvalidEntry:@"vendedor_id"];
                        venta.articuloID =  [salesDictionary filterInvalidEntry:@"articulo_id"];
                        venta.activo = active;
                        self.dataUpdated = YES;
                    }
                    [dal saveContext];
                }
            }
            int nextPage = page + 1;
            [self updatePageCompleted:dictionary[@"page"] ForClass:[Venta class]];
            [self updateSalesPage:nextPage forceOverride:override];
        } else {
            if (page > 1 && override) {
                [self changeSalesList];
            }
            [self updateCompletedFor:[Venta class]];
            [self updateCatalog];
        }
        
    };
    
    [self executeRequestWithParameters:dictionary successBlock:success failBlock:nil];
}

- (void)deleteCatalogs{
    NSManagedObjectContext *context = [[EQDataAccessLayer sharedInstance] managedObjectContext];
    NSError *error = nil;
    @autoreleasepool {
        NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Catalogo"];
        NSArray *objects = [context executeFetchRequest:allRequest error:&error];
        //Delete old catalogs
        for (Catalogo *catalogo in objects) {
            [context deleteObject:catalogo];
        }
        
        NSFetchRequest *allImagesRequest = [[NSFetchRequest alloc] initWithEntityName:@"CatalogoImagen"];
        NSArray *imagenes = [context executeFetchRequest:allImagesRequest error:&error];
        //Delete old catalogs
        for (CatalogoImagen *imagen in imagenes) {
            [context deleteObject:imagen];
        }
        [[EQDataAccessLayer sharedInstance] saveContext];
    }
}

//last load method
- (void)updateCatalog{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"catalogo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        [self deleteCatalogs];
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        // make a directory for these
        NSFileManager *mgr = [NSFileManager defaultManager];
        BOOL isDir;
        int catalogNumber = 1;
        for (NSDictionary* catalogoDictionary in jsonArray) {
            Catalogo *catalogo = (Catalogo *)[adl objectForClass:[Catalogo class] withId:[catalogoDictionary objectForKey:@"id"]];
            catalogo.identifier = [[catalogoDictionary filterInvalidEntry:@"id"] stringValue];
            catalogo.titulo = [catalogoDictionary filterInvalidEntry:@"titulo"];
            catalogo.posicion = [NSNumber numberWithInt:catalogNumber];
            NSString *picturesPath = [NSString stringWithFormat:CACHE_DIRECTORY_FORMAT, NSHomeDirectory(),catalogo.identifier];
            if (![mgr fileExistsAtPath:picturesPath isDirectory:&isDir]) {
                [mgr createDirectoryAtPath:picturesPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            
            if ([[catalogoDictionary filterInvalidEntry:@"fotos_ipad"] isKindOfClass:[NSArray class]]) {
                int pagina = 0;
                for (NSString *fotoPath in [catalogoDictionary objectForKey:@"fotos_ipad"]) {
                    pagina++;
                    NSString *fileName = [[fotoPath componentsSeparatedByString:@"/"] lastObject];
                    if ([fileName length] > 0) {
                        fileName = [catalogo.identifier stringByAppendingFormat:@"/%@",fileName];
                        if (![[EQImagesManager sharedInstance] existImageNamed:fileName]) {
                            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[BASE_URL stringByAppendingString:fotoPath]]];
                            AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                [[EQImagesManager sharedInstance] saveImage:image named:fileName];
                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                NSLog(@"%@",error);
                            }];
                            [operation start];
                        }
                        CatalogoImagen *imagen = (CatalogoImagen *)[adl createManagedObject:@"CatalogoImagen"];
                        imagen.catalogoID = catalogo.identifier;
                        imagen.nombre = fileName;
                        imagen.pagina = [NSNumber numberWithInt:pagina];
                    }
                }
            }
            
            for (NSDictionary *category in [catalogoDictionary filterInvalidEntry:@"categorias"]) {
                Grupo *grupo = (Grupo *)[adl objectForClass:[Grupo class] withId:[category objectForKey:@"term_id"]];
                [catalogo addCategoriasObject:grupo];
            }
            
            self.dataUpdated = YES;
            catalogNumber++;
        }
        
        [adl saveContext];
        [self updateCompletedFor:[Catalogo class]];
        [self performSelectorOnMainThread:@selector(updateCompleted) withObject:nil waitUntilDone:NO];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)changeSalesList{
    NSManagedObjectContext *context = [[EQDataAccessLayer sharedInstance] managedObjectContext];
    NSError *error = nil;
    @autoreleasepool {
        NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Venta"];
        //Get old sales
        allRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.activo == %@",[NSNumber numberWithBool:YES]];
        NSArray *objects = [context executeFetchRequest:allRequest error:&error];
        //Delete old sales
        for (Venta *price in objects) {
            [context deleteObject:price];
        }
        [[EQDataAccessLayer sharedInstance] saveContext];
    }
    @autoreleasepool {
        
        NSFetchRequest *allRequest = [[NSFetchRequest alloc] initWithEntityName:@"Venta"];
        allRequest.predicate = [NSPredicate predicateWithFormat:@"SELF.activo == %@",[NSNumber numberWithBool:NO]];
        //fetch new sales
        NSArray *newObjects = [context executeFetchRequest:allRequest error:&error];
        [newObjects setValue:[NSNumber numberWithBool:YES] forKey:@"activo"];
        //now save your changes back.
        [[EQDataAccessLayer sharedInstance] saveContext];
    }
}

// first load method
- (void)updateShippingArea{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"zona_envio" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[ZonaEnvio class]]];
    
    SuccessRequest successBlock = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* envioDictionary in jsonArray) {
            ZonaEnvio *envio = (ZonaEnvio *)[adl objectForClass:[ZonaEnvio class] withId:[envioDictionary objectForKey:@"id"]];
            envio.identifier = [envioDictionary filterInvalidEntry:@"id"];
            envio.descripcion = [envioDictionary filterInvalidEntry:@"descripcion"];
            envio.codigo = [envioDictionary filterInvalidEntry:@"codigo"];
            envio.activo = [[envioDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
        }
        
        [adl saveContext];
        [self updateCompletedFor:[ZonaEnvio class]];
        [self updateProvince];
    };
    
    [self executeRequestWithParameters:dictionary successBlock:successBlock failBlock:nil];
}

- (void)updateClients{
    SuccessRequest block = ^(NSArray * jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* clienteDictionary in jsonArray) {
            Cliente *client = (Cliente *)[adl objectForClass:[Cliente class] withId:[clienteDictionary objectForKey:@"id"]];
            client.identifier = [clienteDictionary filterInvalidEntry:@"id"];
            client.cobradorID = [clienteDictionary filterInvalidEntry:@"cobrador_id"];
            client.codigoPostal = [clienteDictionary filterInvalidEntry:@"cod_postal"];
            client.codigo1 = [clienteDictionary filterInvalidEntry:@"codigo1"];
            client.codigo2 = [clienteDictionary filterInvalidEntry:@"codigo2"];
            client.condicionDePagoID = [clienteDictionary filterInvalidEntry:@"condicion_pago_id"];
            client.cuit = [clienteDictionary filterInvalidEntry:@"cuit"];
            client.conDescuento = [[clienteDictionary filterInvalidEntry:@"calificacion"] number];
            client.descuento1 = [[clienteDictionary filterInvalidEntry:@"descuento1"] number];
            client.descuento2 = [[clienteDictionary filterInvalidEntry:@"descuento2"] number];
            client.descuento3 = [[clienteDictionary filterInvalidEntry:@"descuento3"] number];
            client.descuento4 = [[clienteDictionary filterInvalidEntry:@"descuento4"] number];
            client.diasDePago = [clienteDictionary filterInvalidEntry:@"dias_de_pago"];
            client.domicilio = [clienteDictionary filterInvalidEntry:@"domicilio"];
            client.domicilioDeEnvio = [clienteDictionary filterInvalidEntry:@"domicilio_envio"];
            client.propietario = [clienteDictionary filterInvalidEntry:@"dueno"];
            client.encCompras = [clienteDictionary filterInvalidEntry:@"enc_compras"];
            client.expresoID = [clienteDictionary filterInvalidEntry:@"expreso_id"];
            client.horario = [clienteDictionary filterInvalidEntry:@"horario"];
            client.lineaDeVentaID = [clienteDictionary filterInvalidEntry:@"linea_venta_id"];
            client.localidad = [clienteDictionary filterInvalidEntry:@"localidad"];
            client.mail = [clienteDictionary filterInvalidEntry:@"mail"];
            client.nombre = [clienteDictionary filterInvalidEntry:@"nombre"];
            client.nombreDeFantasia = [clienteDictionary filterInvalidEntry:@"nombre_fantasia"];
            client.observaciones = [clienteDictionary filterInvalidEntry:@"observaciones"];
            client.provinciaID = [clienteDictionary filterInvalidEntry:@"provincia_id"];
            client.sucursal = [[clienteDictionary filterInvalidEntry:@"sucursal"] number];
            client.telefono = [clienteDictionary filterInvalidEntry:@"telefono"];
            client.ivaID = [clienteDictionary filterInvalidEntry:@"tipo_iva_id"];
            client.latitud = [[clienteDictionary filterInvalidEntry:@"ubicacion_gps_lat"] number];
            client.longitud = [[clienteDictionary filterInvalidEntry:@"ubicacion_gps_lng"] number];
            client.vendedorID = [clienteDictionary filterInvalidEntry:@"vendedor_id"];
            client.zonaEnvioID = [clienteDictionary filterInvalidEntry:@"zona_envio_id"];
            client.web = [clienteDictionary filterInvalidEntry:@"web"];
            client.actualizado = [NSNumber numberWithBool:YES];
            client.activo = [[clienteDictionary filterInvalidEntry:@"activo"] number];
            client.listaPrecios = [clienteDictionary filterInvalidEntry:@"numero_lista_precios"];
            self.dataUpdated = YES;
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
        if ([jsonArray count] > 0) {
            EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
            [[EQImagesManager sharedInstance] clearCache];
            for (NSDictionary* articuloDictionary in jsonArray) {
                Articulo *art = (Articulo *)[adl objectForClass:[Articulo class] withId:[articuloDictionary objectForKey:@"id"]];
                art.identifier = [articuloDictionary filterInvalidEntry:@"id"];
                NSMutableString *codigo = [NSMutableString stringWithString:[articuloDictionary filterInvalidEntry:@"codigo1"]];
                [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo2"]];
                [codigo appendFormat:@" %@",[articuloDictionary filterInvalidEntry:@"codigo3"]];
                art.codigo = codigo;
                art.nombre = [articuloDictionary filterInvalidEntry:@"post_title"];
                art.descripcion = [articuloDictionary filterInvalidEntry:@"descripcion"];
                
                NSDictionary *images = [articuloDictionary filterInvalidEntry:@"attachments"];
                if (images) {
                    NSString *file = [images filterInvalidEntry:@"file"];
                    NSRange range = [file rangeOfString:@"/" options:NSBackwardsSearch];
                    NSString *path = [file substringToIndex:NSMaxRange(range)];
                    
                    NSDictionary *sizes = [images filterInvalidEntry:@"sizes"];
                    NSDictionary *bigImage = [sizes filterInvalidEntry:@"items_detail_2"];
                    bigImage = bigImage ? bigImage : [sizes filterInvalidEntry:@"thumbnail"];
                    art.imagenURL = [path stringByAppendingString:[bigImage filterInvalidEntry:@"file"]];
                }
                
                art.tipo = [articuloDictionary filterInvalidEntry:@"tipo"];
                NSNumber *multiplo = [[articuloDictionary filterInvalidEntry:@"multiplo_pedido"] number];
                art.multiploPedido = [multiplo intValue] > 0 ? multiplo : @3;
                art.minimoPedido = [[articuloDictionary filterInvalidEntry:@"minimo_pedido"] number];
                art.disponibilidadID = [articuloDictionary filterInvalidEntry:@"disponibilidad_id"];
                
                NSDateFormatter *dateFormatter = DATE_FORMATTER;
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                art.creado = [dateFormatter dateFromString:[articuloDictionary filterInvalidEntry:@"creado"]];
                art.modificado = [dateFormatter dateFromString:[articuloDictionary filterInvalidEntry:@"modificado"]];
                
                art.cantidadPredeterminada = [[articuloDictionary filterInvalidEntry:@"cant_predeterm"] number];
                art.activo = [[articuloDictionary filterInvalidEntry:@"activo"] number];
                art.grupoID = [articuloDictionary filterInvalidEntry:@"term_id"];
                self.dataUpdated = YES;
            }
            [adl saveContext];
        }
        [self updateCompletedFor:[Articulo class]];
        [self updateSellers];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@"articulo" forKey:@"object"];
    [dictionary setObject:@"listar" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainLastUpdateFor:[Articulo class]]];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    
    [self executeRequestWithParameters:dictionary successBlock:block failBlock:nil];
}

- (void)updateSellers{
    SuccessRequest block = ^(NSArray *jsonArray){
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* vendedorDictionary in jsonArray) {
            Vendedor *seller = (Vendedor *)[adl objectForClass:[Vendedor class] withId:[vendedorDictionary objectForKey:@"id"]];
            seller.identifier = [vendedorDictionary filterInvalidEntry:@"id"];
            seller.codigo = [vendedorDictionary filterInvalidEntry:@"codigo"];
            seller.descripcion = [vendedorDictionary filterInvalidEntry:@"descripcion"];
            seller.activo = [[vendedorDictionary filterInvalidEntry:@"activo"] number];
            seller.usuarioID = [vendedorDictionary filterInvalidEntry:@"wp_user_id"];
            seller.usuario = (Usuario *)[adl objectForClass:[Usuario class] withId:seller.usuarioID];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* expresoDictionary in jsonArray) {
            Expreso *express = (Expreso *)[adl objectForClass:[Expreso class] withId:[expresoDictionary objectForKey:@"id"]];
            express.identifier = [expresoDictionary filterInvalidEntry:@"id"];
            express.codigo = [expresoDictionary filterInvalidEntry:@"codigo"];
            express.descripcion = [expresoDictionary filterInvalidEntry:@"descripcion"];
            express.activo = [[expresoDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* provinciaDictionary in jsonArray) {
            Provincia *province = (Provincia *)[adl objectForClass:[Provincia class] withId:[provinciaDictionary objectForKey:@"id"]];
            province.identifier = [provinciaDictionary filterInvalidEntry:@"id"];
            province.codigo = [provinciaDictionary filterInvalidEntry:@"codigo"];
            province.descripcion = [provinciaDictionary filterInvalidEntry:@"descripcion"];
            province.activo = [[provinciaDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* ivaDictionary in jsonArray) {
            TipoIvas *iva = (TipoIvas *)[adl objectForClass:[TipoIvas class] withId:[ivaDictionary objectForKey:@"id"]];
            iva.identifier = [ivaDictionary filterInvalidEntry:@"id"];
            iva.codigo = [ivaDictionary filterInvalidEntry:@"codigo"];
            iva.descripcion = [ivaDictionary filterInvalidEntry:@"descripcion"];
            iva.activo = [[ivaDictionary filterInvalidEntry:@"activo"] number];
            self.dataUpdated = YES;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* usuarioDictionary in jsonArray) {
            NSString *identifier = [usuarioDictionary filterInvalidEntry:@"wp_user_id"];
            NSString *usuario = [usuarioDictionary filterInvalidEntry:@"username"];
            NSString *password = [usuarioDictionary filterInvalidEntry:@"hashed_password"];
            Usuario *user = (Usuario *)[adl objectForClass:[Usuario class] withId:identifier];
            user.identifier = identifier;
            user.nombreDeUsuario = usuario;
            user.password = password;
            user.nombre = [usuarioDictionary filterInvalidEntry:@"display_name"];
            user.vendedorID = [usuarioDictionary filterInvalidEntry:@"vendedor_id"];
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* dictionary in jsonArray) {
            NSString *identifier = [dictionary filterInvalidEntry:@"term_id"];
            Grupo *group = (Grupo *)[adl objectForClass:[Grupo class] withId:identifier];
            group.identifier = identifier;
            group.nombre = [dictionary filterInvalidEntry:@"name"];
            group.parentID = [dictionary filterInvalidEntry:@"parent"];
            group.descripcion = [dictionary filterInvalidEntry:@"description"];
            group.count = [[dictionary filterInvalidEntry:@"count"] number];
            NSDictionary *images = [dictionary filterInvalidEntry:@"category_image"];
            if (images) {
                NSString *imagen = [images filterInvalidEntry:@"url"];
                group.imagen = [imagen stringByReplacingOccurrencesOfString:IMAGES_BASE_URL withString:@""];;
            }
            
            group.relevancia = @0;
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
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        for (NSDictionary* dictionary in jsonArray) {
            NSString *identifier = [dictionary filterInvalidEntry:@"id"];
            Disponibilidad *disponibilidad = (Disponibilidad *)[adl objectForClass:[Disponibilidad class] withId:identifier];
            disponibilidad.identifier = identifier;
            disponibilidad.descripcion = [dictionary filterInvalidEntry:@"descripcion"];
            self.dataUpdated = YES;
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
    
    __block Cliente *newClient = nil;
    SuccessRequest block = ^(NSDictionary *clientDictionary){
        newClient = (Cliente *)[[[EQDataAccessLayer sharedInstance] managedObjectContext] objectWithID:[client objectID]];
        id identifier = [clientDictionary filterInvalidEntry:@"obj_id"];
        NSString * idString = nil;
        if ([identifier isKindOfClass:[NSString class]]) {
            idString = identifier;
        } else {
            idString = [identifier stringValue];
        }
        
        if (idString) {
            newClient.identifier = idString;
        }
        
        newClient.actualizado = [NSNumber numberWithBool:YES];
        [[EQDataAccessLayer sharedInstance] saveContext];
        [[EQSession sharedInstance] updateCache];
    };
    
    FailRequest failBlock = ^(NSError *error){

    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:failBlock runInBackground:YES];
    [EQNetworkManager makeRequest:request];
}

- (NSMutableDictionary *)parseClient:(Cliente *)client{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if([client.identifier intValue] > 0) {
        [dictionary setNotNilObject:client.identifier forKey:@"id"];
    }
    if ([client.cobrador.identifier intValue] > 0) {
        [dictionary setNotNilObject:client.cobrador.identifier forKey:@"atributos[cobrador_id]"];
    }
    
    [dictionary setNotEmptyStringEscaped:client.codigoPostal forKey:@"atributos[cod_postal]"];
    [dictionary setNotEmptyStringEscaped:client.codigo1 forKey:@"atributos[codigo1]"];
    [dictionary setNotEmptyStringEscaped:client.codigo2 forKey:@"atributos[codigo2]"];
    
    if ([client.condicionDePagoID intValue] > 0) {
        [dictionary setNotNilObject:client.condicionDePagoID forKey:@"atributos[condicion_pago_id]"];
    }
    [dictionary setNotEmptyStringEscaped:client.cuit forKey:@"atributos[cuit]"];
    
    [dictionary setNotNilObject:client.conDescuento forKey:@"atributos[calificacion]"];
    [dictionary setNotNilObject:client.descuento1 forKey:@"atributos[descuento1]"];
    [dictionary setNotNilObject:client.descuento2 forKey:@"atributos[descuento2]"];
    [dictionary setNotNilObject:client.descuento3 forKey:@"atributos[descuento3]"];
    [dictionary setNotNilObject:client.descuento4 forKey:@"atributos[descuento4]"];
    [dictionary setNotEmptyStringEscaped:client.diasDePago forKey:@"atributos[dias_de_pago]"];
    [dictionary setNotEmptyStringEscaped:client.domicilio forKey:@"atributos[domicilio]"];
    [dictionary setNotEmptyStringEscaped:client.domicilioDeEnvio forKey:@"atributos[domicilio_envio]"];
    [dictionary setNotEmptyStringEscaped:client.propietario forKey:@"atributos[dueno]"];
    [dictionary setNotEmptyStringEscaped:client.encCompras forKey:@"atributos[enc_compras]"];
    if ([client.expresoID intValue] > 0) {
        [dictionary setNotNilObject:client.expresoID forKey:@"atributos[expreso_id]"];
    }
    
    [dictionary setNotEmptyStringEscaped:client.horario forKey:@"atributos[horario]"];
    if ([client.lineaDeVentaID intValue] > 0) {
        [dictionary setNotNilObject:client.lineaDeVentaID forKey:@"atributos[linea_venta_id]"];
    }
    
    [dictionary setNotEmptyStringEscaped:client.localidad forKey:@"atributos[localidad]"];
    [dictionary setNotEmptyStringEscaped:client.mail forKey:@"atributos[mail]"];
    [dictionary setNotEmptyStringEscaped:client.nombre forKey:@"atributos[nombre]"];
    [dictionary setNotEmptyStringEscaped:client.nombreDeFantasia forKey:@"atributos[nombre_fantasia]"];
    [dictionary setNotEmptyStringEscaped:client.observaciones forKey:@"atributos[observaciones]"];
    if ([client.provinciaID intValue] > 0) {
        [dictionary setNotNilObject:client.provinciaID forKey:@"atributos[provincia_id]"];
    }
    
    [dictionary setNotNilObject:client.sucursal forKey:@"atributos[sucursal]"];
    [dictionary setNotEmptyStringEscaped:client.telefono forKey:@"atributos[telefono]"];
    if ([client.ivaID intValue] > 0) {
        [dictionary setNotNilObject:client.ivaID forKey:@"atributos[tipo_iva_id]"];
    }
    
    [dictionary setNotNilObject:client.latitud forKey:@"atributos[ubicacion_gps_lat]"];
    [dictionary setNotNilObject:client.longitud forKey:@"atributos[ubicacion_gps_lng]"];
    if ([client.vendedor.identifier intValue] > 0) {
        [dictionary setNotNilObject:client.vendedor.identifier forKey:@"atributos[vendedor_id]"];
    }
    
    if ([client.zonaEnvioID intValue] > 0) {
        [dictionary setNotNilObject:client.zonaEnvioID forKey:@"atributos[zona_envio_id]"];
    }
    
    [dictionary setNotEmptyStringEscaped:client.web forKey:@"atributos[web]"];
    [dictionary setObject:client.activo forKey:@"atributos[activo]"];
    
    return dictionary;
}

- (void)sendCommunication:(Comunicacion *)communication{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setNotNilObject:@"comunicacion" forKey:@"object"];
    [dictionary setNotNilObject:[communication.identifier intValue] > 0 ? @"modificar":@"crear" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self parseCommunication:communication]];
    
    __block Comunicacion *newCommunication = nil;
    SuccessRequest block = ^(NSDictionary *communicationDictionary){
        newCommunication = (Comunicacion *)[[[EQDataAccessLayer sharedInstance] managedObjectContext] objectWithID:[communication objectID]];
        id identifier = [communicationDictionary filterInvalidEntry:@"obj_id"];
        NSString * idString = nil;
        if ([identifier isKindOfClass:[NSString class]]) {
            idString = identifier;
        } else {
            idString = [identifier stringValue];
        }
        if (idString) {
            newCommunication.identifier = idString;
        }
        
        newCommunication.actualizado = [NSNumber numberWithBool:YES];
        [[EQDataAccessLayer sharedInstance] saveContext];
    };
    
    FailRequest failBlock = ^(NSError *error){
        newCommunication.actualizado = [NSNumber numberWithBool:NO];
        [[EQDataAccessLayer sharedInstance] saveContext];
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:failBlock runInBackground:YES];
    [EQNetworkManager makeRequest:request];
}

- (NSMutableDictionary *)parseCommunication:(Comunicacion *)communication{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if([communication.identifier intValue] > 0) {
        [dictionary setNotNilObject:communication.identifier forKey:@"id"];
    }
    
    if ([communication.clienteID intValue] > 0) {
        [dictionary setNotNilObject:communication.clienteID forKey:@"atributos[cliente_id]"];
    }
    
    [dictionary setNotNilObject:communication.codigoSerial forKey:@"atributos[codigo_serial]"];
    [dictionary setNotEmptyStringEscaped:communication.descripcion forKey:@"atributos[descripcion]"];
    NSDateFormatter *dateFormatter = DATE_FORMATTER;
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dictionary setNotEmptyStringEscaped:[dateFormatter stringFromDate:communication.leido]  forKey:@"atributos[leido]"];
    [dictionary setNotNilObject:communication.receiverID forKey:@"atributos[receiver_id]"];
    [dictionary setNotNilObject:communication.senderID forKey:@"atributos[sender_id]"];
    [dictionary setNotNilObject:communication.threadID forKey:@"atributos[thread_id]"];
    [dictionary setNotNilObject:communication.tipo forKey:@"atributos[tipo]"];
    [dictionary setNotEmptyStringEscaped:communication.titulo forKey:@"atributos[titulo]"];
    [dictionary setObject:communication.activo forKey:@"atributos[activo]"];
    
    return dictionary;
}


- (void)sendOrder:(Pedido *)order{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setNotNilObject:@"pedido" forKey:@"object"];
    [dictionary setNotNilObject:[order.identifier intValue] > 0 ? @"modificar":@"crear" forKey:@"action"];
    [dictionary addEntriesFromDictionary:[self obtainCredentials]];
    [dictionary addEntriesFromDictionary:[self parseOrder:order]];
    [dictionary setValue:[NSNumber numberWithBool:YES] forKey:@"POST"];
    
    __block Pedido *newOrder = nil;
    SuccessRequest block = ^(NSDictionary *clientDictionary){
        newOrder = (Pedido *)[[[EQDataAccessLayer sharedInstance] managedObjectContext] objectWithID:[order objectID]];
        id identifier = [clientDictionary filterInvalidEntry:@"obj_id"];
        NSString * idString = nil;
        if ([identifier isKindOfClass:[NSString class]]) {
            idString = identifier;
        } else {
            idString = [identifier stringValue];
        }
        if (idString) {
            newOrder.identifier = idString;
        }
        
        newOrder.sincronizacion = [NSDate date];
        newOrder.actualizado = [NSNumber numberWithBool:YES];
        [[EQDataAccessLayer sharedInstance] saveContext];
        [[EQSession sharedInstance] updateCache];
    };
    
    FailRequest failBlock = ^(NSError *error){
        NSLog(@"send order fail error:%@ UserInfo:%@",error ,error.userInfo);
    };
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:block failRequestBlock:failBlock runInBackground:YES];
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
        [itemDictionary setObject:[NSNumber numberWithFloat:[[item.articulo priceForClient:item.pedido.cliente] priceForClient:item.pedido.cliente]] forKey:@"precio_con_descuento"];
        [itemDictionary setObject:[item.articulo priceForClient:item.pedido.cliente].importe forKey:@"precio_unitario"];
        
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
    NSDateFormatter *dateFormatter = DATE_FORMATTER;
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
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
