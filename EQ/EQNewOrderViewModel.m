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

@interface EQNewOrderViewModel()

@property (nonatomic,strong) NSString *categorySelected;
@property (nonatomic,strong) NSString *group1Selected;
@property (nonatomic,strong) NSString *group2Selected;

@end

@implementation EQNewOrderViewModel

- (id)initWithOrder:(Pedido *)order{
    self = [super init];
    if (self) {
        self.order = order;
    }
    return self;
}

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    
    if (self.order) {
        self.items = [self.order.items allObjects];
    }
    
    EQDataAccessLayer *adl = [EQDataAccessLayer sharedInstance];
    self.articles = [adl objectListForClass:[Articulo class]];
    
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
    
    NSArray *numbers = [NSArray arrayWithObjects:@1,@2,@3,@4,@5, nil];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:[NSNumber numberWithInt:2] forKey:@"cliente_id"];
    [dictionary setValue:[NSNumber numberWithInt:1] forKey:@"vendedor_id"];
    [dictionary setValue:[NSNumber numberWithInt:100] forKey:@"ubicacion_gps_lat"];
    [dictionary setValue:[NSNumber numberWithInt:123] forKey:@"ubicacion_gps_lng"];
    [dictionary setValue:@"Observaciones de pedido (esto es un test)" forKey:@"observaciones"];
    [dictionary setValue:[NSNumber numberWithInt:1] forKey:@"activo"];
    [dictionary setValue:@"2013-04-19" forKey:@"fecha"];
    [dictionary setValue:numbers forKey:@"articulos"];
    [dictionary setValue:numbers forKey:@"cantidades"];
    [dictionary setValue:@"JSON" forKey:@"POST"];
    
    EQRequest *request = [[EQRequest alloc] initWithParams:dictionary successRequestBlock:nil failRequestBlock:nil];
    [EQNetworkManager makeRequest:request];
}

- (void)defineSelectedCategory:(NSString *)category{
    self.categorySelected = category;
}

- (void)defineSelectedGroup1:(int)index{
    self.group1Selected = [self.group1 objectAtIndex:index];
    [self loadData];
}

- (void)defineSelectedGroup2:(int)index{
    self.group2Selected = [self.group2 objectAtIndex:index];
    [self loadData];
}

- (void)defineSelectedArticle:(int)index{
    self.articleSelected = [self.articles objectAtIndex:index];
}

- (void)addItemQuantity:(int)quantity{
    if (quantity % 2 == 0 && quantity % [self.articleSelected.multiploPedido intValue] && quantity > [self.articleSelected.minimoPedido intValue]) {
        BOOL existItem = NO;
        EQDataAccessLayer * DAL = [EQDataAccessLayer sharedInstance];
        for (ItemPedido *item in self.articleSelected.itemsPedido) {
            if ([item.articulo.identifier isEqualToNumber:self.articleSelected.identifier]) {
                existItem = YES;
                item.cantidad = [NSNumber numberWithInt:[item.cantidad intValue] + quantity];
                break;
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
        subtotal += [[item subTotal] floatValue];
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

@end
