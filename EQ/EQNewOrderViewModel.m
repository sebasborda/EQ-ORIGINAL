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
#import "Grupo+extra.h"
#import "EQDataManager.h"
#import "Vendedor+extra.h"
#import "EQSession.h"
#import "Cliente+extra.h"
#import "Precio+extra.h"
#import "Disponibilidad+extra.h"
#import "Articulo+extra.h"

#define DEFAULT_CATEGORY @"artistica"

@interface EQNewOrderViewModel()

@property (nonatomic,strong) NSUndoManager *undoManager;
@property (nonatomic,strong) NSSortDescriptor *sortArticle;
@property (nonatomic,strong) NSSortDescriptor *sortGroup1;
@property (nonatomic,strong) NSSortDescriptor *sortGroup2;
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
        self.order = (Pedido *)[[EQDataAccessLayer sharedInstance] createManagedObject:NSStringFromClass([Pedido class])];
        self.order.clienteID = self.ActiveClient.identifier;
        self.order.tempClientID = self.ActiveClient.tempID;
        self.order.descuento3 = self.ActiveClient.descuento3;
        self.order.descuento4 = self.ActiveClient.descuento4;
        self.order.vendedorID = self.currentSeller.identifier;
        [self initilize];
    }
    return self;
}

- (void)initilize{
    self.undoManager = [[NSUndoManager alloc] init];
    [[self.order managedObjectContext] setUndoManager:self.undoManager];
    [self.undoManager beginUndoGrouping];
    self.categories = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == 0"]];
    
    [self sortArticlesByIndex:0];
    [self sortGroup1ByIndex:0];
    [self sortGroup2ByIndex:0];
    Grupo *defaultGroup = [self.categories filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.nombre like[cd] %@",DEFAULT_CATEGORY]][0];

    self.categorySelected = [self.categories indexOfObject:defaultGroup];
    self.group1 = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",defaultGroup.identifier]];
    self.group1 = [self.group1 sortedArrayUsingDescriptors:@[self.sortGroup1]];
    self.group1Selected = self.group2Selected = NSNotFound;
    self.newOrder = YES;
    [self.delegate modelDidUpdateData];
}

- (void)loadData{
    [self.delegate modelWillStartDataLoading];
    if (([self.group2 count] == 0 && self.group1Selected != NSNotFound) || self.group2Selected != NSNotFound) {
        Grupo *group = self.group2Selected != NSNotFound ? self.group2[self.group2Selected] : self.group1[self.group1Selected];
        self.articles = [group.articulos sortedArrayUsingDescriptors:@[self.sortArticle]];
    }
    if ([self.group1 count] > 0) {
        self.group1 = [self.group1 sortedArrayUsingDescriptors:@[self.sortGroup1]];
    }
    if ([self.group2 count] > 0) {
        self.group2 = [self.group2 sortedArrayUsingDescriptors:@[self.sortGroup2]];
    }
    
    [self.delegate modelDidUpdateData];
}

- (void)save{
    [self.undoManager endUndoGrouping];
    if (self.order.fecha == nil) {
        self.order.fecha = [NSDate date];
        self.order.latitud = [[EQSession sharedInstance] currentLatitude];
        self.order.longitud = [[EQSession sharedInstance] currentLongitude];
    }

    if (self.newOrder) {
        if ([self.order.estado length] == 0) {
            self.order.estado = @"pendiente";
        }
        
        if (self.ActiveClient) {
            self.order.clienteID = self.ActiveClient.identifier;
            self.order.tempClientID = self.ActiveClient.tempID;
        }
    }
    
    self.order.subTotal = [self subTotal];
    self.order.total = [NSNumber numberWithFloat:[self total]];
    self.order.descuento = [NSNumber numberWithInt:[self discountValue]];
    self.order.activo = [NSNumber numberWithBool:YES];
    self.order.actualizado = [NSNumber numberWithBool:NO];
    [[EQDataAccessLayer sharedInstance] saveContext];
    [[EQSession sharedInstance] updateCache];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[EQDataManager sharedInstance] sendOrder:self.order andUpdate:NO fullUpdate:NO];
    });
}

- (void)defineSelectedCategory:(NSUInteger)index{
    self.categorySelected = index;
    self.group1Selected = self.group2Selected = NSNotFound;
    Grupo *grupo = self.categories[self.categorySelected];
    self.group1 = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
    self.group1 = [self.group1 sortedArrayUsingDescriptors:@[self.sortGroup1]];
    self.group2 = nil;
    self.articles = nil;
    self.articleSelected = nil;
    [self.delegate modelDidUpdateData];
}

