//
//  EQOrdersViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 5/15/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQOrdersViewModel.h"
#import "EQSession.h"
#import "Usuario.h"
#import "Vendedor+extra.h"
#import "Pedido+extra.h"
#import "Cliente.h"

@interface EQOrdersViewModel()

@property (nonatomic, strong) NSString* client;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;

@end

@implementation EQOrdersViewModel

- (id)init{
    self = [super init];
    if (self) {
        self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self ordersFieldByIndex:0] ascending:YES];
        self.sortFields = [NSArray arrayWithObjects:@"Estado", @"Fecha de sincronizacion", @"Fecha de facturacion", @"Cliente", @"Pedido", @"Importe Bruto", @"Importe Neto", nil];
    }
    return self;
}

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    NSArray *results = [EQSession sharedInstance].user.vendedor.pedidos;
    NSMutableArray *subPredicates = [NSMutableArray new];
    if ([self.client length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cliente.nombre == %@",self.client];
        [subPredicates addObject:predicate];
    }
    
    if ([self.status length] > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.estado == %@",self.status];
        [subPredicates addObject:predicate];
    }
    
    if (self.startBillingDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fecha >= %@",self.startBillingDate];
        [subPredicates addObject:predicate];
    }
    
    if (self.endBillingDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fecha <= %@",self.endBillingDate];
        [subPredicates addObject:predicate];
    }
    
    if (self.startSyncDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.sincronizacion <= %@",self.startSyncDate];
        [subPredicates addObject:predicate];
    }
    
    if (self.endSyncDate) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.sincronizacion >= %@",self.endSyncDate];
        [subPredicates addObject:predicate];
    }
    
    NSPredicate *predicate = [subPredicates count] > 0 ? [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates] : nil;
    if (predicate) {
        results = [results filteredArrayUsingPredicate:predicate];
    }
    
    self.orders = [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
    self.clientsList = [NSMutableArray arrayWithObject:@"Todos"];
    self.statusList = [NSMutableArray arrayWithObject:@"Todos"];
    for (Pedido *order in self.orders) {
        if ([order.cliente.nombre length] > 0 && ![self.clientsList containsObject:order.cliente.nombre]) {
            [self.clientsList addObject: order.cliente.nombre];
        }
        
        if ([order.estado length] > 0 && ![self.statusList containsObject:order.estado]) {
            [self.statusList addObject:order.estado];
        }
    }
    [self.delegate modelDidUpdateData];
}

- (NSString *)ordersFieldByIndex:(int)index{
    switch (index) {
        case 0:
            return @"estado";
            break;
        case 1:
            return @"sincronizacion";
            break;
        case 2:
            return @"fecha";
            break;
        case 3:
            return @"cliente.nombre";
            break;
        case 4:
            return @"identifier";
            break;
        case 5:
            return @"importe";
            break;
        case 6:
            return @"neto";
            break;
        default:
            return @"cliente.nombre";
            break;
    }
}

- (void)changeSortOrder:(int)index{
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:[self ordersFieldByIndex:index] ascending:YES];
    self.orders = [self.orders sortedArrayUsingDescriptors:[NSArray arrayWithObject:self.sortDescriptor]];
    [self.delegate modelDidUpdateData];
}

- (void)defineClient:(NSString *)client{
    if ([client isEqualToString:@"Todos"]) {
        self.client = nil;
    } else {
        self.client = client;
    }
    
    [self loadData];
}

- (void)defineStatus:(NSString *)status{
    if ([status isEqualToString:@"Todos"]) {
        self.status = nil;
    } else {
        self.status = status;
    }
    
    [self loadData];
}

@end
