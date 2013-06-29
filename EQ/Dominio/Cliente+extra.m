//
//  Cliente+extra.m
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Cliente+extra.h"

@implementation Cliente (extra)

@dynamic ventas;
@dynamic condicionesDePago;
@dynamic expresos;
@dynamic lineasDeVenta;
@dynamic ivas;
@dynamic provincias;
@dynamic zonasEnvio;

- (Provincia *)provincia{
    return [self.provincias lastObject];
}

- (Expreso *)expreso{
    return [self.expresos lastObject];
}

- (LineaVTA *)lineaDeVenta{
    return [self.lineasDeVenta lastObject];
}

- (TipoIvas *)iva{
    return [self.expresos lastObject];
}

- (ZonaEnvio *)zonaEnvio{
    return [self.zonasEnvio lastObject];
}

- (CondPag *)condicionDePago{
    return [self.condicionesDePago lastObject];
}

@end
