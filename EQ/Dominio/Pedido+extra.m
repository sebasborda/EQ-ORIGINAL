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
#import "ItemFacturado.h"

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

- (NSDate *)ultimaFechaDeFacturacion {
    NSDate *ultimaFecha = nil;
    for (NSDate *date in [self fechasFacturacion]) {
        if(!ultimaFecha || [date compare: ultimaFecha] == NSOrderedDescending) {
            ultimaFecha = date;
        }
    }
    return ultimaFecha;
}

- (NSDate *)primerFechaDeFacturacion {
    NSDate *primerFecha = nil;
    for (NSDate *date in [self fechasFacturacion]) {
        if(!primerFecha || [date compare: primerFecha] == NSOrderedAscending) {
            primerFecha = date;
        }
    }
    return primerFecha;
}

- (NSMutableArray *)fechasFacturacion{
    ItemPedido *item = [self.items anyObject];
    NSMutableArray *fechas = [NSMutableArray array];
    for (ItemFacturado *facturado in item.facturados) {
        if (facturado.facturado) {
            [fechas addObject:facturado.facturado];
        }
    }
    return fechas;
}

@end
