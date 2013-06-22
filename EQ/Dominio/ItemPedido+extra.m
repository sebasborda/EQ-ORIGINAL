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
#import "Precio+Cliente.h"

@implementation ItemPedido (extra)

- (CGFloat)subTotal{
    CGFloat subTotal = [self.articulo.precio importeConDescuento] * [self.cantidad intValue];
    return subTotal;
}

@end
