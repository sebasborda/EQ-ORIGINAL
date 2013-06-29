//
//  Precio+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Precio+extra.h"
#import "EQSession.h"
#import "Cliente.h"

@implementation Precio (extra)

@dynamic articulo;

- (CGFloat)importeConDescuento {
    Cliente *cliente = [EQSession sharedInstance].selectedClient;
    CGFloat descuento = [cliente.descuento1 floatValue] + [cliente.descuento2 floatValue];
    CGFloat importeConDescuento = ([self.importe floatValue] * (100 - descuento)) / 100;
    
    return importeConDescuento;
}

@end
