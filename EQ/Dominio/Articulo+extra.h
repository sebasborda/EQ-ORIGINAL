//
//  Articulo+extra.h
//  EQ
//
//  Created by Sebastian Borda on 6/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Articulo.h"
@class Disponibilidad;
@class Precio;
@class Grupo;

@interface Articulo (extra)

@property (nonatomic,strong) NSArray *precios;
@property (nonatomic,strong) NSArray *disponibilidades;
@property (nonatomic,strong) NSArray *grupos;

- (Disponibilidad *)disponibilidad;
- (Precio *)precio;
- (Grupo *)grupo;
@end
