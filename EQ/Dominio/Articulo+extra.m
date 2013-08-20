//
//  Articulo+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/27/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Articulo+extra.h"
#import "Precio+extra.h"
#import "Cliente+extra.h"
#import "EQSession.h"

@implementation Articulo (extra)

@dynamic disponibilidades;
@dynamic grupos;

- (Disponibilidad *)disponibilidad{
    return [self.disponibilidades lastObject];
}

- (Precio *)priceForActiveClient{
    return [self priceForClient:[EQSession sharedInstance].selectedClient];
}

- (Precio *)priceForClient:(Cliente *)client{
    Precio *price = nil;
    for (Precio *p in client.listaDePrecios) {
        if([p.articuloID isEqualToNumber:self.identifier]){
            price = p;
            break;
        }
    }
    return price;
}

- (Grupo *)grupo{
    return [self.grupos lastObject];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"article id:%@ description:%@ availability:%@",self.identifier,self.description, self.disponibilidad];
}

@end
