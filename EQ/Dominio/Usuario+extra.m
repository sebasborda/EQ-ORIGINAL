//
//  Usuario+extra.m
//  EQ
//
//  Created by Sebastian Borda on 7/7/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Usuario+extra.h"

@implementation Usuario (extra)

@dynamic comunicaciones;
@dynamic vendedores;

- (Vendedor *)vendedor{
    return [self.vendedores lastObject];
}

@end
