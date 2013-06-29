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

@implementation ItemPedido (extra)

@dynamic pedidos;
@dynamic articulos;

- (CGFloat)totalConDescuento{
    CGFloat total = [self.articulo.precio importeConDescuento] * [self.cantidad intValue];
    return total;
}

- (CGFloat)totalSinDescuento{
    CGFloat total = [self.articulo.precio.importe floatValue] * [self.cantidad intValue];
    return total;
}

- (Articulo *)articulo{
    return [self.articulos lastObject];
}

- (Pedido *)pedido{
    return [self.pedidos lastObject];
}

@end
