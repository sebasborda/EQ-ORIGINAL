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
#import "Pedido+extra.h"

@implementation ItemPedido (extra)

@dynamic articulos;

- (CGFloat)totalConDescuento{
    CGFloat total = [self.articulo.precio priceForClient:self.pedido.cliente] * [self.cantidad intValue];
    return total;
}

- (CGFloat)totalSinDescuento{
    CGFloat total = [self.articulo.precio.importe floatValue] * [self.cantidad intValue];
    return total;
}

- (Articulo *)articulo{
    return [self.articulos lastObject];
}

//- (BOOL)isEqual:(id)object{
//    if ([object isKindOfClass:[ItemPedido class]]) {
//        ItemPedido *item = object;
//        return [item.articuloID isEqualToNumber:self.articuloID] && [item.pedido.identifier isEqualToNumber:self.pedido.identifier];
//    }
//    return NO;
//}

@end
