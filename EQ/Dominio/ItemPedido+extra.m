//
//  ItemPedido+extra.m
//  EQ
//
//  Created by Sebastian Borda on 5/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "ItemPedido+extra.h"
#import "Articulo.h"
#import "Precio.h"
#import "Precio+extra.h"
#import "Articulo+extra.h"
#import "EQDataAccessLayer.h"
#import "Pedido+extra.h"

@implementation ItemPedido (extra)

@dynamic articulos;

- (CGFloat)totalConDescuento{
    CGFloat total = [[self.articulo priceForClient:self.pedido.cliente] priceForClient:self.pedido.cliente] * [self.cantidad intValue];
    return total;
}

- (CGFloat)totalSinDescuento{
    CGFloat total = [[self.articulo priceForClient:self.pedido.cliente].importe floatValue] * [self.cantidad intValue];
    return total;
}

- (Articulo *)articulo{
    return [self.articulos lastObject];
}

- (ItemPedido *)copy{
    ItemPedido *item = (ItemPedido *)[[EQDataAccessLayer sharedInstance] createManagedObject:@"ItemPedido"];
    item.articuloID = self.articuloID;
    item.descuento1 = self.descuento1;
    item.descuento2 = self.descuento2;
    item.cantidad = self.cantidad;
    item.descuentoMonto = self.descuentoMonto;
    item.importeConDescuento = self.importeConDescuento;
    item.importeFinal = self.importeFinal;
    item.precioUnitario = self.precioUnitario;
    
    return item;
}

@end
