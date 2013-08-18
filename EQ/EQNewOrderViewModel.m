//
//  EQNewOrderViewModel.m
//  EQ
//
//  Created by Sebastian Borda on 5/18/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "EQNewOrderViewModel.h"
 
#import "ItemPedido.h"
#import "EQNetworkManager.h"
#import "ItemPedido+extra.h"
#import "Grupo+extra.h"
#import "EQDataManager.h"
#import "Vendedor+extra.h"
#import "EQSession.h"

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
        self.order = [Pedido MR_createEntity];
        self.order.clienteID = self.ActiveClient.identifier;
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
    self.categories = [Grupo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.parentID == 0"]];
    [self sortArticlesByIndex:0];
    [self sortGroup1ByIndex:0];
    [self sortGroup2ByIndex:0];
    [self defineSelectedCategory:0];
    self.newOrder = YES;
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
    if (self.newOrder) {
        self.order.fecha = [NSDate date];
        self.order.latitud = [[EQSession sharedInstance] currentLatitude];
        self.order.longitud = [[EQSession sharedInstance] currentLongitude];
        if ([self.order.estado length] == 0) {
            self.order.estado = @"pendiente";
        }
        
        if (self.ActiveClient) {
            self.order.clienteID = self.ActiveClient.identifier;
        }
    }
    
    self.order.subTotal = [self subTotal];
    self.order.total = [NSNumber numberWithFloat:[self total]];
    self.order.descuento = [NSNumber numberWithInt:[self discountValue]];
    self.order.activo = [NSNumber numberWithBool:YES];
    self.order.actualizado = [NSNumber numberWithBool:NO];
    
    [[EQDataManager sharedInstance] sendOrder:self.order];
    [[EQSession sharedInstance] updateCache];
}

- (void)defineSelectedCategory:(int)index{
    self.categorySelected = index;
    self.group1Selected = self.group2Selected = NSNotFound;
    Grupo *grupo = self.categories[self.categorySelected];
    self.group1 = [Grupo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
    self.group1 = [self.group1 sortedArrayUsingDescriptors:@[self.sortGroup1]];
    self.group2 = nil;
    self.articles = nil;
    self.articleSelected = nil;
    [self.delegate modelDidUpdateData];
}

- (void)defineSelectedGroup1:(int)index{
    self.group1Selected = index;
    Grupo *grupo = self.group1[self.group1Selected];
    self.group2 = [Grupo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"self.parentID == %@",grupo.identifier]];
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

- (void)defineSelectedGroup2:(int)index{
    self.group2Selected = index;
    self.articleSelected = nil;
    self.articleSelectedIndex = NSNotFound;
    [self loadData];
}

- (void)defineSelectedArticle:(int)index{
    Articulo *article = [self.articles objectAtIndex:index];
    if ([self canAddArticle:article]) {
        self.articleSelected = article;
        self.articleSelectedIndex = index;
        [self.delegate modelDidUpdateData];
    } else {
        [self.delegate articleUnavailable];
    }
}

- (void)defineOrderStatus:(int)index{
    if (index == 0) {
        self.order.estado = @"presupuestado";
    } else {
        self.order.estado = @"pendiente";
    }
}

- (void)addItemQuantity:(int)quantity{
    int multiplicity = [self.articleSelected.multiploPedido intValue] <= 2 ? [self.articleSelected.multiploPedido intValue] : [self.articleSelected.multiploPedido intValue] * 2;
    if (self.articleSelected && quantity % multiplicity == 0 && quantity >= [self.articleSelected.minimoPedido intValue]) {
        BOOL existItem = NO;
        for (ItemPedido *item in self.order.items) {
            if ([item.articulo.identifier isEqualToNumber:self.articleSelected.identifier]) {
                existItem = YES;
                item.cantidad = [NSNumber numberWithInt:quantity];
            }
        }
        
        if (!existItem) {
            ItemPedido *item = [ItemPedido MR_createEntity];
            item.articuloID = self.articleSelected.identifier;
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
    NSArray *items = [self.order.items allObjects];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"articulo.nombre" ascending:YES];
    items = [items sortedArrayUsingDescriptors:@[sort]];
    return items;
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
    
    if (![g1.parentID isEqualToNumber:@0]) {
        g2 = g1.parent;
    }
    
    if (![g2.parentID isEqualToNumber:@0]) {
        g3 = g2.parent;
    }
    
    if (g3) {
        int index = [self.categories indexOfObject:g3];
        [self defineSelectedCategory:index];
        
        index = [self.group1 indexOfObject:g2];
        [self defineSelectedGroup1:index];
        
        index = [self.group2 indexOfObject:g1];
        [self defineSelectedGroup2:index];
        
        index = [self.articles indexOfObject:item.articulo];
        [self defineSelectedArticle:index];
    } else {
        int index = [self.categories indexOfObject:g2];
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

- (void)sortArticlesByIndex:(int)index{
    self.sortArticle = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"codigo" : @"nombre" ascending:YES];
    [self loadData];
}

- (void)sortGroup2ByIndex:(int)index{
    self.sortGroup2 = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"relevancia" : @"nombre" ascending:index == 1];
    [self loadData];
}

- (void)sortGroup1ByIndex:(int)index{
    self.sortGroup1 = [NSSortDescriptor sortDescriptorWithKey:index == 0 ? @"relevancia" : @"nombre" ascending:index == 1];
    [self loadData];
}

- (BOOL)canAddArticle:(Articulo *)article{
    Cliente *client = self.ActiveClient;
    if (!self.newOrder) {
        client = self.order.cliente;
    }
    
    return [article priceForClient:client] != nil && [article.disponibilidadID intValue] == 1;
}

@end
