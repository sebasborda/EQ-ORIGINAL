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

@implementation ItemPedido (extra)

- (NSNumber *)subTotal{
    CGFloat subTotal = [self.articulo.precio.importe floatValue] * [self.cantidad intValue];
    return [NSNumber numberWithFloat:subTotal];
}

@end
