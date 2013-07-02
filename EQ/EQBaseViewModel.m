//
//  EQBaseViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 4/14/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQBaseViewModel.h"
#import "EQSession.h"
#import "Usuario.h"
#import "Vendedor.h"
#import "EQDataAccessLayer.h"
#import "Pedido.h"

@interface EQBaseViewModel()

@property (nonatomic,strong) NSArray* clients;
@property (nonatomic,assign) int pendigOrdersCount;

@end

@implementation EQBaseViewModel

- (void)loadClients{
    NSArray *results = [[EQSession sharedInstance].user.vendedor.clienteVendedor allObjects];
    results = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.actualizado == true "]];
    self.clients = [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]]];
}

- (void)loadTopBarData{
    [[EQSession sharedInstance] updateCache];
    NSArray *orders = [[EQDataAccessLayer sharedInstance] objectListForClass:[Pedido class] filterByPredicate:[NSPredicate predicateWithFormat:@"SELF.estado == %@ and SELF.vendedorID == %@",@"pendiente",self.currentSeller.identifier]];
    self.pendigOrdersCount = [orders count];
}

- (NSString *)sellerName{
    return [EQSession sharedInstance].user.vendedor ? [EQSession sharedInstance].user.vendedor.descripcion : [EQSession sharedInstance].user.nombre;
}

- (NSString *)lastUpdateWithFormat{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy | HH:mm"];
    return  [NSString stringWithFormat:@"%@ hs.",[dateFormat stringFromDate:[[EQSession sharedInstance] lastSyncDate]]];
}

- (NSString *)currentDateWithFormat{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yy"];
    return  [dateFormat stringFromDate:[NSDate date]];
}

- (NSString *)clientName{
    return [EQSession sharedInstance].selectedClient.nombre;
}

- (NSString *)clientStatus{
    return @"Cliente activo";
}

- (Cliente *)ActiveClient{
    return [EQSession sharedInstance].selectedClient;
}

- (Vendedor *)currentSeller{
    return [EQSession sharedInstance].user.vendedor;
}

- (void)selectClientAtIndex:(NSUInteger)index{
    Cliente *client = [self.clients objectAtIndex:index];
    [client calcularRelevancia];
    [EQSession sharedInstance].selectedClient = client;
}

- (NSArray *)clientsNameList{
    NSMutableArray *names = [NSMutableArray array];
    for (Cliente *client in self.clients) {
        [names addObject:client.nombre];
    }
    
    return names;
}

- (int)obtainPendigOrdersCount{
    return self.pendigOrdersCount;
}

@end
