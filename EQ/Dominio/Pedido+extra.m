//
//  Pedido+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/29/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Pedido+extra.h"
#import "ItemPedido+extra.h"

@implementation Pedido (extra)

@dynamic clientes;
@dynamic vendedores;

- (Cliente *)cliente{
    return [self.clientes lastObject];
}

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

@end
