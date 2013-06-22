//
//  Precio+Cliente.m
//  EQ
//
//  Created by Sebastian Borda on 6/21/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Precio+Cliente.h"
#import "EQSession.h"
#import "Cliente.h"
@implementation Precio (Cliente)

- (CGFloat)importeConDescuento {
    Cliente *cliente = [EQSession sharedInstance].selectedClient;
    CGFloat descuento = [cliente.descuento1 floatValue] + [cliente.descuento2 floatValue];
    CGFloat importeConDescuento = ([self.importe floatValue] * (100 - descuento)) / 100;
    
    return importeConDescuento;
}

@end
