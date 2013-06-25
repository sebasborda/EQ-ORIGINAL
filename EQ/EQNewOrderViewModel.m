//
//  EQNewOrderViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 5/18/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQNewOrderViewModel.h"
#import "EQDataAccessLayer.h"
#import "ItemPedido.h"
#import "EQNetworkManager.h"
#import "ItemPedido+extra.h"
#import "Grupo.h"

@interface EQNewOrderViewModel()

@end

@implementation EQNewOrderViewModel

- (id)initWithOrder:(Pedido *)order{
    self = [super init];
    if (self) {
        self.order = order;
        [self initilize];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initilize];
        self.order = (Pedido *)[[EQDataAccessLayer sharedInstance] createManagedObject:NSStringFromClass([Pedido class])];
    }
    return self;
}

- (void)initilize{
    self.categories = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == 0"]];
    [self defineSelectedCategory:0];
    self.order.descuento3 = self.ActiveClient.descuento3;
    self.order.descuento4 = self.ActiveClient.descuento4;
    self.newOrder = YES;
}

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    if (([self.group2 count] == 0 && self.group1Selected >= 0) || self.group2Selected >= 0) {
        EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
        Grupo *group = self.group2Selected >= 0 ? self.group2[self.group2Selected] : self.group1[self.group1Selected];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.grupoID == %@",group.identifier];
        self.articles = [adl objectListForClass:[Articulo class] filterByPredicate:predicate];
    }
    [self.delegate modelDidUpdateData];
}

- (void)save{
//    EQDataAccessLayer *EAL = [EQDataAccessLayer sharedInstance];
//    Pedido *newOrder =  nil;
//    if (self.order.identifier == nil) {
//        newOrder = (Pedido *)[EAL createManagedObject:@"Pedido"];
//    } else{
//        newOrder = (Pedido *)[EAL objectForClass:[Pedido class] withId:self.order.identifier];
//        newOrder.identifier = self.order.identifier;
//    }
//    
//    
//    newOrder.importe = self.order.importe;
//    [EAL saveContext];
    
    NSArray *arts = @[ @{ @"articulo_id" : @1000,
                          @"cantidad_pedida" : @10,
                          @"descuento1" : @20,
                          @"descuento2" : @20,
                          @"descuento_monto" : @2,
                          @"importe_final" : @30,
                          @"precio_con_descuento" : @3,
                          @"precio_unitario" : @5
                          },
                       @{ @"articulo_id" : @1001,
                          @"cantidad_pedida" : @20,
                          @"descuento1" : @25,
                          @"descuento2" : @0,
                          @"descuento_monto" : @2,
                          @"importe_final" : @120,
                          @"precio_con_descuento" : @6,
                          @"precio_unitario" : @8
                          }
                       ];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:@29 forKey:@"cliente_id"];
    [dictionary setValue:@13 forKey:@"vendedor_id"];
    [dictionary setValue:@100 forKey:@"ubicacion_gps_lat"];
    [dictionary setValue:@123 forKey:@"ubicacion_gps_lng"];
    [dictionary setValue:@"Observaciones de pedido (esto es un test)" forKey:@"observaciones"];
    [dictionary setValue:@1 forKey:@"activo"];
    [dictionary setValue:@"2013-04-19" forKey:@"fecha"];
    [dictionary setValue:arts forKey:@"articulos"];
    [dictionary setValue:@1 forKey:@"POST"];
    [dictionary setValue:@"crear" forKey:@"action"];
    [dictionary setValue:@"pedido" forKey:@"object"];
    [dictionary setValue:@"borgnacarlos" forKey:@"usuario"];
    [dictionary setValue:@"a1e3bdcb8199fe7383816c65076a11a7" forKey:@"password"];
    [dictionary setValue:@300 forKey:@"total"];
    [dictionary setValue:@345 forKey:@"subtotal"];
    
    
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:nil failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)defineSelectedCategory:(int)index{
    self.categorySelected = index;
    self.group1Selected = self.group2Selected = -1;
    Grupo *grupo = self.categories[self.categorySelected];
    self.group1 = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
    self.group2 = nil;
    self.articles = nil;
    self.articleSelected = nil;
    [self.delegate modelDidUpdateData];
}

- (void)defineSelectedGroup1:(int)index{
    self.group1Selected = index;
    Grupo *grupo = self.group1[self.group1Selected];
    self.group2 = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
    self.group2Selected = -1;
    self.articles = nil;
    self.articleSelected = nil;
    if ([self.group2 count] == 0) {
        [self loadData];
    } else{
        [self.delegate modelDidUpdateData];
    }
}

- (void)defineSelectedGroup2:(int)index{
    self.group2Selected = index;
    [self loadData];
}

- (void)defineSelectedArticle:(int)index{
    self.articleSelected = [self.articles objectAtIndex:index];
}

- (void)addItemQuantity:(int)quantity{
    if (quantity % 2 == 0 && quantity % [self.articleSelected.multiploPedido intValue] == 0 && quantity >= [self.articleSelected.minimoPedido intValue]) {
        BOOL existItem = NO;
        EQDataAccessLayer * DAL = [EQDataAccessLayer sharedInstance];
        for (ItemPedido *item in self.articleSelected.itemsPedido) {
            if ([item.articulo.identifier isEqualToNumber:self.articleSelected.identifier]) {
                existItem = YES;
                item.cantidad = [NSNumber numberWithInt:[item.cantidad intValue] + quantity];
            }
        }
        
        if (!existItem) {
            ItemPedido *item = (ItemPedido *)[DAL createManagedObject:@"ItemPedido"];
            item.articulo = self.articleSelected;
            item.cantidad = [NSNumber numberWithInt:quantity];
            [self.order addItemsObject:item];
        }
        
        [self.delegate modelDidAddItem];
    } else {
        [self.delegate modelAddItemDidFail];
    }
}

- (NSNumber *)itemsQuantity{
    int quantity = 0;
    for (ItemPedido *item in self.order.items) {
        quantity += [item.cantidad intValue];
    }
    
    return [NSNumber numberWithInt:quantity];
}

- (NSNumber *)subTotal{
    CGFloat subtotal = 0;
    for (ItemPedido *item in self.order.items) {
        subtotal += [item subTotal];
    }
    
    return [NSNumber numberWithFloat:subtotal];
}

- (int)discountPercentage{
    return [self.ActiveClient.descuento1 intValue];
}


- (int)discountValue{
    return  ([[self subTotal] intValue] * [self.ActiveClient.descuento1 intValue]) / 100;
}

- (float)total{
    return [[self subTotal] floatValue] - [self discountValue];
}

- (NSArray *)items{
    NSArray *items = [self.order.items allObjects];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"articulo.nombre" ascending:YES];
    items = [items sortedArrayUsingDescriptors:@[sort]];
    return items;
}

@end
