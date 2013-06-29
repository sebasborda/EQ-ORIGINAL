//
//  ItemPedido+extra.h
//  EQ
//
//  Created by Sebastian Borda on 5/20/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "ItemPedido.h"
@class Pedido;
@class Articulo;

@interface ItemPedido (extra)

@property (nonatomic, strong) NSArray* articulos;
@property (nonatomic, strong) NSArray* pedidos;

- (CGFloat)totalConDescuento;
- (CGFloat)totalSinDescuento;
- (Articulo *)articulo;
- (Pedido *)pedido;

@end

