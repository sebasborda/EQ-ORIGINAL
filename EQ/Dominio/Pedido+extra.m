//
//  Pedido+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/29/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Pedido+extra.h"
#import "ItemPedido+extra.h"
#import "EQDataAccessLayer.h"

@implementation Pedido (extra)

@dynamic clientes;
@dynamic vendedores;

- (Cliente *)cliente{
    return [self.clientes lastObject];
}

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

- (float)porcentajeDescuento{
    CGFloat descuento = (1 - (1 - ([self.descuento3 floatValue] / 100)) * (1 - ([self.descuento4 floatValue] / 100))) * 100;
    return descuento;
}

- (Pedido *)copy{
    Pedido *order = (Pedido *)[[EQDataAccessLayer sharedInstance] createManagedObject:@"Pedido"];
    order.activo = self.activo;
    order.actualizado = [NSNumber numberWithBool:NO];
    order.descuento = self.descuento;
    order.descuento3 = self.descuento3;
    order.descuento4 = self.descuento4;
    order.latitud = self.latitud;
    order.longitud = self.longitud;
    order.observaciones = self.observaciones;
    order.subTotal = self.subTotal;
    order.total = self.total;
    order.clienteID = self.clienteID;
    order.vendedorID = self.vendedorID;
    for (ItemPedido *item in self.items) {
        [order addItemsObject:[item copy]];
    }
    
    return order;
}

- (NSDate *)fechaFacturacion{
    ItemPedido *item = [self.items anyObject];
    return item.fechaFacturado;
}

@end
