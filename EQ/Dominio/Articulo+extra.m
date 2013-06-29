//
//  Articulo+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Articulo+extra.h"

@implementation Articulo (extra)

@dynamic precios;
@dynamic disponibilidades;
@dynamic grupos;

- (Disponibilidad *)disponibilidad{
    return [self.disponibilidades lastObject];
}

- (Precio *)precio{
    return [self.precios lastObject];
}

- (Grupo *)grupo{
    return [self.grupos lastObject];
}

@end