- (void)defineSelectedGroup1:(NSUInteger)index{
    self.group1Selected = index;
    Grupo *grupo = self.group1[self.group1Selected];
    self.group2 = [[EQDataAccessLayer sharedInstance] objectListForClass:[Grupo class] filterByPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
    self.group2 = [self.group2 sortedArrayUsingDescriptors:@[self.sortGroup2]];
    self.group2Selected = NSNotFound;
    self.articles = nil;
    self.articleSelected = nil;
    if ([self.group2 count] == 0) {
        [self loadData];
    } else{
        [self.delegate modelDidUpdateData];
    }
}

- (void)defineSelectedGroup2:(NSUInteger)index{
    self.group2Selected = index;
    self.articleSelected = nil;
    self.articleSelectedIndex = NSNotFound;
    [self loadData];
}

- (void)defineSelectedArticle:(NSUInteger)index{
    Articulo *article = [self.articles objectAtIndex:index];
    NSString *message = [self canAddArticle:article];
    if (message == nil) {
        self.articleSelected = article;
        self.articleSelectedIndex = index;
        [self.delegate modelDidUpdateData];
    } else {
        [self.delegate articleUnavailable:message];
    }
}

- (void)defineOrderStatus:(NSUInteger)index{
    if (index == 0) {
        self.order.estado = @"presupuestado";
    } else {
        self.order.estado = @"pendiente";
    }
}

- (void)AddQuantity:(NSUInteger)quantity canAdd:(BOOL)canAdd {
    if (canAdd) {
        BOOL existItem = NO;
        EQDataAccessLayer * DAL = [EQDataAccessLayer sharedInstance];
        for (ItemPedido *item in self.order.items) {
            if ([item.articulo.identifier isEqualToString:self.articleSelected.identifier]) {
                existItem = YES;
                item.cantidad = [NSNumber numberWithUnsignedInteger:quantity];
            }
        }
        
        if (!existItem) {
            ItemPedido *item = (ItemPedido *)[DAL createManagedObject:@"ItemPedido"];
            item.articuloID = self.articleSelected.identifier;
            item.cantidad = [NSNumber numberWithUnsignedInteger:quantity];
            [self.order addItemsObject:item];
            item.orden = @([self.order.items count]);
        }
        
        [self.delegate modelDidAddItem];
    } else {
        [self.delegate modelAddItemDidFail];
    }
}

- (BOOL)addItemQuantity:(NSUInteger)quantity{
    int multiplo = [self.articleSelected.multiploPedido intValue];
    int minimo = [self.articleSelected.minimoPedido intValue];
    BOOL canAdd = self.articleSelected && quantity % multiplo == 0 && quantity >= minimo;
    [self AddQuantity:quantity canAdd:canAdd];
    
    return canAdd;
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
        subtotal += [item totalConDescuento];
    }
    
    return [NSNumber numberWithFloat:subtotal];
}

- (float)discountPercentage{
    return [self.order porcentajeDescuento];
}


- (float)discountValue{
    return  ([[self subTotal] floatValue] * [self discountPercentage]) / 100;
}

- (float)total{
    return [[self subTotal] floatValue] - [self discountValue];
}

- (NSArray *)items{
    return [self.order sortedItems];
}

- (int)orderStatusIndex{
    if ([self.order.estado isEqualToString:@"presupuestado"]) {
        return 0;
    }
    
    return 1;
}

- (NSDate *)date{
    return self.order.fecha ? self.order.fecha : [NSDate date];
}

- (void)removeItem:(ItemPedido *)item{
    [self.order removeItemsObject:item];
    [self loadData];
}

- (void)editItem:(ItemPedido *)item{
    Grupo *g1 = item.articulo.grupo;
    Grupo *g3 , *g2 = nil;
    
    if (![g1.parentID isEqualToString:@"0"]) {
        g2 = g1.parent;
    }
    
    if (![g2.parentID isEqualToString:@"0"]) {
        g3 = g2.parent;
    }
    
    if (g3) {
        NSUInteger index = [self.categories indexOfObject:g3];
        [self defineSelectedCategory:index];
        
        index = [self.group1 indexOfObject:g2];
        [self defineSelectedGroup1:index];
        
        index = [self.group2 indexOfObject:g1];
        [self defineSelectedGroup2:index];
        
        index = [self.articles indexOfObject:item.articulo];
        [self defineSelectedArticle:index];
    } else {
        NSUInteger index = [self.categories indexOfObject:g2];
        [self defineSelectedCategory:index];
        
        index = [self.group1 indexOfObject:g1];
        [self defineSelectedGroup1:index];
        
        index = [self.articles indexOfObject:item.articulo];
        [self defineSelectedArticle:index];
    }
}


- (NSNumber *)quantityOfCurrentArticle{
    for (ItemPedido *item in self.order.items) {
        if ([self.articleSelected isEqual:item.articulo]) {
            return item.cantidad;
        }
    }
    
    return @0;
}

- (void)cancelOrder{
    [self.undoManager endUndoGrouping];
    [self.undoManager undo];
}

- (void)sortArticlesByIndex:(NSUInteger)index{
    self.sortArticle = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"codigo" : @"nombre" ascending:YES];
    [self loadData];
}

- (void)sortGroup2ByIndex:(NSUInteger)index{
    self.sortGroup2 = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"relevancia" : @"nombre" ascending:index == 1];
    [self loadData];
}

- (void)sortGroup1ByIndex:(NSUInteger)index{
    self.sortGroup1 = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"relevancia" : @"nombre" ascending:index == 1];
    [self loadData];
}

- (NSString *)canAddArticle:(Articulo *)article{
    Cliente *client = self.ActiveClient;
    if (!self.newOrder) {
        client = self.order.cliente;
    }

    Precio *precio = [article priceForClient:client];
    if (precio == nil) {
        return [NSString stringWithFormat:@"No se encontro precio para el articulo:%@ lista:%@",article.identifier,client.listaPrecios];
    }

    if (![article.disponibilidad isAvailable]) {
        return [NSString stringWithFormat:@"El estado del articulo:%@ estado:%@",article.identifier, [article.disponibilidad descripcion]];
    }

    if (![article.activo boolValue]) {
        return [NSString stringWithFormat:@"El articulo:%@ no esta activo",article.identifier];
    }


    return  nil;
}

- (NSString *)orderHTML {
    return [self.order pedidoHTML];
}

@end
