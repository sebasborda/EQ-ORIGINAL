//
//  Precio+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Precio+extra.h"
#import "EQSession.h"

@implementation Precio (extra)

@dynamic articulo;

- (CGFloat)priceForActiveClient {
    Cliente *cliente = [EQSession sharedInstance].selectedClient;
    return [self priceForClient:cliente];
}

- (CGFloat)priceForClient:(Cliente *)client {
    CGFloat descuento = [client.descuento1 floatValue] + [client.descuento2 floatValue];
    CGFloat importeConDescuento = ([self.importe floatValue] * (100 - descuento)) / 100;
    
    return importeConDescuento;
}

@end
