//
//  CtaCte+extra.m
//  EQ
//
//  Created by Sebastian Borda on 7/3/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "CtaCte+extra.h"

@implementation CtaCte (extra)

@dynamic vendedores;
@dynamic clientes;

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

- (Cliente *)cliente{
    return [self.clientes lastObject];
}

@end
