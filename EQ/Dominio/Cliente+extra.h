//
//  Cliente+extra.h
//  EQ
//
//  Created by Sebastian Borda on 6/28/13.
//  Copyright (c) 2013 Sebastian Borda. All rights reserved.
//

#import "Cliente.h"
@class Provincia;
@class Expreso;
@class LineaVTA;
@class TipoIvas;
@class ZonaEnvio;
@class CondPag;

@interface Cliente (extra)

@property (nonatomic,strong) NSArray *ventas;
@property (nonatomic,strong) NSArray *condicionesDePago;
@property (nonatomic,strong) NSArray *expresos;
@property (nonatomic,strong) NSArray *lineasDeVenta;
@property (nonatomic,strong) NSArray *ivas;
@property (nonatomic,strong) NSArray *provincias;
@property (nonatomic,strong) NSArray *zonasEnvio;
@property (nonatomic,strong) NSArray *pedidos;

- (Provincia *)provincia;
- (Expreso *)expreso;
- (LineaVTA *)lineaDeVenta;
- (TipoIvas *)iva;
- (ZonaEnvio *)zonaEnvio;
- (CondPag *)condicionDePago;
- (void)calcularRelevancia;
- (void)resetRelevancia;
@end
